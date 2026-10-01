// ReAct 引擎核心模块
// 实现推理(Reason) + 行动(Act) 循环

use "llm/provider"
use "tools/definition"
use "tools/registry"
use "memory/short_term"

/// ReAct 步骤类型
pub enum StepType {
  Thought     // 推理思考
  Action      // 工具调用
  Observation // 观察工具结果
  FinalAnswer // 最终回答
} derive(Show, Eq)

/// ReAct 单步记录
pub struct ReactStep {
  step_type: StepType
  content: String
  timestamp: Int
} derive(Show)

/// ReAct 执行结果
pub struct ReactOutput {
  steps: Array[ReactStep]
  final_answer: String
  iterations_used: Int
  success: Bool
  error: Option[String]
}

/// ReAct 引擎配置
pub struct ReactConfig {
  max_iterations: Int       // 最大迭代次数
  system_prompt: String     // 系统提示词
  stop_on_error: Bool       // 错误时是否停止
  verbose: Bool             // 是否输出调试信息
}

pub fn default_config() -> ReactConfig {
  ReactConfig::{
    max_iterations: 10,
    system_prompt: default_system_prompt(),
    stop_on_error: false,
    verbose: false
  }
}

/// 默认系统提示词
fn default_system_prompt() -> String {
  "You are a helpful AI assistant with access to tools.\n\n" +
  "To solve problems, follow the ReAct pattern:\n" +
  "1. Think: Analyze what you need to do\n" +
  "2. Action: Use a tool in the format Action: tool_name(args)\n" +
  "3. Observe: Review the tool output\n" +
  "4. Repeat until you have enough information\n" +
  "5. Final Answer: Provide your conclusion\n\n" +
  "Always think before acting."
}

/// ReAct 引擎主结构
pub struct ReactEngine {
  config: ReactConfig
  registry: Registry
  llm: Box[LLMProvider]
  memory: ShortMemory
  steps: Array[ReactStep]
}

/// 创建 ReAct 引擎
pub fn ReactEngine::new(
  config: ReactConfig,
  registry: Registry,
  llm: Box[LLMProvider]
) -> ReactEngine {
  ReactEngine::{
    config: config,
    registry: registry,
    llm: llm,
    memory: ShortMemory::new(50),
    steps: Array::new()
  }
}

/// 执行 ReAct 循环
pub fn ReactEngine::run(
  self: ReactEngine,
  user_input: String
) -> Result[ReactOutput, String] {
  // 初始化对话历史
  let system_msg = system_msg(self.config.system_prompt)
  let tools_msg = system_msg(self.registry.format_for_llm() + "\n" + self.registry.tool_hint())
  let user_msg = user_msg(user_input)
  
  self.memory.add(system_msg)
  self.memory.add(tools_msg)
  self.memory.add(user_msg)
  
  // 添加工具描述到可用步骤
  let _ = self.registry.format_for_llm()
  let _ = self.registry.tool_hint()
  
  // ReAct 主循环
  let mut iteration = 0
  let mut final_answer = ""
  
  while iteration < self.config.max_iterations {
    iteration = iteration + 1
    
    // 获取 LLM 响应
    let messages = self.memory.get_all()
    let response = self.llm.chat(messages)
    
    match response {
      Ok(llm_resp) => {
        match llm_resp.finish_reason {
          ToolCalls => {
            // 处理工具调用
            let tool_calls = llm_resp.tool_calls
            if tool_calls.length() == 0 {
              // 没有工具调用，解析文本中的工具调用
              match llm_resp.content {
                Some(content) => {
                  // 检查是否包含 "行动:" 或 "Action:" 前缀
                  if self._is_final_answer(&content) {
                    final_answer = self._extract_final_answer(&content)
                    self.memory.add(assistant_msg(content))
                    break
                  } else {
                    // 尝试解析为工具调用
                    match self._parse_tool_call_from_text(&content) {
                      Some((tool_name, args)) => {
                        // 添加思考步骤
                        let thought = self._extract_thought(&content)
                        self.steps.push(ReactStep[{
                          step_type: Thought,
                          content: thought,
                          timestamp: iteration
                        })
                        
                        // 执行工具
                        let result = self.registry.execute(
                          tool_name,
                          args,
                          "call_\{iteration}",
                          "agent"
                        )
                        
                        self.steps.push(ReactStep[{
                          step_type: Action,
                          content: "\{tool_name}(\{args})",
                          timestamp: iteration
                        })
                        
                        self.steps.push(ReactStep[{
                          step_type: Observation,
                          content: result.output,
                          timestamp: iteration
                        })
                        
                        self.memory.add(assistant_msg("Action: \{tool_name}(\{args})"))
                        self.memory.add(tool_msg("call_\{iteration}", tool_name, result.output))
                      }
                      None => {
                        // 没有工具调用，当作普通思考处理
                        self.memory.add(assistant_msg(content))
                        if self._is_final_answer(&content) {
                          final_answer = self._extract_final_answer(&content)
                          break
                        }
                      }
                    }
                  }
                }
                None => ()
              }
            } else {
              // 处理结构化工具调用
              for tool_call in tool_calls {
                self.steps.push(ReactStep[{
                  step_type: Action,
                  content: "\{tool_call.name}(\{tool_call.arguments})",
                  timestamp: iteration
                })
                
                let result = self.registry.execute(
                  tool_call.name,
                  tool_call.arguments,
                  tool_call.id,
                  "agent"
                )
                
                self.steps.push(ReactStep[{
                  step_type: Observation,
                  content: result.output,
                  timestamp: iteration
                })
                
                self.memory.add(tool_msg(tool_call.id, tool_call.name, result.output))
              }
            }
          }
          
          Stop => {
            // 正常结束
            match llm_resp.content {
              Some(content) => {
                if self._is_final_answer(&content) {
                  final_answer = self._extract_final_answer(&content)
                } else {
                  final_answer = content
                }
              }
              None => ()
            }
            break
          }
          
          Error(msg) => {
            // 错误处理
            if self.config.stop_on_error {
              return Err("LLM error: \{msg}")
            }
          }
          
          Length => {
            // 达到长度限制，尝试提取已有答案
            match llm_resp.content {
              Some(content) => {
                final_answer = content
              }
              None => ()
            }
            break
          }
        }
      }
      Err(e) => {
        if self.config.stop_on_error {
          return Err("LLM call failed: \{e}")
        }
      }
    }
  }
  
  Ok(ReactOutput[{
    steps: self.steps,
    final_answer: final_answer,
    iterations_used: iteration,
    success: final_answer.length() > 0,
    error: if final_answer.length() > 0 { None } else { Some("Max iterations reached without final answer") }
  })
}

/// 从文本中提取思考内容
fn ReactEngine::_extract_thought(_self: ReactEngine, text: String) -> String {
  let lines = text.split("\n")
  let mut result = ""
  for line in lines {
    let trimmed = line.trim()
    if trimmed.starts_with("思考:") || trimmed.starts_with("Thought:") {
      result = trimmed.substring(3, trimmed.length()).trim()
      break
    } else if trimmed.starts_with("Action:") || trimmed.starts_with("行动:") {
      break
    } else if result.length() > 0 {
      result = result + "\n" + trimmed
    } else {
      result = trimmed
    }
  }
  result
}

/// 判断是否为最终答案
fn ReactEngine::_is_final_answer(_self: ReactEngine, text: String) -> Bool {
  text.contains("最终答案:") || text.contains("Final Answer:")
}

/// 提取最终答案
fn ReactEngine::_extract_final_answer(_self: ReactEngine, text: String) -> String {
  let markers = ["最终答案:", "Final Answer:"]
  for marker in markers {
    let idx = text.index_of(marker)
    match idx {
      Some(i) => return text.substring(i + marker.length(), text.length()).trim()
      None => ()
    }
  }
  text.trim()
}

/// 从文本解析工具调用
fn ReactEngine::_parse_tool_call_from_text(
  _self: ReactEngine,
  text: String
) -> Option[(String, String)] {
  // 格式: "行动: tool_name(args)" 或 "Action: tool_name(args)"
  let markers = ["行动:", "Action:"]
  for marker in markers {
    let idx = text.index_of(marker)
    match idx {
      Some(i) => {
        let action_text = text.substring(i + marker.length(), text.length()).trim()
        // 解析工具名和参数
        let paren_idx = action_text.index_of("(")
        match paren_idx {
          Some(p) => {
            let name = action_text.substring(0, p).trim()
            let close_idx = action_text.index_of(")")
            match close_idx {
              Some(c) => {
                let args = action_text.substring(p + 1, c).trim()
                return Some((name, args))
              }
              None => {
                return Some((name, ""))
              }
            }
          }
          None => {
            return Some((action_text, ""))
          }
        }
      }
      None => ()
    }
  }
  None
}

/// Agent 主结构 - 封装完整的 Agent 能力
pub struct Agent {
  engine: ReactEngine
  name: String
  description: String
  tools: Registry
  memory: ShortMemory
  config: AgentConfig
}

pub struct AgentConfig {
  name: String
  description: String
  max_iterations: Int
  verbose: Bool
  system_prompt: String
}

pub fn AgentConfig::new(name: String) -> AgentConfig {
  AgentConfig[{
    name: name,
    description: "",
    max_iterations: 10,
    verbose: false,
    system_prompt: default_system_prompt()
  }]
}

/// 构建 Agent
pub fn Agent::builder(name: String) -> AgentBuilder {
  AgentBuilder::{
    config: AgentConfig::new(name),
    registry: Registry::new(),
    llm: None
  }
}

pub struct AgentBuilder {
  config: AgentConfig
  registry: Registry
  llm: Option[Box[LLMProvider]]
}

pub fn AgentBuilder::description(self: AgentBuilder, desc: String) -> AgentBuilder {
  let new_config = AgentConfig[{
    name: self.config.name,
    description: desc,
    max_iterations: self.config.max_iterations,
    verbose: self.config.verbose,
    system_prompt: self.config.system_prompt
  }]
  AgentBuilder[{
    config: new_config,
    registry: self.registry,
    llm: self.llm
  }]
}

pub fn AgentBuilder::max_iterations(self: AgentBuilder, max: Int) -> AgentBuilder {
  let new_config = AgentConfig[{
    name: self.config.name,
    description: self.config.description,
    max_iterations: max,
    verbose: self.config.verbose,
    system_prompt: self.config.system_prompt
  }]
  AgentBuilder[{
    config: new_config,
    registry: self.registry,
    llm: self.llm
  }]
}

pub fn AgentBuilder::llm(self: AgentBuilder, provider: Box[LLMProvider]) -> AgentBuilder {
  AgentBuilder[{
    config: self.config,
    registry: self.registry,
    llm: Some(provider)
  }]
}

pub fn AgentBuilder::tool(
  self: AgentBuilder,
  name: String,
  description: String,
  params: Array[ToolParam],
  executor: ToolExecutorFn
) -> AgentBuilder {
  let new_registry = self.registry.register(name, description, params, "", executor)
  AgentBuilder[{
    config: self.config,
    registry: new_registry,
    llm: self.llm
  }]
}

pub fn AgentBuilder::build(self: AgentBuilder) -> Result[Agent, String] {
  let llm = match self.llm {
    Some(provider) => provider,
    None => return Err("LLM provider is required")
  }
  
  let react_config = ReactConfig[{
    max_iterations: self.config.max_iterations,
    system_prompt: self.config.system_prompt,
    stop_on_error: false,
    verbose: self.config.verbose
  }]
  
  Ok(Agent{
    engine: ReactEngine::new(react_config, self.registry, llm),
    name: self.config.name,
    description: self.config.description,
    tools: self.registry,
    memory: ShortMemory::new(50),
    config: self.config
  })
}

/// Agent 运行入口
pub fn Agent::run(self: Agent, input: String) -> Result[AgentResponse, String] {
  match self.engine.run(input) {
    Ok(output) => {
      Ok(AgentResponse[{
        content: output.final_answer,
        iterations: output.iterations_used,
        steps: output.steps,
        agent_name: self.name
      }])
    }
    Err(e) => Err(e)
  }
}

/// Agent 响应
pub struct AgentResponse {
  content: String,
  iterations: Int,
  steps: Array[ReactStep],
  agent_name: String
}

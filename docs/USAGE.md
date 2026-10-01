# MoonAgent Reactor 使用指南

## 快速开始

### 最简单的 Agent

```moonbit
use "core/react_engine"
use "llm/mock"

fn main {
  let llm = MockProvider::new([|
    "思考: 简单问题\n最终答案: Hello! I am your AI assistant."
  |])
  
  let engine = ReactEngine::new(default_config(), Registry::new(), llm)
  match engine.run("你好") {
    Ok(output) => println(output.final_answer)
    Err(e) => println("Error: \{e}")
  }
}
```

### 带工具的 Agent (Builder 模式)

```moonbit
use "core/agent"
use "llm/mock"
use "tools/builtin/calculator"

fn main {
  match Agent::builder("math_helper")
    .description("Agent with calculator")
    .tool("calculate", "Math tool", [string_param("expr", "Expression", true)], CalcTool::execute)
    .llm(mock_llm)
    .build() {
    Ok(agent) => {
      match agent.run("2 + 2 = ?") {
        Ok(resp) => println(resp.content)
        Err(e) => println("Error: \{e}")
      }
    }
    Err(e) => println("Build error: \{e}")
  }
}
```

## 接入真实 LLM

### OpenAI

```moonbit
use "llm/openai_compat"

fn main {
  let config = OpenAIConfig[{
    base_url: "https://api.openai.com/v1",
    api_key: "sk-...",
    model: "gpt-4",
    temperature: 0.7,
    max_tokens: 4096,
    timeout_ms: 60000
  }]
  
  let llm = OpenAIProvider::new(config)
  let agent = Agent::builder("gpt4_agent")
    .llm(llm)
    .build()
}
```

### Ollama (本地部署)

```moonbit
let llm = ollama_provider("llama3.2")
```

## ReAct 模式详解

Agent 的执行循环:

1. **Thought**: 分析当前状态，推理下一步
2. **Action**: 调用工具获取信息
3. **Observation**: 观察工具返回结果
4. **循环** 1-3 直到满足以下条件之一:
   - 获得足够信息 → Final Answer
   - 达到 max_iterations

## 工具开发

自定义工具只需要实现执行函数:

```moonbit
fn my_tool_execute(args: String, ctx: ToolContext) -> ToolResult {
  // 解析参数
  let params = parse_simple_args(args)
  
  // 执行逻辑
  let result = do_something(params)
  
  // 返回结果
  ToolResult::ok("Tool executed successfully")
}

// 注册工具
let registry = registry.register(
  "my_tool",
  "Does something useful",
  [string_param("input", "Input data", true)],
  "Output description",
  my_tool_execute
)
```

## Memory 系统

### Short Memory (对话历史)

```moonbit
let mem = ShortMemory::new(50)  // 保留最近 50 条消息
let mem = mem.add(user_msg("Hello"))
let messages = mem.get_all()
```

### Long Memory (知识库)

```moonbit
let ltm = LongTermMemory::new(1000)
let ltm = ltm.remember("fact1", "MoonBit is fast", "tech", 8)
let results = ltm.search("MoonBit")
```

## 规划系统

```moonbit
use "planner/plan"

fn main {
  let plan = Plan::new("Research Task")
  // 添加子任务...
  println(plan.summary())
}
```

## 最佳实践

1. **max_iterations 设置**: 复杂任务设 10-15，简单问题设 3-5
2. **工具描述**: 清晰的描述帮助 LLM 正确选择工具
3. **错误处理**: 在工具中区分成功和失败
4. **Memory 管理**: 短期对话不超长，长期知识定期清理

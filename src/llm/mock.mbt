// Mock LLM 后端实现 (用于测试和演示)

use "llm/provider"

/// Mock LLM 后端 - 返回预定义的响应序列
pub struct MockProvider {
  responses: Array[String]
  current_index: Int
  call_count: Int
}

pub fn MockProvider::new(responses: Array[String]) -> MockProvider {
  MockProvider::{
    responses: responses,
    current_index: 0,
    call_count: 0
  }
}

/// 使用 MockProvider 作为 LLMProvider 的实现
pub fn MockProvider::chat(
  self: MockProvider,
  messages: Array[Message]
) -> Result[LLMResponse, String] {
  if self.current_index >= self.responses.length() {
    return Ok(assistant_text("思考: 我需要查看已完成的工作。\n最终答案: 我已经完成了任务。"))
  }
  
  let response = self.responses[self.current_index]
  let new_provider = MockProvider::{
    responses: self.responses,
    current_index: self.current_index + 1,
    call_count: self.call_count + 1
  }
  
  // 模拟响应解析 (简化: 检查是否是工具调用)
  let llm_response = self._parse_response(response)
  let _ = messages  // 使用 messages 避免警告
  let _ = new_provider
  Ok(llm_response)
}

fn MockProvider::name(_self: MockProvider) -> String {
  "MockProvider"
}

fn MockProvider::supports_tool_calling(_self: MockProvider) -> Bool {
  true
}

fn MockProvider::_parse_response(
  _self: MockProvider,
  response: String
) -> LLMResponse {
  // 简单解析响应文本
  // 如果包含 "行动:" 前缀，则解析为工具调用
  if response.contains("行动:") {
    let lines = response.split("\n")
    let mut tool_calls = Array::new()
    let mut content = ""
    
    for line in lines {
      let trimmed = line.trim()
      if trimmed.starts_with("思考:") {
        content = content + trimmed + "\n"
      } else if trimmed.starts_with("行动:") {
        // 解析工具调用: "行动: tool_name(args)"
        let action = trimmed.substring(3, trimmed.length())
        let trimmed_action = action.trim()
        // 提取工具名称和参数
        let (name, args) = self._parse_action(trimmed_action)
        tool_calls.push(ToolCall::{
          id: "call_\{tool_calls.length() + 1}",
          name: name,
          arguments: args
        })
      } else if trimmed.starts_with("观察:") {
        content = content + "Observation: " + trimmed.substring(3, trimmed.length()) + "\n"
      }
    }
    
    if tool_calls.length() > 0 {
      LLMResponse::{
        content: Some(content),
        tool_calls: tool_calls,
        finish_reason: ToolCalls,
        usage: Some(TokenUsage::{
          prompt_tokens: 10,
          completion_tokens: response.length(),
          total_tokens: 10 + response.length()
        })
      }
    } else {
      assistant_text(content + response)
    }
  } else if response.contains("最终答案:") {
    let idx = response.index_of("最终答案:")
    match idx {
      Some(i) => {
        let answer = response.substring(i + 5, response.length())
        assistant_text(answer.trim())
      }
      None => assistant_text(response)
    }
  } else {
    assistant_text(response)
  }
}

fn MockProvider::_parse_action(
  _self: MockProvider,
  action: String
) -> (String, String) {
  // 解析 "tool_name(args)" 格式
  let idx = action.index_of("(")
  match idx {
    Some(i) => {
      let name = action.substring(0, i).trim()
      let args_len = action.length()
      let args = if args_len > i + 1 {
        action.substring(i + 1, args_len - 1)
      } else {
        ""
      }
      (name, args)
    }
    None => (action, "")
  }
}

/// 创建一个简单的问答 Mock
pub fn simple_qa_mock(answers: Array[String]) -> MockProvider {
  MockProvider::new(answers)
}

/// 创建一个带工具调用的 Mock
pub fn tool_calling_mock(
  thoughts: Array[String],
  tool_results: Array[String],
  final_answer: String
) -> MockProvider {
  let all_responses = Array::new()
  // 交替添加思考和工具调用
  let thought_len = thoughts.length()
  let tool_len = tool_results.length()
  let max_iter = if thought_len > tool_len { thought_len } else { tool_len }
  
  for i in Range::new(0, max_iter) {
    if i < thought_len {
      all_responses
    }
  }
  // 简化: 返回基本响应
  MockProvider::new([|
    "思考: 让我分析一下这个问题\n行动: search(量子计算)",
    "观察: 搜索到量子计算相关信息",
    "思考: 我现在有了足够的信息\n最终答案: 量子计算是一种利用量子力学原理的计算方式"
  |])
}

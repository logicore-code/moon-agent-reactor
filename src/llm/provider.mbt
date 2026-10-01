// LLM 后端接口定义模块
// 定义了 Agent 可以使用的 LLM 后端抽象接口

/// LLM 消息角色
pub enum Role {
  System
  User
  Assistant
  Tool        // 工具调用结果
} derive(Show, Eq)

/// 单条消息
pub struct Message {
  role: Role
  content: String
  name: Option[String]        // 调用者名称 (Tool 消息用)
  tool_call_id: Option[String] // 工具调用 ID
} derive(Show)

/// 工具调用请求 (由 LLM 生成)
pub struct ToolCall {
  id: String
  name: String
  arguments: String  // JSON 格式的参数
} derive(Show)

/// LLM 响应
pub struct LLMResponse {
  content: Option[String]
  tool_calls: Array[ToolCall]
  finish_reason: FinishReason
  usage: Option[TokenUsage]
}

pub enum FinishReason {
  Stop          // 正常停止
  ToolCalls     // 决定调用工具
  Length        // 达到长度限制
  Error(String) // 错误
} derive(Show)

/// Token 使用量统计
pub struct TokenUsage {
  prompt_tokens: Int
  completion_tokens: Int
  total_tokens: Int
} derive(Show)

/// LLM 后端接口
pub trait LLMProvider {
  /// 发送消息并获取响应
  fn chat(messages: Array[Message]) -> Result[LLMResponse, String]
  
  /// 获取后端名称
  fn name() -> String
  
  /// 是否支持工具调用
  fn supports_tool_calling() -> Bool
}

/// 创建系统消息
pub fn system_msg(content: String) -> Message {
  Message::{
    role: System,
    content: content,
    name: None,
    tool_call_id: None
  }
}

/// 创建用户消息
pub fn user_msg(content: String) -> Message {
  Message::{
    role: User,
    content: content,
    name: None,
    tool_call_id: None
  }
}

/// 创建助手消息
pub fn assistant_msg(content: String) -> Message {
  Message::{
    role: Assistant,
    content: content,
    name: None,
    tool_call_id: None
  }
}

/// 创建工具结果消息
pub fn tool_msg(tool_call_id: String, name: String, content: String) -> Message {
  Message::{
    role: Tool,
    content: content,
    name: Some(name),
    tool_call_id: Some(tool_call_id)
  }
}

/// 创建带工具调用的助手消息
pub fn assistant_with_tool_calls(
  content: Option[String],
  tool_calls: Array[ToolCall]
) -> LLMResponse {
  LLMResponse::{
    content: content,
    tool_calls: tool_calls,
    finish_reason: if tool_calls.length() > 0 { ToolCalls } else { Stop },
    usage: None
  }
}

/// 创建纯文本助手响应
pub fn assistant_text(content: String) -> LLMResponse {
  LLMResponse::{
    content: Some(content),
    tool_calls: Array::new(),
    finish_reason: Stop,
    usage: None
  }
}

/// 创建错误响应
pub fn error_response(msg: String) -> LLMResponse {
  LLMResponse::{
    content: None,
    tool_calls: Array::new(),
    finish_reason: Error(msg),
    usage: None
  }
}

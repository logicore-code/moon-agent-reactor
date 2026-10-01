// 工具注册模块
// 管理工具集合

use "tools/definition"
use "llm/provider"

/// 工具注册
pub struct ToolEntry {
  metadata: ToolMetadata
  executor: ToolExecutor
}

/// 工具执行器函数类型
pub type ToolExecutorFn (String, ToolContext) -> ToolResult

pub struct ToolExecutor {
  name: String
  fn_exec: ToolExecutorFn
}

/// 工具注册表
pub struct Registry {
  tools: Map[String, ToolEntry]
}

pub fn Registry::new() -> Registry {
  Registry::{ tools: Map::new() }
}

/// 注册工具
pub fn Registry::register(
  self: Registry,
  name: String,
  description: String,
  params: Array[ToolParam],
  returns: String,
  executor: ToolExecutorFn
) -> Registry {
  let entry = ToolEntry::{
    metadata: ToolMetadata::{
      name: name,
      description: description,
      parameters: params,
      returns: returns
    },
    executor: ToolExecutor::{
      name: name,
      fn_exec: executor
    }
  }
  let new_tools = self.tools.insert(name, entry)
  Registry::{ tools: new_tools }
}

/// 获取工具元数据
pub fn Registry::get_metadata(self: Registry, name: String) -> Option[ToolMetadata] {
  match self.tools.get(name) {
    Some(entry) => Some(entry.metadata)
    None => None
  }
}

/// 列出所有工具
pub fn Registry::list_tools(self: Registry) -> Array[ToolMetadata] {
  let result = Array::new()
  for entry in self.tools.values() {
    result.push(entry.metadata)
  }
  result
}

/// 执行工具调用
pub fn Registry::execute(
  self: Registry,
  tool_name: String,
  args: String,
  call_id: String,
  agent_name: String
) -> ToolResult {
  match self.tools.get(tool_name) {
    Some(entry) => {
      let ctx = ToolContext[{
        agent_name: agent_name,
        call_id: call_id,
        memory: ToolMemory::{ store: Map::new() }
      }
      entry.executor.fn_exec(args, ctx)
    }
    None => ToolResult::err("Tool not found: \{tool_name}")
  }
}

/// 检查工具是否已注册
pub fn Registry::has(self: Registry, name: String) -> Bool {
  self.tools.contains(name)
}

/// 获取工具数量
pub fn Registry::count(self: Registry) -> Int {
  self.tools.size()
}

/// 生成所有工具的 LLM 描述
pub fn Registry::format_for_llm(self: Registry) -> String {
  let mut result = "Available Tools:\n\n"
  for entry in self.tools.values() {
    result = result + tool_to_llm_format(entry.metadata) + "\n"
  }
  result
}

/// 生成工具使用提示
pub fn Registry::tool_hint(self: Registry) -> String {
  "When you need to use a tool, respond in this format:\n" +
  "Action: tool_name(args)\n" +
  "Observation: [result will appear here]"
}

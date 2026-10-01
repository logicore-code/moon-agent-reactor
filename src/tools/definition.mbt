// 工具定义模块
// 定义工具接口和类型系统

/// 工具参数类型
pub enum ToolParamType {
  String
  Number
  Boolean
  Array
  Object
  Integer
} derive(Show, Eq)

/// 工具参数定义
pub struct ToolParam {
  name: String
  description: String
  param_type: ToolParamType
  required: Bool
  default_value: Option[String]
} derive(Show)

/// 工具元数据
pub struct ToolMetadata {
  name: String
  description: String
  parameters: Array[ToolParam]
  returns: String
} derive(Show)

/// 工具执行上下文
pub struct ToolContext {
  agent_name: String
  call_id: String
  memory: ToolMemory
}

pub struct ToolMemory {
  store: Map[String, String]
}

/// 工具执行结果
pub struct ToolResult {
  success: Bool
  output: String
  error: Option[String]
  metadata: Map[String, String]
} derive(Show)

pub fn ToolResult::ok(output: String) -> ToolResult {
  ToolResult::{
    success: true,
    output: output,
    error: None,
    metadata: Map::new()
  }
}

pub fn ToolResult::err(msg: String) -> ToolResult {
  ToolResult::{
    success: false,
    output: "",
    error: Some(msg),
    metadata: Map::new()
  }
}

/// 创建简单字符串参数
pub fn string_param(name: String, desc: String, required: Bool) -> ToolParam {
  ToolParam::{
    name: name,
    description: desc,
    param_type: String,
    required: required,
    default_value: None
  }
}

/// 创建整数参数
pub fn int_param(name: String, desc: String, required: Bool) -> ToolParam {
  ToolParam::{
    name: name,
    description: desc,
    param_type: Integer,
    required: required,
    default_value: None
  }
}

/// 创建布尔参数
pub fn bool_param(name: String, desc: String, required: Bool) -> ToolParam {
  ToolParam::{
    name: name,
    description: desc,
    param_type: Boolean,
    required: required,
    default_value: None
  }
}

/// 创建数组参数
pub fn array_param(name: String, desc: String, required: Bool) -> ToolParam {
  ToolParam[{
    name: name,
    description: desc,
    param_type: Array,
    required: required,
    default_value: None
  }
}

/// 解析简单参数
pub fn parse_simple_args(args: String) -> Map[String, String] {
  let result = Map::new()
  let trimmed = args.trim()
  if trimmed.length() == 0 {
    return result
  }
  for pair in trimmed.split(",") {
    let idx = pair.index_of(":")
    match idx {
      Some(i) => {
        let key = pair.substring(0, i).trim()
        let value = pair.substring(i + 1, pair.length()).trim()
        result.insert(key, value)
      }
      None => {
        result.insert("query", pair.trim())
      }
    }
  }
  result
}

/// 生成工具的 LLM 格式描述
pub fn tool_to_llm_format(meta: ToolMetadata) -> String {
  let mut result = "\{meta.name}: \{meta.description}\n"
  result = result + "Parameters:\n"
  for param in meta.parameters {
    let req_str = if param.required { " (required)" } else { " (optional)" }
    result = result + "  - \{param.name} (\{param.param_type}): \{param.description}\{req_str}\n"
  }
  result
}

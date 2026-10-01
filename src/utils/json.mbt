// JSON 工具模块
// 简化版 JSON 解析和序列化

/// JSON 值类型
pub enum JsonValue {
  JsonNull
  JsonBool(Bool)
  JsonNumber(Double)
  JsonString(String)
  JsonArray(Array[JsonValue])
  JsonObject(Map[String, JsonValue])
} derive(Show, Eq)

/// JSON 解析结果
pub type JsonResult Result[JsonValue, String]

/// 解析 JSON 字符串 (简化实现)
pub fn parse_json(input: String) -> JsonResult {
  let trimmed = input.trim()
  
  match trimmed {
    "null" => Ok(JsonNull),
    "true" => Ok(JsonBool(true)),
    "false" => Ok(JsonBool(false)),
    _ => {
      // 检查是否为数字
      if is_number(trimmed) {
        match Double::from_string(trimmed) {
          Ok(n) => Ok(JsonNumber(n)),
          Err(_) => parse_string_or_object(trimmed)
        }
      } else if trimmed.starts_with("\"") && trimmed.ends_with("\"") {
        Ok(JsonString(trimmed.substring(1, trimmed.length() - 1)))
      } else if trimmed.starts_with("{") && trimmed.ends_with("}") {
        parse_object(trimmed)
      } else if trimmed.starts_with("[") && trimmed.ends_with("]") {
        parse_array(trimmed)
      } else {
        Ok(JsonString(trimmed))
      }
    }
  }
}

/// 序列化 JSON 值
pub fn stringify_json(value: JsonValue) -> String {
  match value {
    JsonNull => "null"
    JsonBool(true) => "true"
    JsonBool(false) => "false"
    JsonNumber(n) => {
      if n == n.to_int().to_double() {
        n.to_int().to_string()
      } else {
        n.to_string()
      }
    }
    JsonString(s) => "\"\{s}\""
    JsonArray(items) => {
      let elements = items.map(fn(v) { stringify_json(v) }).join(",")
      "[\{elements}]"
    }
    JsonObject(map) => {
      let pairs = Array::new()
      for key in map.keys() {
        pairs.push("\"\{key}\":\{stringify_json(map.get(key).unwrap())}")
      }
      "{ \{pairs.join(", \")} }"
    }
  }
}

/// 获取对象字段
pub fn JsonObject::get(self: JsonValue, key: String) -> Option[JsonValue] {
  match self {
    JsonObject(map) => map.get(key),
    _ => None
  }
}

/// 获取数组元素
pub fn JsonValue::get_array_item(self: JsonValue, index: Int) -> Option[JsonValue] {
  match self {
    JsonArray(items) => {
      if index >= 0 && index < items.length() {
        Some(items[index])
      } else {
        None
      }
    }
    _ => None
  }
}

/// 安全的字符串获取
pub fn JsonValue::as_string(self: JsonValue) -> Option[String] {
  match self {
    JsonString(s) => Some(s),
    _ => None
  }
}

/// 安全的数字获取
pub fn JsonValue::as_number(self: JsonValue) -> Option[Double] {
  match self {
    JsonNumber(n) => Some(n),
    _ => None
  }
}

/// 安全的布尔获取
pub fn JsonValue::as_bool(self: JsonValue) -> Option[Bool] {
  match self {
    JsonBool(b) => Some(b),
    _ => None
  }
}

fn is_number(s: String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let first = s[0]
  (first >= '0' && first <= '9') || first == '-'
}

fn parse_string_or_object(s: String) -> JsonResult {
  //尝试作为对象解析
  if s.starts_with("{") && s.ends_with("}") {
    parse_object(s)
  } else {
    Ok(JsonString(s))
  }
}

fn parse_object(s: String) -> JsonResult {
  // 简化: 只返回空对象 (完整版需要递归解析)
  Ok(JsonObject(Map::new()))
}

fn parse_array(s: String) -> JsonResult {
  // 简化: 只返回空数组
  Ok(JsonArray(Array::new()))
}

/// 简化版 JSON 对象构建器
pub struct JsonBuilder {
  data: Map[String, JsonValue]
}

pub fn JsonBuilder::new() -> JsonBuilder
  JsonBuilder::{ data: Map::new() }

pub fn JsonBuilder::put_string(self: JsonBuilder, key: String, value: String) -> JsonBuilder {
  let new_data = self.data.insert(key, JsonString(value))
  JsonBuilder::{ data: new_data }
}

pub fn JsonBuilder::put_number(self: JsonBuilder, key: String, value: Double) -> JsonBuilder {
  let new_data = self.data.insert(key, JsonNumber(value))
  JsonBuilder::{ data: new_data }
}

pub fn JsonBuilder::put_bool(self: JsonBuilder, key: String, value: Bool) -> JsonBuilder {
  let new_data = self.data.insert(key, JsonBool(value))
  JsonBuilder::{ data: new_data }
}

pub fn JsonBuilder::put_null(self: JsonBuilder, key: String) -> JsonBuilder {
  let new_data = self.data.insert(key, JsonNull)
  JsonBuilder::{ data: new_data }
}

pub fn JsonBuilder::build(self: JsonBuilder) -> JsonValue {
  JsonObject(self.data)
}

pub fn JsonBuilder::to_string(self: JsonBuilder) -> String
  stringify_json(JsonObject(self.data))

// 内置计算器工具
// 支持基本数学运算

use "tools/definition"

pub struct CalcTool {}

pub fn CalcTool::metadata() -> ToolMetadata {
  ToolMetadata[{
    name: "calculate",
    description: "Evaluate a mathematical expression. Supports +, -, *, /, ^",
    parameters: [
      string_param("expression", "Mathematical expression to evaluate", true)
    ],
    returns: "Result as a number string"
  }
}

pub fn CalcTool::execute(args: String, ctx: ToolContext) -> ToolResult {
  let expr = args.trim()
  if expr.length() == 0 {
    return ToolResult::err("Expression cannot be empty")
  }
  
  let result = evaluate(expr)
  match result {
    Ok(value) => ToolResult::ok(stringify_number(value)),
    Err(e) => ToolResult::err("Calculation error: \{e}")
  }
}

fn CalcTool::validate_args(args: String) -> Result[Map[String, String], String] {
  let trimmed = args.trim()
  if trimmed.length() == 0 {
    Err("Expression cannot be empty")
  } else {
    Ok(parse_simple_args(trimmed))
  }
}

fn evaluate(expr: String) -> Result[Double, String] {
  let tokens = tokenize(expr)
  match parse_and_eval(tokens) {
    Ok(value) => Ok(value),
    Err(e) => Err(e)
  }
}

fn tokenize(expr: String) -> Array[String] {
  let tokens = Array::new()
  let current = ""
  for ch in expr.chars() {
    if ch.is_whitespace() {
      if current.length() > 0 {
        tokens.push(current)
      }
    } else if is_operator(ch) {
      if current.length() > 0 {
        tokens.push(current)
      }
      tokens.push(ch.to_string())
    } else if ch == '(' || ch == ')' {
      if current.length() > 0 {
        tokens.push(current)
      }
      tokens.push(ch.to_string())
    } else {
      // continue building current token
    }
  }
  if current.length() > 0 {
    tokens.push(current)
  }
  tokens
}

fn parse_and_eval(tokens: Array[String]) -> Result[Double, String] {
  if tokens.length() == 3 {
    let left = parse_number(tokens[0])?
    let op = tokens[1]
    let right = parse_number(tokens[2])?
    match op {
      "+" => Ok(left + right)
      "-" => Ok(left - right)
      "*" => Ok(left * right)
      "/" => {
        if right == 0.0 {
          Err("Division by zero")
        } else {
          Ok(left / right)
        }
      }
      "^" => Ok(left ** right)
      _ => Err("Unknown operator: \{op}")
    }
  } else if tokens.length() == 1 {
    parse_number(tokens[0])
  } else {
    Err("Complex expressions not supported in this version")
  }
}

fn parse_number(s: String) -> Result[Double, String] {
  Double::from_string(s)
}

fn is_operator(ch: Char) -> Bool {
  ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '^'
}

fn stringify_number(n: Double) -> String {
  n.to_string()
}

pub fn register_calculator(registry: Registry) -> Registry {
  registry.register(
    "calculate",
    "Evaluate mathematical expressions",
    [string_param("expression", "Math expression like '2 + 3 * 4'", true)],
    "Number result",
    CalcTool::execute
  )
}

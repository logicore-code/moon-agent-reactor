// 工具系统测试

test "tool param creation" {
  let p1 = string_param("query", "Search query", true)
  let p2 = int_param("count", "Result count", false)
  let p3 = bool_param("verbose", "Enable verbose", false)
  println("Params created: \{p1.name}, \{p2.name}, \{p3.name}")
}

test "parse simple args with colon" {
  let args = "query:MoonBit language,limit:10"
  let params = parse_simple_args(args)
  println("Parsed \{params.entries().length()} args")
}

test "parse simple args without colon" {
  let args = "MoonBit programming language"
  let params = parse_simple_args(args)
  println("Default query param set")
}

test "tool result helpers" {
  let ok = ToolResult::ok("Success output")
  let err = ToolResult::err("Error message")
  println("ToolResult helpers work: ok.success=\{ok.success}, err.success=\{err.success}")
}

test "tool metadata formatting" {
  let meta = ToolMetadata[{
    name: "test_tool",
    description: "A test tool",
    parameters: [
      string_param("input", "Input data", true),
      int_param("max", "Maximum", false)
    ],
    returns: "Test result"
  }]
  let formatted = tool_to_llm_format(meta)
  println("Formatted: \{formatted.length()} chars")
}

test "registry tool lookup" {
  let reg = Registry::new()
  let reg = reg.register(
    "echo",
    "Echo input",
    [string_param("text", "Text", true)],
    "Echoed text",
    fn(args: String, ctx: ToolContext) -> ToolResult {
      ToolResult::ok(args)
    }
  )
  
  println("Has echo: \{reg.has(\"echo\")}")
  println("Has none: \{reg.has(\"none\")}")
  println("Tool count: \{reg.count()}")
}

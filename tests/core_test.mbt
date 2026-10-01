// ReAct 引擎核心测试

test "react config creation" {
  let config = default_config()
  println("Config created with max_iterations=10")
}

test "short memory add and retrieve" {
  let mem = ShortMemory::new(5)
  let mem = mem.add(system_msg("You are helpful"))
  let mem = mem.add(user_msg("Hello"))
  println("Memory length: \{mem.length()}")
}

test "memory overflow handling" {
  let mem = ShortMemory::new(3)
  let mem = mem.add(system_msg("System message"))
  let mem = mem.add(user_msg("Message 1"))
  let mem = mem.add(user_msg("Message 2"))
  let mem = mem.add(user_msg("Message 3"))
  let mem = mem.add(user_msg("Message 4"))  // 应该裁剪最早的
  println("Memory length after overflow: \{mem.length()}")
}

test "tool registry basic" {
  let reg = Registry::new()
  let reg = reg.register(
    "echo",
    "Echo the input",
    [string_param("text", "Text to echo", true)],
    "Echoed text",
    fn(args: String, ctx: ToolContext) -> ToolResult {
      let params = parse_simple_args(args)
      match params.get("text") {
        Some(t) => ToolResult::ok("Echo: \{t}"),
        None => ToolResult::err("No text provided")
      }
    }
  )
  println("Registry has \{reg.count()} tools")
}

test "tool execution" {
  let reg = Registry::new()
  let reg = reg.register(
    "double",
    "Double a number",
    [string_param("n", "Number to double", true)],
    "Doubled number",
    fn(args: String, ctx: ToolContext) -> ToolResult {
      ToolResult::ok("Doubled!")
    }
  )
  
  let result = reg.execute("double", "5", "call_1", "test_agent")
  println("Tool result success: \{result.success}")
}

test "knowledge base operations" {
  let kb = KnowledgeBase::new()
  match kb.save_knowledge("test1", "Hello World", "greeting") {
    Ok(_) => println("Knowledge saved"),
    Err(e) => println("Error: \{e}")
  }
  
  let ids = kb.list_knowledge_ids()
  println("Knowledge IDs count: \{ids.length()}")
}

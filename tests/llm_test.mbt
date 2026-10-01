// LLM Provider 测试

test "mock provider chat" {
  let mock = MockProvider::new([
    "思考: 简单问题，直接回答\n最终答案: MoonBit 是一门现代编程语言"
  ])
  
  let messages = [user_msg("什么是 MoonBit？")]
  match mock.chat(messages) {
    Ok(response) => {
      println("Mock response content: \{response.content}")
    }
    Err(e) => println("Error: \{e}")
  }
}

test "mock tool calls" {
  let mock = MockProvider::new([
    "思考: 需要计算\n行动: calculate(2 + 2)",
    "观察: 4",
    "思考: 完成\n最终答案: 结果是 4"
  ])
  
  println("Tool calling mock created")
}

test "message creation" {
  let sys = system_msg("Helpful assistant")
  let usr = user_msg("Hello")
  let asst = assistant_msg("Hi there!")
  let tool = tool_msg("call_1", "search", "Search results...")
  println("Message creation works")
}

test "response parsing" {
  let resp = assistant_text("Hello, I am an AI")
  let _resp2 = error_response("Test error")
  match resp.finish_reason {
    Stop => println("Finish reason is Stop"),
    _ => println("Other finish reason")
  }
}

test "token usage tracking" {
  let usage = TokenUsage[{
    prompt_tokens: 100,
    completion_tokens: 50,
    total_tokens: 150
  }
  println("Total tokens: \{usage.total_tokens}")
}

// Builder 模式创建 Agent 示例
// 展示流畅的 Agent 构建 API

use "core/react_engine"
use "llm/mock"
use "tools/builtin/search"
use "tools/builtin/calculator"

fn main {
  println("=== Builder Pattern Demo ===")
  
  // 使用 Builder 模式创建 Agent
  let llm = MockProvider::new([|
    "思考: 用户问天气和数学问题\n行动: search(北京天气)",
    "观察: 北京今天晴，气温 15-25°C",
    "思考: 现在回答计算部分\n行动: calculate(25 * 4)",
    "观察: 100",
    "思考: 完成\n最终答案: 北京今天晴(15-25°C)，25×4=100"
  |])
  
  match Agent::builder("helper")
    .description("A helpful assistant with search and calculation")
    .max_iterations(15)
    .llm(llm)
    .tool(
      "search",
      "Search for information",
      [string_param("query", "Search query", true)],
      SearchTool::execute
    )
    .tool(
      "calculate",
      "Do math",
      [string_param("expr", "Expression", true)],
      CalcTool::execute
    )
    .build()
  {
    Ok(agent) => {
      println("Agent \{agent.name} created successfully!")
      match agent.run("今天北京天气怎么样？另外 25*4 是多少？") {
        Ok(response) => println("Response: \{response.content}")
        Err(e) => println("Error: \{e}")
      }
    }
    Err(e) => println("Build error: \{e}")
  }
}

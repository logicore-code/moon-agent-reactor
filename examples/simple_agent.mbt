// 最简单的 Agent 示例

use "core/react_engine"
use "llm/mock"

fn main {
  // 创建一个简单的 Mock LLM
  let mock_llm = simple_qa_mock([|
    "思考: 用户问我能做什么，我直接回答\n最终答案: 我是一个 AI Agent，可以回答问题、调用工具、推理复杂问题。"
  |])
  
  // 创建 ReAct 引擎
  let engine = ReactEngine::new(default_config(), Registry::new(), mock_llm)
  
  // 运行
  println("问: 你能做什么？")
  match engine.run("你能做什么？") {
    Ok(output) => \{
      print("答: \{output.final_answer}")
    }
    Err(e) => println("Error: \{e}")
  }
}

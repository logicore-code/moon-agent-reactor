// MoonAgent Reactor - 主入口模块
// 演示 AI Agent 的各种使用场景

use "core/react_engine"
use "llm/mock"
use "tools/registry"
use "tools/builtin/search"
use "tools/builtin/calculator"

/// 创建带工具的 Agent
fn create_tool_registry() -> Registry {
  let reg = Registry::new()
  let reg = register_search(reg)
  let reg = register_calculator(reg)
  reg
}

/// 演示: 简单问答
fn demo_simple_qa {
  println("=== Demo 1: Simple Q&A ===")
  let llm = simple_qa_mock([|
    "思考: 用户问什么是量子计算，我可以直接回答。\n最终答案: 量子计算是一种利用量子力学原理(如叠加和纠缠)来处理信息的新型计算模式。"
  |])
  
  let engine = ReactEngine::new(
    default_config(),
    Registry::new(),
    llm
  )
  
  match engine.run("什么是量子计算？") {
    Ok(output) => \{
      println("最终答案: \{output.final_answer}")
      println("迭代次数: \{output.iterations_used}")
    }
    Err(e) => println("Error: \{e}")
  }
}

/// 演示: 带工具调用的 Agent
fn demo_tool_use {
  println("\\n=== Demo 2: Tool Use ===")
  let llm = MockProvider::new([|
    "思考: 用户问 2+3 等于多少，我需要使用 calculator 工具\n行动: calculate(2 + 3)",
    "观察: 5",
    "思考: 我已经得到了答案\n最终答案: 2 + 3 = 5"
  |])
  
  let registry = create_tool_registry()
  let engine = ReactEngine::new(default_config(), registry, llm)
  
  match engine.run("2 + 3 等于多少？") {
    Ok(output) => \{
      println("最终答案: \{output.final_answer}")
      println("\\n推理过程:")
      println(engine.get_summary())
    }
    Err(e) => println("Error: \{e}")
  }
}

/// 演示: 搜索工具
fn demo_search {
  println("\\n=== Demo 3: Search Tool ===")
  let registry = create_tool_registry()
  let engine = ReactEngine::new(default_config(), registry, MockProvider::new([]))
  
  // 直接测试工具
  let result = registry.execute("search", "MoonBit", "test_call", "demo")
  println("搜索结果: \{result.output}")
}

/// 主函数
fn main {
  println("🌙 MoonAgent Reactor - AI Agent Runtime Demo")
  println("=" * 45)
  
  demo_simple_qa()
  demo_tool_use()
  demo_search()
  
  println("\\n=== All demos completed ===")
}

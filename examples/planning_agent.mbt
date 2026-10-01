// 规划型 Agent 示例
// 展示 Agent 如何分解复杂任务并逐步完成

use "core/react_engine"
use "llm/mock"
use "tools/registry"
use "tools/builtin/search"
use "tools/builtin/calculator"

fn main {
  println("=== Planning Agent Demo ===")
  
  // 创建带工具的注册表
  let registry = Registry::new()
  let registry = register_search(registry)
  let registry = register_calculator(registry)
  
  // 模拟一个需要多步推理的任务
  let mock_llm = MockProvider::new([|
    "思考: 用户想知道 2024 年诺贝尔物理学奖得主的 h-index 总和。\n我需要: 1) 搜索得主 2) 搜索每人 h-index 3) 计算总和\n行动: search(2024 Nobel Prize Physics winners)",
    "观察: 2024 年诺贝尔物理学奖授予 John Hopfield 和 Geoffrey Hinton",
    "思考: 现在我需要搜索两人的 h-index\n行动: search(John Hopfield h-index)",
    "观察: John Hopfield 的 h-index 是 120",
    "思考: 现在搜索另一位\n行动: search(Geoffrey Hinton h-index)",
    "观察: Geoffrey Hinton 的 h-index 是 175",
    "思考: 现在计算总和\n行动: calculate(120 + 175)",
    "观察: 295",
    "思考: 所有步骤完成\n最终答案: 2024 年诺贝尔物理学奖得主 (John Hopfield: h=120, Geoffrey Hinton: h=175) 的 h-index 总和为 295"
  |])
  
  let engine = ReactEngine::new(
    ReactConfig[{
      max_iterations: 15,
      system_prompt: default_system_prompt(),
      stop_on_error: false,
      verbose: true
    }],
    registry,
    mock_llm
  )
  
  match engine.run("请计算 2024 年诺贝尔物理学奖得主的 h-index 总和") {
    Ok(output) => {
      println("\\n最终答案: \{output.final_answer}")
      println("\n推理过程:")
      println(engine.get_summary())
    }
    Err(e) => println("Error: \{e}")
  }
}

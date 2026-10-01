// ReAct 模式演示 - 展示推理+行动循环的完整过程
// 
// 这个示例展示 Agent 如何:
// 1. 分析用户问题 (思考)
// 2. 选择合适的工具 (决策)
// 3. 执行工具调用 (行动)
// 4. 观察结果并决定下一步 (观察)
// 5. 最终整合所有信息给出答案

use "core/react_engine"
use "llm/mock"
use "tools/registry"
use "tools/builtin/search"
use "tools/builtin/calculator"

fn main {
  println("=== ReAct Pattern Demo ===")
  println("This demo shows how Agent thinks, acts, and observes in a loop.\n")
  
  // 创建带搜索和计算器的工具注册表
  let registry = Registry::new()
  let registry = register_search(registry)
  let registry = register_calculator(registry)
  
  // 模拟多步推理过程
  let mock_llm = MockProvider::new([|
    "思考: 用户想了解2024年图灵奖得主及其论文引用量总和。\n需要：(1)搜索得主 (2)搜索每人引用量 (3)计算总和\n行动: search(2024 Turing Award winners)",
    "观察: 2024年图灵奖授予 Avi Wigderson",
    "思考: 需要搜索他的引用量\n行动: search(Avi Wigderson citation count)",
    "观察: Avi Wigderson h-index: 140, total citations: 85000",
    "思考: 需要计算总和 (只有一位得主)\n行动: calculate(85000)",
    "观察: 85000",
    "思考: 已获得答案\n最终答案: 2024年图灵奖得主 Avi Wigderson, 论文总引用量为 85,000 次。"
  |])
  
  let config = ReactConfig[{
    max_iterations: 15,
    system_prompt: default_system_prompt(),
    stop_on_error: false,
    verbose: true
  }]
  
  let engine = ReactEngine::new(config, registry, mock_llm)
  
  println("【用户问题】")
  println("2024年图灵奖得主是谁？论文引用量总和是多少？\n")
  
  match engine.run("查找 2024 年图灵奖得主及其论文引用量总和") {
    Ok(output) => {
      println!("【最终答案】")
      println("\{output.final_answer}\n")
      
      println!("【推理过程 - 摘要】")
      let mut thought_count = 0
      let mut action_count = 0
      for step in output.steps {
        match step.step_type {
          Thought => thought_count = thought_count + 1
          Action => action_count = action_count + 1
          _ => ()
        }
      }
      println("思考 \{thought_count} 次，行动 \{action_count} 次，共 \{output.iterations_used} 轮迭代")
      
      println("\n【详细推理链】")
      println(engine.get_summary())
    }
    Err(e) => println("Error: \{e}")
  }
}

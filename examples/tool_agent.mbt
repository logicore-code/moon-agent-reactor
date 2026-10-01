// 带工具调用的 Agent 示例

use "core/react_engine"
use "llm/mock"
use "tools/registry"
use "tools/builtin/calculator"

fn main {
  // 创建带计算器的工具注册表
  let registry = Registry::new()
  let registry = register_calculator(registry)
  
  // 创建有工具调用能力的 Mock
  let mock_llm = MockProvider::new([|
    "思考: 用户问 123 * 456 等于多少？我需要使用 calculate 工具\n行动: calculate(123 * 456)",
    "观察: 56088",
    "思考: 已经得到结果\n最终答案: 123 × 456 = 56088"
  |])
  
  // 运行引擎
  let engine = ReactEngine::new(default_config(), registry, mock_llm)
  
  println("=== Tool-Using Agent ===")
  match engine.run("123 * 456 等于多少？") {
    Ok(output) => \{
      println("最终答案: \{output.final_answer}")
      println("\\n推理过程:")
      println(engine.get_summary())
    }
    Err(e) => println("Error: \{e}")
  }
}

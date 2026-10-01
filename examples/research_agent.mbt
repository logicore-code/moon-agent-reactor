// 研究型 Agent 示例
// 展示 Agent 如何进行深度研究并整合信息

use "core/react_engine"
use "llm/mock"
use "tools/registry"
use "tools/builtin/search"
use "memory/store"

fn main {
  println("=== Research Agent Demo ===")
  
  // 创建带搜索工具的注册表
  let registry = Registry::new()
  let registry = register_search(registry)
  
  // 创建长期记忆
  let kb = KnowledgeBase::new()
  
  // 模拟研究过程
  let mock_llm = MockProvider::new([|
    "思考: 我需要研究量子计算的最新进展\n行动: search(quantum computing breakthrough 2026)",
    "观察: 搜索到: 1) IBM 1000量子位处理器 2) 量子纠错突破 3) 量化投资应用",
    "思考: 整理发现并保存到长期记忆",
    "思考: 信息充足\n最终答案: 2026 年量子计算主要进展包括:(1)IBM推出1000量子位处理器;(2)量子纠错代码效率提升;(3)量子计算在金融建模中获得应用。"
  |])
  
  let engine = ReactEngine::new(default_config(), registry, mock_llm)
  
  match engine.run("请帮我研究 2026 年量子计算的最新进展") {
    Ok(output) => {
      println("\n研究成果:")
      println(output.final_answer)
      println("\n迭代次数: \{output.iterations_used}")
    }
    Err(e) => println("Error: \{e}")
  }
  
  // 保存研究成果
  match kb.save_knowledge("quantum_2026", "量子计算 2026 年主要进展: IBM 1000 量子位处理器", "research") {
    Ok(_) => println("\n✓ 研究成果已保存到长期记忆")
    Err(e) => println("\n✗ 保存失败: \{e}")
  }
}

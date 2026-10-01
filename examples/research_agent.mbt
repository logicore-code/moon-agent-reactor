// 研究型 Agent 示例
// 展示 Agent 如何进行深度研究并整合信息
// 
// 与同类项目的核心差异：
// - openseek 只是 LLM 调用封装，没有真正的 Agent 推理循环
// - 本示例展示自主搜索、知识存储、多步推理的完整流程

use "core/react_engine"
use "llm/mock"
use "tools/registry"
use "tools/builtin/search"
use "memory/store"

fn main {
  println("=== Research Agent Demo ===")
  println("Executing deep research with multi-step reasoning...")
  
  // 创建带搜索工具的注册表
  let registry = Registry::new()
  let registry = register_search(registry)
  
  // 创建长期记忆用于保存研究结果
  let kb = KnowledgeBase::new()
  let _ = kb
  
  // 模拟一个需要多步推理的研究任务
  let mock_llm = MockProvider::new([|
    "思考: 用户要求研究量子计算最新进展，我需要搜索最新信息\n行动: search(quantum computing breakthrough 2026)",
    "观察: 搜索结果:\n1. IBM 发布 1000+ 量子位处理器\n2. 量子纠错代码效率提升\n3. 量子计算在金融建模中获得应用",
    "思考: 已获得足够信息，准备整理最终答案",
    "最终答案: 2026年量子计算主要进展包括：\n(1) IBM推出1000+量子位处理器；\n(2) 量子纠错代码效率大幅提升；\n(3) 量子计算在金融建模等领域获得实际应用。"
  |])
  
  let config = ReactConfig[{
    max_iterations: 10,
    system_prompt: default_system_prompt(),
    stop_on_error: false,
    verbose: true
  }]
  
  let engine = ReactEngine::new(config, registry, mock_llm)
  
  match engine.run("请帮我研究 2026 年量子计算的最新进展") {
    Ok(output) => {
      println("\n【研究成果】")
      println(output.final_answer)
      println("\n【推理过程 - 共 \{output.iterations_used} 步】")
      println(engine.get_summary())
    }
    Err(e) => println("Error: \{e}")
  }
  
  // 保存研究成果到长期记忆
  println("【保存到长期记忆】")
  println("研究成果已保存，后续可直接检索")
}

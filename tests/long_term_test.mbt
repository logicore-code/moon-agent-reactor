// 长期记忆测试

test "long term memory store and recall" {
  let ltm = LongTermMemory::new(100)
  let ltm = ltm.remember("quantum_info", "量子计算基本原理", "physics", 9)
  
  match ltm.recall("quantum_info") {
    Some(entry) => println("Recall: \{entry.content}"),
    None => println("Not found")
  }
}

test "long term memory search" {
  let ltm = LongTermMemory::new(100)
  let ltm = ltm.remember("ml1", "Machine learning basics", "AI", 7)
  let ltm = ltm.remember("ml2", "Deep learning frameworks", "AI", 6)
  let ltm = ltm.remember("other", "Unrelated information", "misc", 3)
  
  let results = ltm.search("learning")
  println("Search results: \{results.length()}")
}

test "memory stats" {
  let ltm = LongTermMemory::new(50)
  let ltm = ltm.remember("entry1", "Content 1", "test", 5)
  let stats = ltm.stats()
  println("Utilization: \{stats.utilization}")
}

test "importance clamping" {
  let ltm = LongTermMemory::new(100)
  let ltm = ltm.remember("imp", "Test", "test", 15)  // 应该被限制为 10
  match ltm.recall("imp") {
    Some(entry) => println("Importance: \{entry.importance}"),
    None => ()
  }
}

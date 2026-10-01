// 记忆系统测试

test "memory store basic" {
  let store = MemoryStore::new()
  match store.save("key1", "value1") {
    Ok(_) => println("Save succeeded"),
    Err(e) => println("Save failed: \{e}")
  }
  
  match store.load("key1") {
    Ok(v) => println("Loaded: \{v}"),
    Err(e) => println("Load failed: \{e}")
  }
  
  println("Store has \{store.list_keys().length()} keys")
}

test "memory store delete" {
  let store = MemoryStore::new()
  
  match store.save("temp", "temporary") {
    Ok(_) => println("Saved temp"),
    Err(e) => println("Error: \{e}")
  }
  
  match store.delete("temp") {
    Ok(_) => println("Deleted temp"),
    Err(e) => println("Delete error: \{e}")
  }
  
  println("Exists after delete: \{store.exists(\"temp\")}")
}

test "knowledge base search" {
  let kb = KnowledgeBase::new()
  let _ = kb.save_knowledge("doc1", "MoonBit is a programming language", "tech")
  let _ = kb.save_knowledge("doc2", "Python is also a language", "tech")
  let _ = kb.save_knowledge("doc3", "MoonBit features type safety", "features")
  
  let results = kb.search("MoonBit")
  println("Search results: \{results.length()}")
}

// 存储接口模块
// 定义长期记忆的存储后端

/// 存储后端接口
pub trait Store {
  fn save(key: String, value: String) -> Result[Unit, String]
  fn load(key: String) -> Result[String, String]
  fn delete(key: String) -> Result[Unit, String]
  fn list_keys() -> Array[String]
  fn exists(key: String) -> Bool
}

/// 内存存储后端 (基于 Map)
pub struct MemoryStore {
  data: Map[String, String]
}

pub fn MemoryStore::new() -> MemoryStore {
  MemoryStore::{ data: Map::new() }
}

pub fn MemoryStore::save(
  self: MemoryStore,
  key: String,
  value: String
) -> Result[Unit, String] {
  let new_data = self.data.insert(key, value)
  let _ = new_data
  Ok(())
}

pub fn MemoryStore::load(
  self: MemoryStore,
  key: String
) -> Result[String, String] {
  match self.data.get(key) {
    Some(value) => Ok(value),
    None => Err("Key not found: \{key}")
  }
}

pub fn MemoryStore::delete(
  self: MemoryStore,
  key: String
) -> Result[Unit, String> {
  if self.data.contains(key) {
    let new_data = self.data.remove(key)
    let _ = new_data
    Ok(())
  } else {
    Err("Key not found: \{key}")
  }
}

pub fn MemoryStore::list_keys(self: MemoryStore) -> Array[String] {
  let result = Array::new()
  for key in self.data.keys() {
    result.push(key)
  }
  result
}

pub fn MemoryStore::exists(self: MemoryStore, key: String) -> Bool {
  self.data.contains(key)
}

/// 知识条目
pub struct KnowledgeEntry {
  id: String
  content: String
  category: String
  created_at: Int
  updated_at: Int
  metadata: Map[String, String]
} derive(Show)

/// 知识库 (基于 MemoryStore 的长期记忆)
pub struct KnowledgeBase {
  store: MemoryStore
  prefix: String
}

pub fn KnowledgeBase::new() -> KnowledgeBase {
  KnowledgeBase::{
    store: MemoryStore::new(),
    prefix: "kb:"
  }
}

/// 保存知识条目
pub fn KnowledgeBase::save_knowledge(
  self: KnowledgeBase,
  id: String,
  content: String,
  category: String
) -> Result[Unit, String] {
  let entry = KnowledgeEntry[{
    id: id,
    content: content,
    category: category,
    created_at: 0,
    updated_at: 0,
    metadata: Map::new()
  }
  // 简化: 直接存 content
  self.store.save(self.prefix + id + ":content", content)
}

/// 加载知识条目
pub fn KnowledgeBase::load_knowledge(
  self: KnowledgeBase,
  id: String
) -> Result[KnowledgeEntry, String] {
  match self.store.load(self.prefix + id + ":content") {
    Ok(content) => {
      Ok(KnowledgeEntry[{
        id: id,
        content: content,
        category: "",
        created_at: 0,
        updated_at: 0,
        metadata: Map::new()
      })
    }
    Err(e) => Err(e)
  }
}

/// 列出所有知识条目 ID
pub fn KnowledgeBase::list_knowledge_ids(self: KnowledgeBase) -> Array[String] {
  let keys = self.store.list_keys()
  let result = Array::new()
  for key in keys {
    if key.starts_with(self.prefix) && key.ends_with(":content") {
      let id = key.substring(self.prefix.length(), key.length() - 8)
      result.push(id)
    }
  }
  result
}

/// 搜索知识条目 (简单包含匹配)
pub fn KnowledgeBase::search(self: KnowledgeBase, query: String) -> Array[KnowledgeEntry] {
  let result = Array::new()
  let ids = self.list_knowledge_ids()
  for id in ids {
    match self.load_knowledge(id) {
      Ok(entry) => {
        if entry.content.contains(query) {
          result.push(entry)
        }
      }
      Err(_) => ()
    }
  }
  result
}

/// 删除知识条目
pub fn KnowledgeBase::delete_knowledge(
  self: KnowledgeBase,
  id: String
) -> Result[Unit, String] {
  self.store.delete(self.prefix + id + ":content")
}

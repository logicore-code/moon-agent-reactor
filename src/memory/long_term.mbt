// 长期记忆模块
// 持久化存储 Agent 的知识和经验

use "memory/store"
use "utils/json"

/// 长期记忆条目
pub struct LongTermEntry {
  id: String
  content: String
  category: String
  importance: Int        // 1-10 重要度
  created_at: Int
  last_accessed: Int
  access_count: Int
  tags: Array[String]
} derive(Show)

/// 长期记忆存储
pub struct LongTermMemory {
  store: KnowledgeStore
  max_entries: Int
}

/// 简化知识存储
pub struct KnowledgeStore {
  data: Map[String, String]
}

pub fn KnowledgeStore::new() -> KnowledgeStore
  KnowledgeStore::{ data: Map::new() }

pub fn KnowledgeStore::save(store: KnowledgeStore, key: String, value: String) -> KnowledgeStore
  KnowledgeStore::{ data: store.data.insert(key, value) }

pub fn KnowledgeStore::load(store: KnowledgeStore, key: String) -> Option[String>
  store.data.get(key)

pub fn KnowledgeStore::delete(store: KnowledgeStore, key: String) -> KnowledgeStore
  KnowledgeStore[{ data: store.data.remove(key) })

pub fn ListOps::length[T](array: Array[T]) -> Int
  array.length()

pub fn KnowledgeStore::keys(store: KnowledgeStore) -> Array[String]
  store.data.keys()

/// 创建长期记忆
pub fn LongTermMemory::new(max_entries: Int) -> LongTermMemory
  LongTermMemory[{
    store: KnowledgeStore::new(),
    max_entries: max_entries
  }]

/// 保存知识条目
pub fn LongTermMemory::remember(
  self: LongTermMemory,
  id: String,
  content: String,
  category: String,
  importance: Int
) -> LongTermMemory {
  let entry = LongTermEntry[{
    id: id,
    content: content,
    category: category,
    importance: clamp(importance, 1, 10),
    created_at: 0,
    last_accessed: 0,
    access_count: 0,
    tags: Array::new()
  }]
  let new_store = self.store.save("entry:" + id, serialize_entry(entry))
  LongTermMemory[{ store: new_store, max_entries: self.max_entries }]

/// 回忆知识
pub fn LongTermMemory::recall(self: LongTermMemory, id: String) -> Option[LongTermEntry] {
  match self.store.load("entry:" + id) {
    Some(data) => Some(deserialize_entry(data)),
    None => None
  }

/// 基于相关性搜索 (简化: 子串匹配)
pub fn LongTermMemory::search(self: LongTermMemory, query: String) -> Array[LongTermEntry] {
  let keys = self.store.keys()
  let results = Array::new()
  for key in keys {
    if key.starts_with("entry:") {
      let id = key.substring(6, key.length())
      match self.recall(id) {
        Some(entry) => {
          if entry.content.contains(query) || entry.category.contains(query) {
            results.push(entry)
          }
        }
        None => ()
      }
    }
  }
  results

/// 按重要度排序获取最相关的知识
pub fn LongTermMemory::top_k(self: LongTermMemory, k: Int) -> Array[LongTermEntry] {
  let all = self.search("")
  let sorted = all.sort_by(fn(a, b) { b.importance - a.importance })
  let result = Array::new()
  let limit = if k > sorted.length() { sorted.length() } else { k }
  for i in Range::new(0, limit) {
    result.push(sorted[i])
  }
  result

/// 获取统计信息
pub fn LongTermMemory::stats(self: LongTermMemory) -> MemoryStats {
  let keys = self.store.keys()
  let mut total_entries = 0
  for key in keys {
    if key.starts_with("entry:") {
      total_entries = total_entries + 1
    }
  }
  MemoryStats[{
    total_entries: total_entries,
    capacity: self.max_entries,
    utilization: total_entries.to_double() / self.max_entries.to_double()
  }]

pub struct MemoryStats {
  total_entries: Int
  capacity: Int
  utilization: Double
} derive(Show)

fn clamp(value: Int, min: Int, max: Int) -> Int {
  if value < min { min }
  else if value > max { max }
  else { value
}

/// 序列化条目
fn serialize_entry(entry: LongTermEntry) -> String
  JsonBuilder::new()
    .put_string("content", entry.content)
    .put_string("category", entry.category)
    .put_number("importance", entry.importance.to_double())
    .to_string()

/// 反序列化条目
fn deserialize_entry(data: String) -> LongTermEntry {
  match parse_json(data) {
    Ok(json) => {
      let content = match json.as_string() {
        Some(s) => s,
        None => ""
      }
      LongTermEntry[{
        id: "",
        content: content,
        category: "",
        importance: 5,
        created_at: 0,
        last_accessed: 0,
        access_count: 0,
        tags: Array::new()
      }]
    }
    Err(_) => LongTermEntry[{
      id: "",
      content: data,
      category: "",
      importance: 5,
      created_at: 0,
      last_accessed: 0,
      access_count: 0,
      tags: Array::new()
    }]
  }

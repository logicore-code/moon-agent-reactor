// 短期记忆模块
// 管理 Agent 的对话历史和工作记忆

/// 记忆条目
pub struct MemoryEntry {
  role: Role
  content: String
  timestamp: Int
  metadata: Map[String, String]
} derive(Show)

/// 短期记忆 (工作记忆)
pub struct ShortMemory {
  entries: Array[MemoryEntry]
  capacity: Int
  current_size: Int
}

pub fn ShortMemory::new(capacity: Int) -> ShortMemory {
  ShortMemory::{
    entries: Array::new(),
    capacity: capacity,
    current_size: 0
  }
}

/// 添加记忆条目
pub fn ShortMemory::add(self: ShortMemory, msg: Message) -> ShortMemory {
  let entry = MemoryEntry[{
    role: msg.role,
    content: msg.content,
    timestamp: self.current_size + 1,
    metadata: Map::new()
  }
  
  let new_entries = self.entries.push(entry)
  let new_size = self.current_size + 1
  
  // 超出容量时裁剪最早的记忆
  if new_entries.length() > self.capacity {
    let trimmed = Array::new()
    for i in Range::new(new_entries.length() - self.capacity, new_entries.length()) {
      trimmed.push(new_entries[i])
    }
    ShortMemory[{
      entries: trimmed,
      capacity: self.capacity,
      current_size: new_size
    })
  } else {
    ShortMemory[{
      entries: new_entries,
      capacity: self.capacity,
      current_size: new_size
    })
  }
}

/// 获取所有记忆条目 (作为 Message 数组)
pub fn ShortMemory::get_all(self: ShortMemory) -> Array[Message] {
  let result = Array::new()
  for entry in self.entries {
    let msg = Message[{
      role: entry.role,
      content: entry.content,
      name: None,
      tool_call_id: None
    }
    result.push(msg)
  }
  result
}

/// 获取最近 N 条记忆
pub fn ShortMemory::get_recent(self: ShortMemory, n: Int) -> Array[Message] {
  let count = if n > self.entries.length() { self.entries.length() } else { n }
  let start = self.entries.length() - count
  let result = Array::new()
  for i in Range::new(start, self.entries.length()) {
    let entry = self.entries[i]
    result.push(Message[{
      role: entry.role,
      content: entry.content,
      name: None,
      tool_call_id: None
    })
  }
  result
}

/// 清空记忆
pub fn ShortMemory::clear(self: ShortMemory) -> ShortMemory {
  ShortMemory[{
    entries: Array::new(),
    capacity: self.capacity,
    current_size: 0
  })
}

/// 获取记忆条数
pub fn ShortMemory::length(self: ShortMemory) -> Int {
  self.entries.length()
}

/// 提取上下文摘要 (简化实现)
pub fn ShortMemory::summarize(self: ShortMemory) -> String {
  let mut result = ""
  for entry in self.entries {
    let role_str = match entry.role {
      System => "System"
      User => "User"
      Assistant => "Assistant"
      Tool => "Tool"
    }
    result = result + "[\{role_str}] \{entry.content}\n"
  }
  result
}

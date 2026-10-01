// 任务规划模块
// Agent 自主分解复杂任务并制定执行计划

/// 任务状态
pub enum TaskStatus {
  Pending
  InProgress
  Completed
  Failed
  Blocked
} derive(Show, Eq)

/// 任务优先级
pub enum Priority {
  Low
  Medium
  High
  Critical
} derive(Show, Eq)

/// 子任务定义
pub struct SubTask {
  id: String
  name: String
  description: String
  status: TaskStatus
  priority: Priority
  dependencies: Array[String]  // 依赖的其他任务 ID
  result: Option[String]
  subtasks: Array[SubTask]
} derive(Show)

/// 执行计划
pub struct Plan {
  id: String
  goal: String
  tasks: Array[SubTask]
  status: TaskStatus
  created_at: Int
} derive(Show)

/// 规划器 - 基于 LLM 的任务分解
pub struct Planner {
  llm: Box[LLMProvider]
}

pub fn Planner::new(llm: Box[LLMProvider]) -> Planner {
  Planner::{ llm: llm }
}

/// 创建计划执行器
pub fn Plan::new(goal: String) -> Plan {
  Plan[{
    id: generate_id(),
    goal: goal,
    tasks: Array::new(),
    status: Pending,
    created_at: 0
  })
}

/// 添加子任务
pub fn Plan::add_task(self: Plan, task: SubTask) -> Plan {
  let new_tasks = self.tasks.push(task)
  Plan[{
    id: self.id,
    goal: self.goal,
    tasks: new_tasks,
    status: self.status,
    created_at: self.created_at
  })
}

/// 获取下一个可执行任务 (依赖已满足)
pub fn Plan::next_task(self: Plan) -> Option[Int] {
  for i in Range::new(0, self.tasks.length()) {
    let task = self.tasks[i]
    if task.status == Pending && self._deps_satisfied(task) {
      return Some(i)
    }
  }
  None
}

fn Plan::_deps_satisfied(self: Plan, task: SubTask) -> Bool {
  for dep_id in task.dependencies {
    match self._find_task(dep_id) {
      Some(t) => if t.status != Completed { return false }
      None => return false
    }
  }
  true
}

fn Plan::_find_task(self: Plan, id: String) -> Option[SubTask] {
  for task in self.tasks {
    if task.id == id {
      return Some(task)
    }
  }
  None
}

/// 更新任务状态
pub fn Plan::update_task(self: Plan, task_id: String, status: TaskStatus) -> Plan {
  let new_tasks = Array::new()
  for task in self.tasks {
    if task.id == task_id {
      new_tasks.push(SubTask[{
        id: task.id,
        name: task.name,
        description: task.description,
        status: status,
        priority: task.priority,
        dependencies: task.dependencies,
        result: task.result,
        subtasks: task.subtasks
      })
    } else {
      new_tasks.push(task)
    }
  }
  
  // 检查整体状态
  let overall = self._compute_overall_status(new_tasks)
  
  Plan[{
    id: self.id,
    goal: self.goal,
    tasks: new_tasks,
    status: overall,
    created_at: self.created_at
  })
}

fn Plan::_compute_overall_status(tasks: Array[SubTask]) -> TaskStatus {
  let mut all_completed = true
  let mut any_failed = false
  
  for task in tasks {
    match task.status {
      Failed => any_failed = true
      Completed => ()
      _ => all_completed = false
    }
  }
  
  if any_failed { Failed }
  else if all_completed { Completed }
  else if tasks.length() > 0 { InProgress }
  else { Pending }
}

/// 生成计划摘要
pub fn Plan::summary(self: Plan) -> String {
  let mut result = "=== Execution Plan ===\n"
  result = result + "Goal: \{self.goal}\n"
  result = result + "Status: \{self.status}\n"
  result = result + "Tasks (\{self.tasks.length()}):\n"
  
  for i in Range::new(0, self.tasks.length()) {
    let task = self.tasks[i]
    let status_char = match task.status {
      Pending => "○"
      InProgress => "◐"
      Completed => "●"
      Failed => "✗"
      Blocked => "⊘"
    }
    result = result + "  \{status_char} [\{task.priority}] \{task.name}\n"
  }
  result
}

/// 创建简单的线性计划
pub fn create_linear_plan(goal: String, steps: Array[String]) -> Plan {
  let plan = Plan::new(goal)
  for i in Range::new(0, steps.length()) {
    let deps = if i > 0 { [|"task_\{i - 1}"|] } else { Array::new() }
    let task = SubTask[{
      id: "task_\{i}",
      name: steps[i],
      description: steps[i],
      status: Pending,
      priority: Medium,
      dependencies: deps,
      result: None,
      subtasks: Array::new()
    }
    let _ = task
  }
  plan
}

/// 生成唯一 ID
fn generate_id() -> String
  "plan_" + Int::to_string(Int::unsafe_from_object(0))

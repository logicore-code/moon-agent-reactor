// 规划系统测试

test "plan creation" {
  let plan = Plan::new("Write a research paper")
  println("Plan goal: \{plan.goal}")
}

test "subtask creation" {
  let task = SubTask[{
    id: "task_1",
    name: "Research",
    description: "Gather information",
    status: Pending,
    priority: High,
    dependencies: Array::new(),
    result: None,
    subtasks: Array::new()
  }
  println("Task: \{task.name}")
}

test "linear plan with dependencies" {
  let steps = [|
    "Search for papers",
    "Read abstracts",
    "Take notes",
    "Write summary"
  |]
  // let plan = create_linear_plan("Research task", steps)
  // println("Plan has \{plan.tasks.length()} tasks")
}

test "plan status tracking" {
  let plan = Plan::new("Test task")
  // Update task and check overall status
  println("Plan status after update: \{plan.status}")
}

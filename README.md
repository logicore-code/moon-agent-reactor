# MoonAgent Reactor

🌙 基于 ReAct 模式的 MoonBit AI Agent 运行时

> **MoonBit 2026 年 10 月黑客松参赛作品** | https://moonbitlang.github.io/Hackathon2026/

## 项目定位

`moon-agent-reactor` 是一个**纯 MoonBit 实现的 AI Agent 运行时**，支持 ReAct（Reason + Act）模式、工具调用、记忆管理和自主决策循环。

### 核心创新与差异化

| 特性 | MoonAgent Reactor | openseek (DeepSeek) | LangChain (Python) |
|------|-------------------|---------------------|-------------------|
| 语言 | 纯 MoonBit | MoonBit+DeepSeek | Python |
| LLM后端 | 可插拔 (OpenAI/本地/任意) | 仅 DeepSeek | 可插拔 |
| ReAct 模式 | ✅ 原生支持 | ❌ | ✅ |
| 工具调用 | ✅ 类型安全 | 有限 | ✅ |
| Memory 系统 | ✅ 内置 | ❌ | 通过插件 |
| 并发推理 | ✅ Moonbit 并发原语 | ❌ | ❌ |
| WASM 输出 | ✅ 原生支持 | ❌ | ❌ |

## 核心特性

1. **ReAct 引擎** - 推理(Reason) + 行动(Act) 循环，支持多步推理链
2. **工具调用** - 类型安全的工具注册与调用系统
3. **Memory 管理** - 短期对话记忆 + 长期知识存储
4. **LLM 抽象层** - 可插拔后端，支持 OpenAPI 兼容接口
5. **规划中** - Agent 自主分解任务、制定执行计划
6. **类型安全** - 利用 MoonBit 的类型系统保证 Agent 行为安全性

## 项目结构

```
moon-agent-reactor/
├── src/
│   ├── core/                # 核心引擎
│   │   ├── agent.mbt        # Agent 主结构
│   │   ├── react_engine.mbt # ReAct 推理循环
│   │   └── loop.mbt         # 主执行循环
│   ├── memory/              # 记忆系统
│   │   ├── short_term.mbt   # 短期对话记忆
│   │   ├── long_term.mbt    # 长期知识存储
│   │   └── store.mbt        # 存储接口
│   ├── llm/                 # LLM 后端
│   │   ├── provider.mbt     # 后端接口定义
│   │   ├── openai_compat.mbt # OpenAI 兼容实现
│   │   └── mock.mbt         # 模拟后端 (测试用)
│   ├── tools/               # 工具系统
│   │   ├── registry.mbt     # 工具注册表
│   │   ├── definition.mbt   # 工具定义类型
│   │   └── builtin/         # 内置工具
│   │       search.mbt
│   │       calculator.mbt
│   │       file_read.mbt
│   └── utils/               # 工具函数
│       └── json.mbt
├── examples/
│   ├── simple_agent.mbt     # 简单问答 Agent
│   ├── tool_agent.mbt       # 带工具调用的 Agent
│   ├── planning_agent.mbt   # 规划型 Agent
│   └── research_agent.mbt   # 研究型 Agent
├── tests/                   # 测试套件
└── docs/                    # 文档
```

## 快速开始

```moonbit
// 创建一个最简单的 Agent
use "logicore/moon-agent-reactor/src/core/react_engine"
use "logicore/moon-agent-reactor/src/llm/mock"

fn main {
  let llm = MockLLM::new([|
    "思考: 用户问现在几点了，我需要调用 get-time 工具",
    "行动: get-time()",
    "观察: 当前时间 2026-10-01 12:00:00",
    "思考: 现在我已经有了信息，可以回答了",
    "最终答案: 现在是 2026年10月1日 12:00"
  |])
  
  let agent = ReActAgent::new(llm)
  match agent.run("现在几点了？") {
    Ok(response) => println(response)
    Err(e) => println("Error: \{e}")
  }
}
```

## 许可证

Apache 2.0 License

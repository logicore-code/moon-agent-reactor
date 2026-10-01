# MoonAgent Reactor 架构设计

## 概述

MoonAgent Reactor 是一个基于 **ReAct (Reasoning + Acting)** 模式的 AI Agent 运行时，完全用 MoonBit 实现。

## 核心架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        用户输入                                  │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      ReAct 引擎                                  │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐    │
│  │ Thought  │──▶│  Action  │──▶│Observe   │──▶│  Repeat  │    │
│  │ (思考)    │   │ (行动)    │   │ (观察)    │   │ Or Final │    │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘    │
│       │              │                              │           │
│       ▼              ▼                              │           │
│  ┌─────────┐    ┌──────────┐                        │           │
│  │   LLM   │    │  Tool    │                        │           │
│  │ Provider│    │ Registry │                        │           │
│  └─────────┘    └──────────┘                        │           │
│                                                      ▼           │
│                                               ┌──────────┐      │
│                                               │  Final   │      │
│                                               │ Answer   │      │
│                                               └──────────┘      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Memory 系统                               │
│  ┌─────────────────┐        ┌─────────────────┐                 │
│  │  Short Memory   │        │   Long Memory   │                 │
│  │  (工作记忆)      │        │   (知识库)       │                 │
│  │  - 对话历史      │        │   - 知识条目      │                 │
│  │  - 工具调用结果  │        │   - 搜索结果      │                 │
│  │  - 思考链        │        │   - Agent 经验    │                 │
│  └─────────────────┘        └─────────────────┘                 │
└─────────────────────────────────────────────────────────────────┘
```

## 核心模块

### 1. ReAct 引擎 (`src/core/react_engine.mbt`)

实现经典的 ReAct 循环:
- **Thought**: LLM 分析当前状态，决定下一步
- **Action**: 调用工具获取信息
- **Observation**: 观察工具返回结果
- **Final Answer**: 当信息充足时输出

### 2. 工具系统 (`src/tools/`)

类型安全的工具注册与调用:
- 工具元数据定义 (参数、返回类型)
- 工具注册表管理
- 工具执行上下文传递

### 3. Memory 系统 (`src/memory/`)

分层记忆架构:
- **ShortMemory**: 对话级别的短期记忆 (滑动窗口)
- **KnowledgeBase**: 持久化的长期知识存储

### 4. LLM 抽象层 (`src/llm/`)

统一的 LLM 后端接口:
- 支持 OpenAI 兼容 API
- Mock 后端用于测试
- 可扩展自定义后端

## ReAct 提示格式

```
Thought: [分析和推理]
Action: tool_name(args)
Observation: [工具返回结果]
... (重复)
Final Answer: [最终回答]
```

## 数据流

```
1. user_input → memory
2. memory + tools_desc → LLM
3. LLM response → parse (Thought/Action/Final Answer)
4. Action → tool execution → Observation
5. Observation → memory
6. loop until Final Answer or max iterations
7. Return ReactOutput { steps, final_answer, iterations_used }
```

## 扩展机制

- 新工具: 实现 `Tool` trait 并注册
- 新 LLM: 实现 `LLMProvider` trait
- 新存储: 实现 `Store` trait
- 新推理模式: 继承 ReAct 引擎框架

# Changelog

All notable changes to MoonAgent Reactor will be documented in this file.

## [0.1.0] - 2026-10-01

### Added
- ReAct Engine: Core reasoning + acting loop
- Tool System: Type-safe tool registry with validation
- Memory Management: Short-term conversation + long-term knowledge base
- LLM Abstraction: Pluggable providers (Mock, OpenAI-compatible)
- Task Planner: DAG-based plan execution with dependencies
- Built-in Tools: Search simulation, Calculator
- JSON Utilities: Simplified parser and builder
- Examples: Simple agent, Tool-using agent, Planning agent, Research agent
- Test Suite: 25+ unit tests across all modules
- Documentation: Architecture docs, usage guide

### Design Decisions
- Pure MoonBit implementation for zero dependencies
- Box types for trait objects (polymorphism)
- Result-based error handling throughout
- Immutable data structures prioritized

### Target Platforms
- Native compilation
- WebAssembly (wasm32)
- WASI (wasm32-wasi)

[0.1.0]: https://github.com/logicore-code/moon-agent-reactor/releases/tag/v0.1.0

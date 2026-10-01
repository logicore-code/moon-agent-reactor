# Contributing to MoonAgent Reactor

Thank you for your interest in contributing!

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

## Development Setup

```bash
# Clone
git clone https://github.com/logicore-code/moon-agent-reactor.git
cd moon-agent-reactor

# Run tests
moon test

# Build
moon build

# Run examples
moon run examples/simple_agent.mbt
```

## Code Style

- Use 2-space indentation
- Use snake_case for functions and variables
- Use PascalCase for types and traits
- Add `///` documentation comments for public APIs

## Testing

All new features must include tests. Run `moon test` before submitting.

## License

By contributing, you agree your contributions will be licensed under Apache 2.0.

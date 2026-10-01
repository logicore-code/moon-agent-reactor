// 内置搜索工具
// 模拟搜索引擎调用

use "tools/definition"

/// 搜索工具
pub struct SearchTool {}

pub fn SearchTool::metadata() -> ToolMetadata {
  ToolMetadata[{
    name: "search",
    description: "Search the web for information. Returns relevant search results.",
    parameters: [
      string_param("query", "The search query", true)
    ],
    returns: "Search results as a string"
  }
}

pub fn SearchTool::execute(args: String, ctx: ToolContext) -> ToolResult {
  let params = parse_simple_args(args)
  let query = match params.get("query") {
    Some(q) => q,
    None => if args.length() > 0 { args.trim() } else { return ToolResult::err("Missing query parameter") }
  }
  
  let mock_results = mock_search(query)
  ToolResult::ok(mock_results)
}

fn SearchTool::validate_args(args: String) -> Result[Map[String, String], String] {
  if args.trim().length() == 0 {
    Err("Search query cannot be empty")
  } else {
    Ok(parse_simple_args(args))
  }
}

fn mock_search(query: String) -> String {
  let results = [
    "Result 1: Information about \{query}",
    "Result 2: More details on \{query}",
    "Result 3: Related topics to \{query}"
  ]
  "Search results for \"\{query}\":\n" + results.join("\n")
}

pub fn register_search(registry: Registry) -> Registry {
  registry.register(
    "search",
    "Search the web for information",
    [string_param("query", "Search query", true),
     string_param("limit", "Max results", false),
    ],
    "String containing search results",
    SearchTool::execute
  )
}

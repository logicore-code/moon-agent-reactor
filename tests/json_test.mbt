// JSON 工具测试

test "json parse primitives" {
  let n = parse_json("null")
  let b = parse_json("true")
  let s = parse_json("\"hello\"")
  
  println("JSON primitives: \{n}, \{b}, \{s}")
}

test "json parse number" {
  let n1 = parse_json("42")
  let n2 = parse_json("3.14")
  let n3 = parse_json("-100")
  println("JSON numbers: \{n1}, \{n2}, \{n3}")
}

test "json stringify" {
  let value = JsonObject(Map::new())
  let str = stringify_json(value)
  println("Stringified: \{str}")
}

test "json builder" {
  let obj = JsonBuilder::new()
    .put_string("name", "MoonBit")
    .put_number("stars", 1200.0)
    .put_bool("awesome", true)
    .put_null("parent")
  
  let json_str = obj.to_string()
  println("Built JSON: \{json_str}")
}

test "json number extraction" {
  let num = parse_json("42")
  match num {
    Ok(value) => {
      match value.as_number() {
        Some(n) => println("Number: \{n}"),
        None => println("Not a number")
      }
    }
    Err(e) => println("Error: \{e}")
  }
}

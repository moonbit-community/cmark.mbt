// Regression tests for the parser's well-formed UTF-16 input invariant.

///|
fn string_of_code_units(units : Array[Int]) -> String {
  let b = StringBuilder::new()
  for u in units {
    b.write_char(u.unsafe_to_char())
  }
  b.to_string()
}

///|
test "valid astral input renders normally" {
  inspect(@cmark_html.render("😀"), content="<p>😀</p>\n")
}

///|
test "panic parser rejects lone leading surrogate" {
  ignore(@cmark_html.render(string_of_code_units([0xD800])))
}

///|
test "panic parser rejects lone trailing surrogate" {
  ignore(@cmark_html.render(string_of_code_units([0xDC00])))
}

///|
test "panic parser rejects leading surrogate not followed by trailing surrogate" {
  ignore(@cmark_html.render(string_of_code_units([0xD800, 'a'.to_int()])))
}

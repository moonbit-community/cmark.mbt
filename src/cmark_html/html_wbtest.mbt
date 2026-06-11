///|
test "html escape with null character" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "\u{0}abc")
  inspect(b.to_string(), content="\uFFFDabc")
}

///|
test "html escape with ampersand" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a&b")
  inspect(b.to_string(), content="a&amp;b")
}

///|
test "html escape with less than" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a<b")
  inspect(b.to_string(), content="a&lt;b")
}

///|
test "html escape with greater than" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a>b")
  inspect(b.to_string(), content="a&gt;b")
}

///|
test "html escape with double quote" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a\"b")
  inspect(b.to_string(), content="a&quot;b")
}

///|
test "buffer_add_pct_encoded_string with ' character" {
  let b = StringBuilder::new()
  buffer_add_pct_encoded_string(b, "don't")
  inspect(b.to_string(), content="don&apos;t")
}

///|
test "xhtml_renderer with safe mode" {
  let renderer = xhtml_renderer(safe=true)
  inspect(renderer.doc_to_string(@cmark.Doc::empty()), content="")
}

///|
test "xhtml_renderer with backend_blocks" {
  let renderer = xhtml_renderer(backend_blocks=true, safe=false)
  inspect(renderer.doc_to_string(@cmark.Doc::empty()), content="")
}

///|
test "buffer_add_pct_encoded_string with ampersand" {
  let b = StringBuilder::new()
  buffer_add_pct_encoded_string(b, "test&test") // This will trigger line 211 for "&" handling
  inspect(b.to_string(), content="test&amp;test")
}

///|
fn wb_string_of_code_units(units : Array[Int]) -> String {
  let b = StringBuilder::new()
  for u in units {
    b.write_char(u.unsafe_to_char())
  }
  b.to_string()
}

///|
/// `write_span`'s fast path must not bulk-copy a span that contains a
/// lone surrogate (which `Parser::new` would normally sanitize away, but
/// a programmatically built Doc need not): it has to fall back to the
/// per-code-unit path that emits U+FFFD, keeping the output well-formed.
test "html escape sanitizes a lone leading surrogate" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, wb_string_of_code_units([0xD800]))
  inspect(b.to_string(), content="�")
  b.reset()
  buffer_add_html_escaped_string(
    b,
    wb_string_of_code_units(['a'.to_int(), 0xD800, 'b'.to_int()]),
  )
  inspect(b.to_string(), content="a�b")
  // A valid astral char still round-trips.
  b.reset()
  buffer_add_html_escaped_string(b, "a😀b")
  inspect(b.to_string(), content="a😀b")
}

///|
test "pct encode sanitizes a lone leading surrogate" {
  let b = StringBuilder::new()
  buffer_add_pct_encoded_string(
    b,
    wb_string_of_code_units(['a'.to_int(), 0xD800]),
  )
  // U+FFFD percent-encoded as its UTF-8 bytes.
  inspect(b.to_string(), content="a%EF%BF%BD")
}

test "html escape with null character" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "\x00abc")
  inspect!(b.to_string(), content="\uFFFDabc")
}

test "html escape with ampersand" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a&b")
  inspect!(b.to_string(), content="a&amp;b")
}

test "html escape with less than" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a<b")
  inspect!(b.to_string(), content="a&lt;b")
}

test "html escape with greater than" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a>b")
  inspect!(b.to_string(), content="a&gt;b")
}

test "html escape with double quote" {
  let b = StringBuilder::new()
  buffer_add_html_escaped_string(b, "a\"b")
  inspect!(b.to_string(), content="a&quot;b")
}

test "buffer_add_pct_encoded_string with ' character" {
  let b = StringBuilder::new()
  buffer_add_pct_encoded_string(b, "don't")
  inspect!(b.to_string(), content="don&apos;t")
}

test "xhtml_renderer with safe mode" {
  let renderer = xhtml_renderer(safe=true)
  inspect!(renderer.doc_to_string!(@cmark.Doc::empty()), content="")
}

test "xhtml_renderer with backend_blocks" {
  let renderer = xhtml_renderer(backend_blocks=true, safe=false)
  inspect!(renderer.doc_to_string!(@cmark.Doc::empty()), content="")
}

test "buffer_add_pct_encoded_string with ampersand" {
  let b = StringBuilder::new()
  buffer_add_pct_encoded_string(b, "test&test") // This will trigger line 211 for "&" handling
  inspect!(b.to_string(), content="test&amp;test")
}

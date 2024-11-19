test "html escape NULL char" {
  let b = @buffer.new()
  buffer_add_html_escaped_char(b, '\x00')
  inspect!(b.to_unchecked_string(), content="�") // Test line 117
}

test "html escape ampersand" {
  let b = @buffer.new()
  buffer_add_html_escaped_char(b, '&')
  inspect!(b.to_unchecked_string(), content="&amp;") // Test line 118
}

test "html escape less than" {
  let b = @buffer.new()
  buffer_add_html_escaped_char(b, '<')
  inspect!(b.to_unchecked_string(), content="&lt;") // Test line 119
}

test "html escape greater than" {
  let b = @buffer.new()
  buffer_add_html_escaped_char(b, '>')
  inspect!(b.to_unchecked_string(), content="&gt;") // Test line 120
}

test "html escape quotes" {
  let b = @buffer.new()
  buffer_add_html_escaped_char(b, '"')
  inspect!(b.to_unchecked_string(), content="&quot;") // Test line 122
}

test "html_escaped_char for regular character" {
  let ctx = @cmark_renderer.Context::new(
    @cmark_renderer.Renderer::new(),
    @buffer.new(),
  )
  html_escaped_char(ctx, 'a')
  inspect!(ctx.b.to_unchecked_string(), content="a")
}

test "html_escaped_char for HTML special characters" {
  let ctx = @cmark_renderer.Context::new(
    @cmark_renderer.Renderer::new(),
    @buffer.new(),
  )
  html_escaped_char(ctx, '<')
  html_escaped_char(ctx, '>')
  html_escaped_char(ctx, '&')
  html_escaped_char(ctx, '"')
  inspect!(ctx.b.to_unchecked_string(), content="&lt;&gt;&amp;&quot;")
}

test "html escape with null character" {
  let b = @buffer.new()
  buffer_add_html_escaped_string(b, "\x00abc")
  inspect!(b.to_unchecked_string(), content="\uFFFDabc")
}

test "html escape with ampersand" {
  let b = @buffer.new()
  buffer_add_html_escaped_string(b, "a&b")
  inspect!(b.to_unchecked_string(), content="a&amp;b")
}

test "html escape with less than" {
  let b = @buffer.new()
  buffer_add_html_escaped_string(b, "a<b")
  inspect!(b.to_unchecked_string(), content="a&lt;b")
}

test "html escape with greater than" {
  let b = @buffer.new()
  buffer_add_html_escaped_string(b, "a>b")
  inspect!(b.to_unchecked_string(), content="a&gt;b")
}

test "html escape with double quote" {
  let b = @buffer.new()
  buffer_add_html_escaped_string(b, "a\"b")
  inspect!(b.to_unchecked_string(), content="a&quot;b")
}

test "buffer_add_pct_encoded_string with ' character" {
  let b = @buffer.new()
  buffer_add_pct_encoded_string(b, "don't")
  inspect!(b.to_unchecked_string(), content="don&apos;t")
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
  let b = @buffer.new()
  buffer_add_pct_encoded_string(b, "test&test") // This will trigger line 211 for "&" handling
  inspect!(b.to_unchecked_string(), content="test&amp;test")
}

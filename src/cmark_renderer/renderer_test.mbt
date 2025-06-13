///|
test "context char" {
  let b = StringBuilder::new(size_hint=0)
  let r = Renderer::new()
  let ctx = Context::new(r, b)
  ctx.char('A')
  inspect(b.to_string(), content="A")
}

///|
test "context_string" {
  let buf = StringBuilder::new(size_hint=0)
  let renderer = Renderer::new()
  let context = Context::new(renderer, buf)
  context.string("hello")
  inspect(buf.to_string(), content="hello")
}

///|
test "renderer_compose" {
  let r1 = Renderer::new(
    init_context=fn(c, _) { c.string("r1-init") },
    inline=fn(c, _) {
      c.string("r1-inline")
      true
    },
    block=fn(c, _) {
      c.string("r1-block")
      true
    },
    doc=fn(c, _) {
      c.string("r1-doc")
      true
    },
  )
  let r2 = Renderer::new(
    init_context=fn(c, _) { c.string("r2-init") },
    inline=fn(c, _) {
      c.string("r2-inline")
      true
    },
    block=fn(c, _) {
      c.string("r2-block")
      true
    },
    doc=fn(c, _) {
      c.string("r2-doc")
      true
    },
  )
  let composed = r1.compose(r2)

  // Test init_context
  {
    let buf = StringBuilder::new(size_hint=0)
    let ctx = Context::new(composed, buf)
    ctx.init(@cmark.Doc::empty())
    inspect(buf.to_string(), content="r1-initr2-init")
  }

  // Test inline handler - should call r2 first, if that returns true, r1 shouldn't be called
  {
    let buf = StringBuilder::new(size_hint=0)
    let ctx = Context::new(composed, buf)
    ctx.inline(@cmark.Inline::empty())
    inspect(buf.to_string(), content="r2-inline")
  }

  // Test block handler
  {
    let buf = StringBuilder::new(size_hint=0)
    let ctx = Context::new(composed, buf)
    ctx.block(@cmark.Block::empty())
    inspect(buf.to_string(), content="r2-block")
  }

  // Test doc handler
  let buf = StringBuilder::new(size_hint=0)
  let ctx = Context::new(composed, buf)
  ctx.doc(@cmark.Doc::empty())
  inspect(buf.to_string(), content="r1-initr2-initr2-doc")
}

///|
test "renderer_error_handling_inline" {
  // Test for error handling in inline!
  let r = Renderer::new(inline=fn(_, _) { false }, // Always returns false to trigger error
  )
  let buf = StringBuilder::new(size_hint=0)
  let ctx = Context::new(r, buf)
  let result = ctx.inline?(@cmark.Inline::empty())
  inspect(
    result,
    content=
      #|Err(RenderError("unknown inline type"))
    ,
  )
}

///|
test "renderer_error_handling_block" {
  // Test for error handling in block!
  let r = Renderer::new(block=fn(_, _) { false }, // Always returns false to trigger error
  )
  let buf = StringBuilder::new(size_hint=0)
  let ctx = Context::new(r, buf)
  let result = ctx.block?(@cmark.Block::empty())
  inspect(
    result,
    content=
      #|Err(RenderError("unknown block type"))
    ,
  )
}

///|
test "renderer_error_handling_doc" {
  // Test for error handling in doc!
  let r = Renderer::new(doc=fn(_, _) { false }, // Always returns false to trigger error
  )
  let buf = StringBuilder::new(size_hint=0)
  let ctx = Context::new(r, buf)
  let result = ctx.doc?(@cmark.Doc::empty())
  inspect(
    result,
    content=
      #|Err(RenderError("unhandled doc"))
    ,
  )
}

///|
test "doc_to_string_and_buffer_add_doc" {
  let r = Renderer::new(doc=fn(c, _) {
    c.string("doc content")
    true
  })

  // Test doc_to_string!
  let result = r.doc_to_string(@cmark.Doc::empty())
  inspect(result, content="doc content")

  // Test buffer_add_doc!
  let buf = StringBuilder::new(size_hint=0)
  r.buffer_add_doc(buf, @cmark.Doc::empty())
  inspect(buf.to_string(), content="doc content")
}

///|
test "renderer_fallback" {
  // Test case where first renderer returns false but second one returns true
  let r1 = Renderer::new(inline=fn(_, _) { false }, block=fn(_, _) { false }, doc=fn(
    _,
    _
  ) {
    false
  })
  let r2 = Renderer::new(
    inline=fn(c, _) {
      c.string("r2-inline")
      true
    },
    block=fn(c, _) {
      c.string("r2-block")
      true
    },
    doc=fn(c, _) {
      c.string("r2-doc")
      true
    },
  )
  let composed = r1.compose(r2)

  // Test inline handler with fallback
  {
    let buf = StringBuilder::new(size_hint=0)
    let ctx = Context::new(composed, buf)
    ctx.inline(@cmark.Inline::empty())
    inspect(buf.to_string(), content="r2-inline")
  }

  // Test block handler with fallback
  {
    let buf = StringBuilder::new(size_hint=0)
    let ctx = Context::new(composed, buf)
    ctx.block(@cmark.Block::empty())
    inspect(buf.to_string(), content="r2-block")
  }

  // Test doc handler with fallback
  let buf = StringBuilder::new(size_hint=0)
  let ctx = Context::new(composed, buf)
  ctx.doc(@cmark.Doc::empty())
  inspect(buf.to_string(), content="r2-doc")
}

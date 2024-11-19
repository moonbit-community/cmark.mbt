test "context char" {
  let b = @buffer.new(size_hint=0)
  let r = Renderer::new()
  let ctx = Context::new(r, b)
  ctx.char('A')
  inspect!(b.to_unchecked_string(), content="A")
}

test "context_string" {
  let buf = @buffer.new(size_hint=0)
  let renderer = Renderer::new()
  let context = Context::new(renderer, buf)
  context.string("hello")
  inspect!(buf.to_unchecked_string(), content="hello")
}

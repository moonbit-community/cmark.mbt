test "context char" {
  let b = StringBuilder::new(size_hint=0)
  let r = Renderer::new()
  let ctx = Context::new(r, b)
  ctx.char('A')
  inspect!(b.to_string(), content="A")
}

test "context_string" {
  let buf = StringBuilder::new(size_hint=0)
  let renderer = Renderer::new()
  let context = Context::new(renderer, buf)
  context.string("hello")
  inspect!(buf.to_string(), content="hello")
}

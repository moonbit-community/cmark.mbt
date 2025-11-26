///|
test "node_map" {
  let meta = @cmark_base.Meta::new()
  let node = @cmark.Node::new("test", meta~)
  let mapped = node.map(fn(s) { s + "!" })
  inspect(mapped.v, content="test!")
  inspect(mapped.meta.is_none(), content="false")
}

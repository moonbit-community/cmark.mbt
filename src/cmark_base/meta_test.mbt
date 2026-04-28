///|
test "Meta compare" {
  let meta1 = @cmark_base.Meta::new()
  let meta2 = @cmark_base.Meta::new()
  debug_inspect(meta1.compare(meta2), content="-1")
}

///|
test "Meta compare with self" {
  let meta = @cmark_base.Meta::new()
  debug_inspect(meta.compare(meta), content="0")
}

///|
test "Meta none sentinel" {
  let none_meta = @cmark_base.Meta::none()
  debug_inspect(none_meta.is_none(), content="true")
}

///|
test "@cmark_base.Meta::none is empty" {
  let meta = @cmark_base.Meta::none()
  debug_inspect(meta.is_none(), content="true")
}

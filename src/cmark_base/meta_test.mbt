///|
test "Meta compare" {
  let meta1 = @cmark_base.Meta::new()
  let meta2 = @cmark_base.Meta::new()
  inspect(meta1.compare(meta2), content="-1")
}

///|
test "Meta compare with self" {
  let meta = @cmark_base.Meta::new()
  inspect(meta.compare(meta), content="0")
}

///|
test "show_implementation_for_meta_none" {
  let none_meta = @cmark_base.Meta::none()
  inspect(Show::to_string(none_meta), content="Meta::none()")
}

///|
test "@cmark_base.Meta::to_json empty" {
  let meta = @cmark_base.Meta::none()
  inspect(meta.to_json(), content="Object({})")
}

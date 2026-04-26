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
test "show_implementation_for_meta_none" {
  let none_meta = @cmark_base.Meta::none()
  debug_inspect(
    @debug.to_string(none_meta),
    content=(
      #|"{\n  id: 0,\n  loc: {\n    file: \"-\",\n    first_ccode: -1,\n    last_ccode: -1,\n    first_line: LinePos(-1, -1),\n    last_line: LinePos(-1, -1),\n  },\n  extra: None,\n}"
    ),
  )
}

///|
test "@cmark_base.Meta::to_json empty" {
  let meta = @cmark_base.Meta::none()
  debug_inspect(meta.to_json(), content="Object({})")
}

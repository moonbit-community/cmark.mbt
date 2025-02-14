///|
test "Meta compare" {
  let meta1 = Meta::new()
  let meta2 = Meta::new()
  inspect!(meta1.compare(meta2), content="-1")
}

///|
test "Meta compare with self" {
  let meta = Meta::new()
  inspect!(meta.compare(meta), content="0")
}

///|
test "show_implementation_for_meta_none" {
  let none_meta = Meta::none()
  inspect!(Show::to_string(none_meta), content="Meta::none()")
}

///|
test "Meta::to_json empty" {
  let meta = Meta::none()
  inspect!(meta.to_json(), content="Object({})")
}

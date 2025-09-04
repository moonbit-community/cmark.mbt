///|
/// Test for tag_name
test "tag_name with valid tag" {
  let s = "div class=\"test\">"
  let result = tag_name(s, last=16, start=0)
  inspect(result, content="Some(2)")
}

///|
test "tag_name with hyphen" {
  let s = "custom-tag>"
  let result = tag_name(s, last=10, start=0)
  inspect(result, content="Some(9)")
}

///|
test "tag_name with invalid start condition" {
  let s = "1div>"
  let result = tag_name(s, last=4, start=0)
  inspect(result, content="Some(3)")
}

///|
/// Test for attribute_name
test "attribute_name with valid start chars" {
  let s = "_attr:value"
  let result = attribute_name(s, last=9, start=0)
  inspect(result, content="Some(9)")
}

///|
test "attribute_name with valid continuation chars" {
  let s = "attr.name-with_colons:value"
  let result = attribute_name(s, last=24, start=0)
  inspect(result, content="Some(24)")
}

///|
test "attribute_name with invalid start" {
  let s = ".invalid"
  let result = attribute_name(s, last=7, start=0)
  inspect(result, content="None")
}

///|
test "attribute_name when start > last" {
  let s = "attr"
  let result = attribute_name(s, last=3, start=4)
  inspect(result, content="None")
}

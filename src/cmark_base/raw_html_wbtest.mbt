///| Mock NextLineFn that returns the specified LineSpan
fn mock_next_line(ret_line : LineSpan) -> (String) -> LineSpan? {
  fn(_) { Some(ret_line) }
}

///| Test for tag_name
test "tag_name with valid tag" {
  let s = "div class=\"test\">"
  let result = tag_name(s, last=16, start=0)
  inspect!(result, content="Some(2)")
}

///|
test "tag_name with hyphen" {
  let s = "custom-tag>"
  let result = tag_name(s, last=10, start=0)
  inspect!(result, content="Some(9)")
}

///|
test "tag_name with invalid start condition" {
  let s = "1div>"
  let result = tag_name(s, last=4, start=0)
  inspect!(result, content="Some(3)")
}

///| Test for attribute_name
test "attribute_name with valid start chars" {
  let s = "_attr:value"
  let result = attribute_name(s, last=9, start=0)
  inspect!(result, content="Some(9)")
}

///|
test "attribute_name with valid continuation chars" {
  let s = "attr.name-with_colons:value"
  let result = attribute_name(s, last=24, start=0)
  inspect!(result, content="Some(24)")
}

///|
test "attribute_name with invalid start" {
  let s = ".invalid"
  let result = attribute_name(s, last=7, start=0)
  inspect!(result, content="None")
}

///|
test "attribute_name when start > last" {
  let s = "attr"
  let result = attribute_name(s, last=3, start=4)
  inspect!(result, content="None")
}

///|
test "raw_html with invalid input" {
  let line_span = { pos: (1, 0), first: 0, last: 0 }
  let s = "" // Empty string
  let next_line_fn = mock_next_line(line_span)
  let result = raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect!(result, content="None")
}

///|
test "raw_html with processing instruction" {
  let s = "<?xml version=\"1.0\"?>"
  let line_span = { pos: (1, 0), first: 0, last: s.length() - 1 }
  let next_line_fn = mock_next_line(line_span)
  let result = raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect!(
    result,
    content="Some(({pos: (1, 0), first: 0, last: 20}, [{start: 0, span: {pos: (1, 0), first: 0, last: 20}}], 20))",
  )
}

///|
test "raw_html with HTML comment" {
  let s = "<!-- test -->"
  let line_span = { pos: (1, 0), first: 0, last: s.length() - 1 }
  let next_line_fn = mock_next_line(line_span)
  let result = raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect!(
    result,
    content="Some(({pos: (1, 0), first: 0, last: 12}, [{start: 0, span: {pos: (1, 0), first: 0, last: 12}}], 12))",
  )
}

///|
test "raw_html with declaration" {
  let s = "<!DOCTYPE html>"
  let line_span = { pos: (1, 0), first: 0, last: s.length() - 1 }
  let next_line_fn = mock_next_line(line_span)
  let result = raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect!(
    result,
    content="Some(({pos: (1, 0), first: 0, last: 14}, [{start: 0, span: {pos: (1, 0), first: 0, last: 14}}], 14))",
  )
}

///|
test "raw_html with CDATA section" {
  let s = "<![CDATA[test]]>"
  let line_span = { pos: (1, 0), first: 0, last: s.length() - 1 }
  let next_line_fn = mock_next_line(line_span)
  let result = raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect!(
    result,
    content="Some(({pos: (1, 0), first: 0, last: 15}, [{start: 0, span: {pos: (1, 0), first: 0, last: 15}}], 15))",
  )
}

///|
test "raw_html with invalid char after <!" {
  let s = "<!1" // Invalid character after <!
  let line_span = { pos: (1, 0), first: 0, last: s.length() - 1 }
  let next_line_fn = mock_next_line(line_span)
  let result = raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect!(result, content="None")
}

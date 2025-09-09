///|
/// Mock NextLineFn that returns the specified @cmark_base.LineSpan
fn mock_next_line(
  _ : @cmark_base.LineSpan,
) -> (String) -> @cmark_base.LineSpan? {
  fn(_) { None }
}

///|
test "raw_html with invalid input" {
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 0,
  }
  let s = "" // Empty string
  let next_line_fn = mock_next_line(line_span)
  let result = @cmark_base.raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
test "raw_html with processing instruction" {
  let s = "<?xml version=\"1.0\"?>"
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let next_line_fn = mock_next_line(line_span)
  let result = @cmark_base.raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 0, last: 20}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 20}}], 20))",
  )
}

///|
test "raw_html with HTML comment" {
  let s = "<!-- test -->"
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let next_line_fn = mock_next_line(line_span)
  let result = @cmark_base.raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 0, last: 12}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 12}}], 12))",
  )
}

///|
test "raw_html with declaration" {
  let s = "<!DOCTYPE html>"
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let next_line_fn = mock_next_line(line_span)
  let result = @cmark_base.raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 0, last: 14}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 14}}], 14))",
  )
}

///|
test "raw_html with CDATA section" {
  let s = "<![CDATA[test]]>"
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let next_line_fn = mock_next_line(line_span)
  let result = @cmark_base.raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 0, last: 15}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 15}}], 15))",
  )
}

///|
test "raw_html with invalid char after <!" {
  let s = "<!1" // Invalid character after <!
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let next_line_fn = mock_next_line(line_span)
  let result = @cmark_base.raw_html(
    next_line=next_line_fn,
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///| Additional tests for raw_html.mbt to improve coverage

///|
/// Test raw_html with invalid start condition
test "raw_html_invalid_start" {
  let s = "text without any HTML"
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test raw_html with closing tag that has invalid tag name
test "raw_html_closing_tag_invalid_name" {
  let s = "</1div>" // Tag name cannot start with a number
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 6, last: 6}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 6}}], 6))",
  )
}

///|
/// Test raw_html with closing tag that has no closing bracket
test "raw_html_closing_tag_no_end" {
  let s = "</div" // Missing closing >
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test raw_html with invalid open tag
test "raw_html_open_tag_invalid" {
  let s = "<.div>" // Tag name cannot start with a dot
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 5, last: 5}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 5}}], 5))",
  )
}

///|
/// Test raw_html with self-closing tag that has no closing bracket
test "raw_html_self_closing_tag_no_end" {
  let s = "<div /" // Missing closing >
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test raw_html with attribute that has invalid name
test "raw_html_attribute_invalid_name" {
  let s = "<div .class=\"value\">"
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test raw_html with attribute that has no value
test "raw_html_attribute_no_value" {
  let s = "<div data-attr>" // Attribute without value is valid
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 14, last: 14}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 14}}], 14))",
  )
}

///|
/// Test raw_html with unquoted attribute value
test "raw_html_attribute_unquoted_value" {
  let s = "<div data-attr=value>" // Unquoted attribute value is valid
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(
    result,
    content="Some(({pos: LinePos(1, 0), first: 20, last: 20}, [{start: 0, span: {pos: LinePos(1, 0), first: 0, last: 20}}], 20))",
  )
}

///|
/// Test raw_html with exclamation mark but invalid format
test "raw_html_exclamation_invalid" {
  let s = "<!x" // Invalid character after <!
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: s.length() - 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dum",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test raw_html with exclamation mark but too short
test "raw_html_exclamation_too_short" {
  let s = "<!" // Too short after !
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 1,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test HTML comment with incomplete format
test "raw_html_comment_incomplete" {
  let s = "<!-" // Incomplete HTML comment
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 2,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test HTML comment with invalid format 1
test "raw_html_comment_invalid1" {
  let s = "<!-->" // Invalid HTML comment
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 4,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test HTML comment with invalid format 2
test "raw_html_comment_invalid2" {
  let s = "<!--->" // Invalid HTML comment
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 5,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test CDATA section with incomplete format
test "raw_html_cdata_incomplete" {
  let s = "<![" // Incomplete CDATA
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 2,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

///|
/// Test CDATA section with wrong format
test "raw_html_cdata_wrong_format" {
  let s = "<![ Wrong" // Not CDATA format
  let line_span = @cmark_base.LineSpan::{
    pos: LinePos(1, 0),
    first: 0,
    last: 8,
  }
  let result = @cmark_base.raw_html(
    next_line=mock_next_line(line_span),
    s,
    "dummy",
    line=line_span,
    start=0,
  )
  inspect(result, content="None")
}

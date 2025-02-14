///|
test "normalize other block types" {
  let block = Block::BlankLine(Node::empty())
  inspect!(block.normalize(), content="BlankLine(Node::new(\"\"))")
}

///|
test "language_of_info_string with empty string" {
  inspect!(CodeBlock::language_of_info_string(""), content="None")
}

///|
test "language_of_info_string with only whitespace in language" {
  inspect!(CodeBlock::language_of_info_string("   "), content="None")
}

///|
test "create new list item" {
  let block = Block::empty()
  let item = ListItem::new(
    before_marker=2,
    marker=layout_empty,
    after_marker=1,
    ext_task_marker=None,
    block,
  )
  inspect!(item.before_marker, content="2")
  inspect!(item.after_marker, content="1")
}

///|
test "Show for Tight outputs the node content" {
  let tight = Tight::empty()
  inspect!(Show::to_string(tight), content="\"\"")
}

///|
test "get_first_line with CRLF" {
  let line = "hello\r\nworld"
  let doc = @cmark.Doc::from_string(line)
  inspect!(doc.nl, content="\r\n")
}

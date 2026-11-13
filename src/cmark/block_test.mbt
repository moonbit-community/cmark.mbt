///|
test "normalize other block types" {
  let block = @cmark.Block::BlankLine(@cmark.Node::empty())
  guard block.normalize() is BlankLine(node) else {
    fail("normalization must preserve a blank line")
  }
  @test.assert_eq(node.v, "")
  let quote = @cmark.Block::BlockQuote(
    @cmark.Node::new(@cmark.BlockQuote::new(@cmark.Block::empty())),
  )
  guard quote.normalize()
    is BlockQuote({ v: { block: Blocks(blocks), .. }, .. }) else {
    fail("normalization must preserve an empty block quote")
  }
  @test.assert_eq(blocks.v.is_empty(), true)
}

///|
test "language_of_info_string with empty string" {
  @test.assert_eq(@cmark.CodeBlock::language_of_info_string(""), None)
}

///|
test "language_of_info_string with only whitespace in language" {
  @test.assert_eq(@cmark.CodeBlock::language_of_info_string("   "), None)
}

///|
test "code block with indented layout and info string" {
  let code = @cmark.Seq::from_array([@cmark.StringNode::empty()])
  let info = @cmark.Node::new("info")
  let block = @cmark.CodeBlock::new(
    layout=Indented,
    info_string=Some(info),
    code,
  )
  guard block.layout is Fenced(layout) else {
    fail("an info string requires a fenced code block")
  }
  @test.assert_eq(layout.indent, 0)
}

///|
test "code block make fence" {
  let code = @cmark.Seq::from_array([@cmark.Node::new("plain text")])
  @test.assert_eq(@cmark.CodeBlock::new(code).make_fence(), ('`', 3))
  let code = @cmark.Seq::from_array([
    @cmark.Node::new("```Example with backticks```"),
  ])
  @test.assert_eq(@cmark.CodeBlock::new(code).make_fence(), ('`', 4))
}

///|
test "block normalize with list using Seq.empty" {
  let items = @cmark.Seq::empty()
  let list = @cmark.BlockList::{ ty: Unordered('*'), tight: true, items, }
  let normalized = @cmark.Block::List(@cmark.Node::new(list)).normalize()
  guard normalized is List(node) else {
    fail("normalization must preserve an empty list")
  }
  @test.assert_eq(node.v.items.is_empty(), true)
}

///|
test "list item map_block" {
  let item = @cmark.ListItem::new(
    before_marker=2,
    marker=@cmark.layout_empty,
    after_marker=1,
    ext_task_marker=None,
    @cmark.Block::empty(),
  )
  let mapped = item.map_block(fn(_) {
    @cmark.Block::BlankLine(@cmark.Node::new(""))
  })
  guard mapped.block is BlankLine(node) else {
    fail("map_block must replace the item's block")
  }
  @test.assert_eq(node.v, "")
  @test.assert_eq(mapped.before_marker, item.before_marker)
  @test.assert_eq(mapped.after_marker, item.after_marker)
}

///|
test "list task status from marker with custom marker" {
  guard @cmark.ListTaskStatus::from_marker('?') is Other(marker) else {
    fail("an unknown task marker must be preserved")
  }
  @test.assert_eq(marker, '?')
}

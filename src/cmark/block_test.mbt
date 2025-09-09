///|
test "normalize other block types" {
  let block = @cmark.Block::BlankLine(@cmark.Node::empty())
  inspect(block.normalize(), content="BlankLine(Node::new(\"\"))")

  // Test BlockQuote normalization
  let quote_block = @cmark.Block::BlockQuote(
    @cmark.Node::new(@cmark.BlockQuote::new(@cmark.Block::empty())),
  )
  inspect(
    quote_block.normalize(),
    content="BlockQuote(Node::new({indent: 0, block: Blocks(Node::new(Seq([])))}))",
  )
}

///|
test "language_of_info_string with empty string" {
  inspect(@cmark.CodeBlock::language_of_info_string(""), content="None")
}

///|
test "language_of_info_string with only whitespace in language" {
  inspect(@cmark.CodeBlock::language_of_info_string("   "), content="None")
}

///|
test "code block new with info string" {
  let node = @cmark.StringNode::empty()
  let code = @cmark.Seq::from_array([node])
  let info = @cmark.Node::new("info")
  let codeBlock = @cmark.CodeBlock::new(info_string=Some(info), code)
  match codeBlock.info_string {
    Some(info_node) => inspect(info_node.v, content="info")
    None => inspect(false, content="true")
  }
}

///|
/// Test CodeBlock::new with indented layout and info string
test "code block with indented layout and info string" {
  let node = @cmark.StringNode::empty()
  let code = @cmark.Seq::from_array([node])
  let info = @cmark.Node::new("info")
  let codeBlock = @cmark.CodeBlock::new(
    layout=@cmark.CodeBlockLayout::Indented,
    info_string=Some(info),
    code,
  )
  match codeBlock.layout {
    @cmark.CodeBlockLayout::Fenced(layout) => {
      inspect(layout.indent, content="0")
      inspect(true, content="true")
    }
    @cmark.CodeBlockLayout::Indented => inspect(false, content="true")
  }
}

///|
/// Test for CodeBlock::make_fence
test "code block make fence" {
  // Test when there are no backticks in any lines
  let node = @cmark.Node::new("plain text")
  let code = @cmark.Seq::from_array([node])
  let codeBlock = @cmark.CodeBlock::new(code)
  let (char, count) = codeBlock.make_fence()
  inspect(char, content="`")
  inspect(count, content="3")

  // Test with backticks in code
  let node_with_backticks = @cmark.Node::new("```Example with backticks```")
  let code_with_backticks = @cmark.Seq::from_array([node_with_backticks])
  let codeBlock_with_backticks = @cmark.CodeBlock::new(code_with_backticks)
  let (char2, count2) = codeBlock_with_backticks.make_fence()
  inspect(char2, content="`")
  inspect(count2, content="4")
}

///|
/// Test Block::normalize for BlockQuote
test "block normalize with block quote" {
  let blockQuote = @cmark.BlockQuote::new(@cmark.Block::empty())
  let normalized = @cmark.Block::BlockQuote(@cmark.Node::new(blockQuote)).normalize()
  inspect(
    normalized,
    content="BlockQuote(Node::new({indent: 0, block: Blocks(Node::new(Seq([])))}))",
  )
}

///|
/// Test Block::normalize for List with Seq.empty()
test "block normalize with list using Seq.empty" {
  let items = @cmark.Seq::empty()
  let list = @cmark.BlockList::{
    ty: @cmark_base.ListType::Unordered('*'),
    tight: true,
    items,
  }
  let normalized = @cmark.Block::List(@cmark.Node::new(list)).normalize()
  inspect(
    normalized,
    content="List(Node::new({ty: Unordered('*'), tight: true, items: Seq([])}))",
  )
}

///|
/// Tests to improve coverage for the block.mbt file
test "code block fenced layout default" {
  let layout = @cmark.CodeBlockFencedLayout::default()
  inspect(layout.indent, content="0")
}

///|
test "thematic break new" {
  let tb = @cmark.BlockThematicBreak::new(indent=2, layout="***")
  inspect(tb.indent, content="2")
  inspect(tb.layout, content="***")
}

///|
test "create new list item" {
  let block = @cmark.Block::empty()
  let item = @cmark.ListItem::new(
    before_marker=2,
    marker=@cmark.layout_empty,
    after_marker=1,
    ext_task_marker=None,
    block,
  )
  inspect(item.before_marker, content="2")
  inspect(item.after_marker, content="1")

  // Test ListItem::map_block and ListItem::normalize_block
  let new_block = @cmark.Block::BlankLine(@cmark.Node::new(""))
  let mapped_item = item.map_block(fn(_) { new_block })
  inspect(mapped_item.block, content="BlankLine(Node::new(\"\"))")
  let normalized_item = item.normalize_block()
  inspect(normalized_item.before_marker, content="2")
}

///|
test "block quote normalize_block" {
  let quote = @cmark.BlockQuote::new(@cmark.Block::empty())
  let normalized_quote = quote.normalize_block()
  inspect(normalized_quote.indent, content="0")
}

///|
/// Test the ListTaskStatus::from_marker with a custom marker
test "list task status from marker with custom marker" {
  let status = @cmark.ListTaskStatus::from_marker('?')
  match status {
    Other(c) => inspect(c, content="?")
    _ => inspect(false, content="true")
  }
}

///|
test "paragraph new" {
  let inline = @cmark.Inline::Text(@cmark.Node::new("text"))
  let para = @cmark.BlockParagraph::new(
    leading_indent=2,
    trailing_blanks="  ",
    inline,
  )
  inspect(para.leading_indent, content="2")
  inspect(para.trailing_blanks, content="  ")
}

///|
test "heading new" {
  let inline = @cmark.Inline::Text(@cmark.Node::new("heading"))
  let heading = @cmark.BlockHeading::new(level=2, inline)
  inspect(heading.level, content="2")
}

///|
test "block normalize" {
  let block = @cmark.Block::BlankLine(@cmark.Node::new(""))
  let normalized = block.normalize()
  inspect(normalized, content="BlankLine(Node::new(\"\"))")
}

///|
test "Show for Tight outputs the node content" {
  let tight = @cmark.Tight::empty()
  inspect(Show::to_string(tight), content="\"\"")
}

///|
test "BlockLine::to_string extracts the string value" {
  let meta = @cmark_base.Meta::none()
  let block_line : @cmark.BlockLine = { v: "Test string", meta }
  let result = block_line.to_string()
  inspect(result, content="Test string")
}

///|
test "BlockLine::list_text_loc handles empty sequence" {
  let empty_seq = @cmark.Seq::empty()
  inspect(
    @cmark.BlockLine::list_text_loc(empty_seq),
    content=(
      #|{file: "-", first_ccode: -1, last_ccode: -1, first_line: LinePos(-1, -1), last_line: LinePos(-1, -1)}
    ),
  )
}

///|
test "BlockLine::list_text_loc handles single element sequence" {
  let loc = @cmark_base.TextLoc::{
    file: @cmark_base.file_path_none,
    first_ccode: 0,
    last_ccode: 5,
    first_line: LinePos(1, 0),
    last_line: LinePos(1, 5),
  }
  let meta = @cmark_base.Meta::new(loc~)
  let single_node : @cmark.BlockLine = { v: "hello", meta }
  let single_seq = @cmark.Seq::from_array([single_node])
  let result = @cmark.BlockLine::list_text_loc(single_seq)
  inspect(
    result,
    content=(
      #|{file: "-", first_ccode: 0, last_ccode: 5, first_line: LinePos(1, 0), last_line: LinePos(1, 5)}
    ),
  )
}

///|
test "BlockLine::list_text_loc handles multiple element sequence" {
  // First node with location at line 1
  let loc1 = @cmark_base.TextLoc::{
    file: @cmark_base.file_path_none,
    first_ccode: 0,
    last_ccode: 5,
    first_line: LinePos(1, 0),
    last_line: LinePos(1, 5),
  }
  let meta1 = @cmark_base.Meta::new(loc=loc1)
  let node1 : @cmark.BlockLine = { v: "hello", meta: meta1 }

  // Second node with location at line 2
  let loc2 = @cmark_base.TextLoc::{
    file: @cmark_base.file_path_none,
    first_ccode: 6,
    last_ccode: 11,
    first_line: LinePos(2, 0),
    last_line: LinePos(2, 5),
  }
  let meta2 = @cmark_base.Meta::new(loc=loc2)
  let node2 : @cmark.BlockLine = { v: "world", meta: meta2 }
  let multi_seq = @cmark.Seq::from_array([node1, node2])
  let result = @cmark.BlockLine::list_text_loc(multi_seq)

  // Should span from first_ccode of first node to last_ccode of last node
  inspect(
    result,
    content=(
      #|{file: "-", first_ccode: 0, last_ccode: 11, first_line: LinePos(1, 0), last_line: LinePos(2, 5)}
    ),
  )
}

///|
test "Tight::list_text_loc handles empty sequence" {
  let empty_seq = @cmark.Seq::empty()
  inspect(
    @cmark.Tight::list_text_loc(empty_seq),
    content=(
      #|{file: "-", first_ccode: -1, last_ccode: -1, first_line: LinePos(-1, -1), last_line: LinePos(-1, -1)}
    ),
  )
}

///|
test "Tight::list_text_loc handles single element sequence" {
  let loc = @cmark_base.TextLoc::{
    file: @cmark_base.file_path_none,
    first_ccode: 0,
    last_ccode: 5,
    first_line: LinePos(1, 0),
    last_line: LinePos(1, 5),
  }
  let meta = @cmark_base.Meta::new(loc~)
  let node : @cmark.StringNode = { v: "hello", meta }
  let t : @cmark.Tight = { blanks: "", node }
  let seq = @cmark.Seq::from_array([t])
  inspect(
    @cmark.Tight::list_text_loc(seq),
    content=(
      #|{file: "-", first_ccode: 0, last_ccode: 5, first_line: LinePos(1, 0), last_line: LinePos(1, 5)}
    ),
  )
}

///|
test "Tight::list_text_loc handles multiple element sequence" {
  // First tight element
  let loc1 = @cmark_base.TextLoc::{
    file: @cmark_base.file_path_none,
    first_ccode: 0,
    last_ccode: 5,
    first_line: LinePos(1, 0),
    last_line: LinePos(1, 5),
  }
  let meta1 = @cmark_base.Meta::new(loc=loc1)
  let node1 : @cmark.StringNode = { v: "hello", meta: meta1 }
  let t1 : @cmark.Tight = { blanks: "", node: node1 }

  // Second tight element
  let loc2 = @cmark_base.TextLoc::{
    file: @cmark_base.file_path_none,
    first_ccode: 6,
    last_ccode: 11,
    first_line: LinePos(2, 0),
    last_line: LinePos(2, 5),
  }
  let meta2 = @cmark_base.Meta::new(loc=loc2)
  let node2 : @cmark.StringNode = { v: "world", meta: meta2 }
  let t2 : @cmark.Tight = { blanks: "  ", node: node2 }
  let seq = @cmark.Seq::from_array([t1, t2])
  inspect(
    @cmark.Tight::list_text_loc(seq),
    content=(
      #|{file: "-", first_ccode: 0, last_ccode: 11, first_line: LinePos(1, 0), last_line: LinePos(2, 5)}
    ),
  )
}

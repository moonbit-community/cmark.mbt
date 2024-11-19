test "mapper ret function" {
  // Test ret function by passing in different types of values
  let int_result = Mapper::ret(42)
  inspect!(int_result, content="Map(Some(42))")
  let str_result = Mapper::ret("hello")
  inspect!(str_result, content="Map(Some(\"hello\"))")
  let bool_result = Mapper::ret(true)
  inspect!(bool_result, content="Map(Some(true))")
}

test "mapper_none" {
  // Create a new Mapper with default parameters
  let mapper = Mapper::new()
  // Call none with any value to trigger line 44
  inspect!(mapper.none(42), content="Default")
}

test "map_block blocks" {
  // Test blocks mapping
  let mapper = Mapper::new()
  let blocks = Block::Blocks(Node::new(@immut/list.Nil))
  inspect!(mapper.map_block(blocks), content="None")
}

test "panic block_ext_none raises error" {
  let mapper = Mapper::new()
  let block = Block::empty()
  let _ = mapper.block_ext_none!(block)

}

test "map_inline default case" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("hello"))
  inspect!(mapper.map_inline(text), content="Some(Text(Node::new(\"hello\")))")
}

test "map_doc with empty document" {
  let mapper = Mapper::new()
  let doc = Doc::empty()
  let result = mapper.map_doc(doc)
  inspect!(result.block, content="Blocks(Node::new(@list.of([])))")
}

test "map_block with default case" {
  let mapper = Mapper::new()
  let block = Block::BlankLine(Node::new(""))
  let result = mapper.map_block(block)
  inspect!(result, content="Some(BlankLine(Node::new(\"\")))")
}

test "map_block with blocks" {
  let mapper = Mapper::new()
  let block = Block::Blocks(
    Node::new(@immut/list.of([Block::BlankLine(Node::new(""))])),
  )
  let result = mapper.map_block(block)
  inspect!(
    result,
    content="Some(Blocks(Node::new(@list.of([BlankLine(Node::new(\"\"))]))))",
  )
}

test "map_block with paragraph" {
  let mapper = Mapper::new()
  let para = Block::Paragraph(
    Node::new(
      { leading_indent: 0, inline: Inline::empty(), trailing_blanks: "" },
    ),
  )
  let result = mapper.map_block(para)
  inspect!(result, content="None")
}

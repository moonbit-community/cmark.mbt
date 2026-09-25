///|
test "task children use ordinary list continuation indentation" {
  for indent in ["  ", "    "] {
    let source = "- [x] parent\n" + indent + "- [ ] child"
    guard @cmark.Doc::from_string(source, strict=false).block is List(parents) &&
      parents.v.items.to_array() is [parent] &&
      parent.v.block is Blocks(blocks) &&
      blocks.v.to_array() is [Paragraph(_), List(children)] &&
      children.v.items.to_array() is [child] else {
      fail("expected one parent task containing one child task")
    }
    @test.assert_eq(parent.v.ext_task_marker.map(marker => marker.v), Some('x'))
    @test.assert_eq(child.v.ext_task_marker.map(marker => marker.v), Some(' '))
  }
}

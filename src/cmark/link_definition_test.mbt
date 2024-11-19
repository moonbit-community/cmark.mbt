test "link definition layout for destination with space" {
  let dest = "hello world"
  let layout = LinkDefinitionLayout::for_dest(dest)
  inspect!(layout.angled_dest, content="true")
}

test "link definition layout for destination with control character" {
  let dest = "hello\x00world"
  let layout = LinkDefinitionLayout::for_dest(dest)
  inspect!(layout.angled_dest, content="true")
}

test "link definition layout for normal destination" {
  let dest = "hello-world"
  let layout = LinkDefinitionLayout::for_dest(dest)
  inspect!(layout.angled_dest, content="false")
}

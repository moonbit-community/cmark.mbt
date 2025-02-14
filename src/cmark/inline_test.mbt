///|
test "InlineAutolink::new with link" {
  let meta = @rami3l/cmark/cmark_base.Meta::none()
  let link = Node::new("example.com", meta~)
  let autolink = InlineAutolink::new(link)
  inspect!(autolink.is_email, content="false")
  inspect!(autolink.link.v, content="example.com")
}

///|
test "InlineCodeSpan::code with empty content" {
  let empty_code = InlineCodeSpan::from_string("")
  inspect!(empty_code.code(), content="")
}

///|
test "is_unsafe for data URLs" {
  // Test data URL with image/gif
  let data_url = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"
  inspect!(InlineLink::is_unsafe(data_url), content="false")

  // Test data URL with missing comma after base64
  let invalid_data = "data:image/gif;base64"
  inspect!(InlineLink::is_unsafe(invalid_data), content="true")

  // Test data URL with no semicolon
  let data_no_semi = "data:image/gif,content"
  inspect!(InlineLink::is_unsafe(data_no_semi), content="false")
}

///|
test "is_unsafe for data URLs with various media types" {
  // Test data URL with allowed image types
  let data_gif = "data:image/gif,R0lGO"
  let data_png = "data:image/png,iVBOR"
  let data_jpeg = "data:image/jpeg,/9j/4"
  let data_webp = "data:image/webp,UklGR"
  inspect!(InlineLink::is_unsafe(data_gif), content="false")
  inspect!(InlineLink::is_unsafe(data_png), content="false")
  inspect!(InlineLink::is_unsafe(data_jpeg), content="false")
  inspect!(InlineLink::is_unsafe(data_webp), content="false")
}

///|
test "referenced_label with inline reference" {
  let text = Inline::empty()
  let link_def = Node::new(LinkDefinition::new())
  let inline_ref = ReferenceKind::Inline(link_def)
  let link = InlineLink::new(text, inline_ref)
  inspect!(link.referenced_label(), content="None")
}

///|
test "inline id with text containing backticks" {
  let inline = Inline::CodeSpan(
    Node::new({
      backticks: 1,
      code_layout: Seq::from_array([{ blanks: "", node: Node::new("`text`") }]),
    }),
  )
  inspect!(inline.id(), content="text")
}

///|
test "inline id with whitespace and punctuation" {
  let text = " Hello, World! \t"
  let inline = Inline::Text(Node::new(text))
  inspect!(inline.id(), content="hello-world")
}

///|
test "inline id with underscore and dash" {
  let text = "hello_world-test"
  let inline = Inline::Text(Node::new(text))
  inspect!(inline.id(), content="hello_world-test")
}

///|
test "inline id with mixed case and punctuation" {
  let text = "Hello, World! This is a Test."
  let inline = Inline::Text(Node::new(text))
  inspect!(inline.id(), content="hello-world-this-is-a-test")
}

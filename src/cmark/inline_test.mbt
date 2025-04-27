///|
test "InlineAutolink::new with link" {
  let meta = @rami3l/cmark/cmark_base.Meta::none()
  let link = Node::new("example.com", meta~)
  let autolink = InlineAutolink::new(link)
  inspect!(autolink.is_email, content="false")
  inspect!(autolink.link.v, content="example.com")
}

///|
test "Inline::is_empty checks if inline content is empty" {
  let meta = @rami3l/cmark/cmark_base.Meta::none()

  // Test empty inlines list
  let empty_inlines = Inline::Inlines({ v: Seq::empty(), meta })
  inspect!(empty_inlines.is_empty(), content="true")

  // Test non-empty inlines list
  let text_node = Inline::Text(Node::new("text", meta~))
  let non_empty_inlines = Inline::Inlines({
    v: Seq::from_array([text_node]),
    meta,
  })
  inspect!(non_empty_inlines.is_empty(), content="false")

  // Test empty text
  let empty_text = Inline::Text(Node::new("", meta~))
  inspect!(empty_text.is_empty(), content="true")

  // Test non-empty text
  let non_empty_text = Inline::Text(Node::new("Some text", meta~))
  inspect!(non_empty_text.is_empty(), content="false")

  // Test other cases which always return false
  let al_node = Node::new(InlineAutolink::new(Node::new("test", meta~)), meta~)
  let autolink = Inline::Autolink(al_node)
  inspect!(autolink.is_empty(), content="false")
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

///|
test "Inline::normalize with Emphasis type" {
  let meta = @cmark_base.Meta::none()

  // Create a nested Text inside Emphasis
  let text = Inline::Text(Node::new("emphasized text", meta~))
  let emphasis = Inline::Emphasis(
    Node::new({ delim: '*', inline: text }, meta~),
  )

  // Normalize and check result
  let normalized = emphasis.normalize()
  @json.inspect!(normalized, content={
    "$tag": "Emphasis",
    "0": [
      { "delim": "*", "inline": { "$tag": "Text", "0": ["emphasized text"] } },
    ],
  })
}

///|
test "Inline::normalize with StrongEmphasis type" {
  let meta = @cmark_base.Meta::none()

  // Create a nested Text inside StrongEmphasis
  let text = Inline::Text(Node::new("strong text", meta~))
  let strong = Inline::StrongEmphasis(
    Node::new({ delim: '*', inline: text }, meta~),
  )

  // Normalize and check result
  let normalized = strong.normalize()
  @json.inspect!(normalized, content={
    "$tag": "StrongEmphasis",
    "0": [{ "delim": "*", "inline": { "$tag": "Text", "0": ["strong text"] } }],
  })
}

///|
test "InlineBreak::new creates a break with specified parameters" {
  let meta = @cmark_base.Meta::none()
  let layout_before = Node::new("  ", meta~)
  let layout_after = Node::new("   ", meta~)
  let break_type = InlineBreakType::Hard
  let line_break = InlineBreak::new(layout_before~, layout_after~, break_type)
  inspect!(line_break.ty, content="Hard")
  inspect!(line_break.layout_before.v, content="  ")
  inspect!(line_break.layout_after.v, content="   ")
}

///|
test "Inline::id with null character" {
  let meta = @cmark_base.Meta::none()

  // Create text with null character
  let text = Inline::Text(Node::new("text\u{0000}more", meta~))

  // Should replace null with replacement character in output
  let id = text.id()
  inspect!(id, content="text�more")
}

///|
test "Inline::normalize with Link type" {
  let meta = @cmark_base.Meta::none()

  // Create a link with text inside
  let text = Inline::Text(Node::new("link text", meta~))
  let link_def = Node::new(@rami3l/cmark/cmark.LinkDefinition::new(), meta~)
  let reference = ReferenceKind::Inline(link_def)
  let link = Inline::Link(Node::new({ text, reference }, meta~))

  // Normalize should recursively normalize the link's text
  let normalized = link.normalize()

  // Check that the result is correctly normalized
  inspect!(normalized.is_empty(), content="false")
}

///|
test "Inline::normalize with more complex Inlines structure" {
  let meta = @cmark_base.Meta::none()

  // Create two Text nodes to be concatenated
  let text1 = Inline::Text(Node::new("first", meta~))
  let text2 = Inline::Text(Node::new("second", meta~))

  // Create a nested Inlines with another Inlines inside
  let inner_inlines = Inline::Inlines(
    Node::new(Seq::from_array([text1]), meta~),
  )
  let outer_inlines = Inline::Inlines(
    Node::new(Seq::from_array([inner_inlines, text2]), meta~),
  )

  // The normalization should flatten the nested Inlines and concat consecutive texts
  let normalized = outer_inlines.normalize()
  @json.inspect!(normalized, content={ "$tag": "Text", "0": ["firstsecond"] })
}

///|
test "Inline::normalize with nested structures" {
  let meta = @cmark_base.Meta::none()

  // Test with Image type
  let text = Inline::Text(Node::new("alt text", meta~))
  let link_def = Node::new(@rami3l/cmark/cmark.LinkDefinition::new(), meta~)
  let reference = ReferenceKind::Inline(link_def)
  let link = InlineLink::new(text, reference)
  let image = Inline::Image(Node::new(link, meta~))

  // Normalize and check that it correctly processed nested elements
  let normalized = image.normalize()
  @json.inspect!(normalized, content={
    "$tag": "Image",
    "0": [
      {
        "text": { "$tag": "Text", "0": ["alt text"] },
        "reference": {
          "$tag": "Inline",
          "0": [
            {
              "layout": {
                "indent": 0,
                "angled_dest": false,
                "before_dest": [],
                "after_dest": [],
                "title_open_delim": "\"",
                "after_title": [],
              },
            },
          ],
        },
      },
    ],
  })
}

///|
test "Inline::normalize with ExtStrikethrough type" {
  let meta = @cmark_base.Meta::none()

  // Create inner text
  let text = Inline::Text(Node::new("strikethrough", meta~))

  // Create strikethrough with the text
  let strikethrough = Inline::ExtStrikethrough(Node::new(text, meta~))

  // Normalize and check
  let normalized = strikethrough.normalize()
  inspect!(
    normalized,
    content=
      #|ExtStrikethrough(Node::new(InlineStrikethrough(Text(Node::new("strikethrough")))))
    ,
  )
}

///|
test "Inline::normalize with singleton list" {
  let meta = @cmark_base.Meta::none()

  // Create inner text
  let text = Inline::Text(Node::new("single item", meta~))

  // Create inlines with just one item
  let inlines = Inline::Inlines(Node::new(Seq::from_array([text]), meta~))

  // Normalize should return just the inner item
  let normalized = inlines.normalize()
  inspect!(normalized, content="Text(Node::new(\"single item\"))")
}

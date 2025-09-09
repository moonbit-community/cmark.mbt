///|
test "InlineAutolink::new with link" {
  let meta = @rami3l/cmark/cmark_base.Meta::none()
  let link = @cmark.Node::new("example.com", meta~)
  let autolink = @cmark.InlineAutolink::new(link)
  inspect(autolink.is_email, content="false")
  inspect(autolink.link.v, content="example.com")
}

///|
test "Inline::is_empty checks if inline content is empty" {
  let meta = @rami3l/cmark/cmark_base.Meta::none()

  // Test empty inlines list
  let empty_inlines = @cmark.Inline::Inlines({ v: @cmark.Seq::empty(), meta })
  inspect(empty_inlines.is_empty(), content="true")

  // Test non-empty inlines list
  let text_node = @cmark.Inline::Text(@cmark.Node::new("text", meta~))
  let non_empty_inlines = @cmark.Inline::Inlines({
    v: @cmark.Seq::from_array([text_node]),
    meta,
  })
  inspect(non_empty_inlines.is_empty(), content="false")

  // Test empty text
  let empty_text = @cmark.Inline::Text(@cmark.Node::new("", meta~))
  inspect(empty_text.is_empty(), content="true")

  // Test non-empty text
  let non_empty_text = @cmark.Inline::Text(@cmark.Node::new("Some text", meta~))
  inspect(non_empty_text.is_empty(), content="false")

  // Test other cases which always return false
  let al_node = @cmark.Node::new(
    @cmark.InlineAutolink::new(@cmark.Node::new("test", meta~)),
    meta~,
  )
  let autolink = @cmark.Inline::Autolink(al_node)
  inspect(autolink.is_empty(), content="false")
}

///|
test "InlineCodeSpan::code with empty content" {
  let empty_code = @cmark.InlineCodeSpan::from_string("")
  inspect(empty_code.code(), content="")
}

///|
test "is_unsafe for data URLs" {
  // Test data URL with image/gif
  let data_url = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"
  inspect(@cmark.InlineLink::is_unsafe(data_url), content="false")

  // Test data URL with missing comma after base64
  let invalid_data = "data:image/gif;base64"
  inspect(@cmark.InlineLink::is_unsafe(invalid_data), content="true")

  // Test data URL with no semicolon
  let data_no_semi = "data:image/gif,content"
  inspect(@cmark.InlineLink::is_unsafe(data_no_semi), content="false")
}

///|
test "is_unsafe for data URLs with various media types" {
  // Test data URL with allowed image types
  let data_gif = "data:image/gif,R0lGO"
  let data_png = "data:image/png,iVBOR"
  let data_jpeg = "data:image/jpeg,/9j/4"
  let data_webp = "data:image/webp,UklGR"
  inspect(@cmark.InlineLink::is_unsafe(data_gif), content="false")
  inspect(@cmark.InlineLink::is_unsafe(data_png), content="false")
  inspect(@cmark.InlineLink::is_unsafe(data_jpeg), content="false")
  inspect(@cmark.InlineLink::is_unsafe(data_webp), content="false")
}

///|
test "referenced_label with inline reference" {
  let text = @cmark.Inline::empty()
  let link_def = @cmark.Node::new(@cmark.LinkDefinition::new())
  let inline_ref = @cmark.ReferenceKind::Inline(link_def)
  let link = @cmark.InlineLink::new(text, inline_ref)
  inspect(link.referenced_label(), content="None")
}

///|
test "inline id with text containing backticks" {
  let inline = @cmark.Inline::CodeSpan(
    @cmark.Node::new({
      backticks: 1,
      code_layout: @cmark.Seq::from_array([
        { blanks: "", node: @cmark.Node::new("`text`") },
      ]),
    }),
  )
  inspect(inline.id(), content="text")
}

///|
test "inline id with whitespace and punctuation" {
  let text = " Hello, World! \t"
  let inline = @cmark.Inline::Text(@cmark.Node::new(text))
  inspect(inline.id(), content="hello-world")
}

///|
test "inline id with underscore and dash" {
  let text = "hello_world-test"
  let inline = @cmark.Inline::Text(@cmark.Node::new(text))
  inspect(inline.id(), content="hello_world-test")
}

///|
test "inline id with mixed case and punctuation" {
  let text = "Hello, World! This is a Test."
  let inline = @cmark.Inline::Text(@cmark.Node::new(text))
  inspect(inline.id(), content="hello-world-this-is-a-test")
}

///|
test "Inline::normalize with Emphasis type" {
  let meta = @cmark_base.Meta::none()

  // Create a nested Text inside Emphasis
  let text = @cmark.Inline::Text(@cmark.Node::new("emphasized text", meta~))
  let emphasis = @cmark.Inline::Emphasis(
    @cmark.Node::new({ delim: '*', inline: text }, meta~),
  )

  // Normalize and check result
  let normalized = emphasis.normalize()
  @json.inspect(normalized, content=[
    "Emphasis",
    [{ "delim": "*", "inline": ["Text", ["emphasized text"]] }],
  ])
}

///|
test "Inline::normalize with StrongEmphasis type" {
  let meta = @cmark_base.Meta::none()

  // Create a nested Text inside StrongEmphasis
  let text = @cmark.Inline::Text(@cmark.Node::new("strong text", meta~))
  let strong = @cmark.Inline::StrongEmphasis(
    @cmark.Node::new({ delim: '*', inline: text }, meta~),
  )

  // Normalize and check result
  let normalized = strong.normalize()
  @json.inspect(normalized, content=[
    "StrongEmphasis",
    [{ "delim": "*", "inline": ["Text", ["strong text"]] }],
  ])
}

///|
test "InlineBreak::new creates a break with specified parameters" {
  let meta = @cmark_base.Meta::none()
  let layout_before = @cmark.Node::new("  ", meta~)
  let layout_after = @cmark.Node::new("   ", meta~)
  let break_type = @cmark.InlineBreakType::Hard
  let line_break = @cmark.InlineBreak::new(
    layout_before~,
    layout_after~,
    break_type,
  )
  inspect(line_break.ty, content="Hard")
  inspect(line_break.layout_before.v, content="  ")
  inspect(line_break.layout_after.v, content="   ")
}

///|
test "Inline::id with null character" {
  let meta = @cmark_base.Meta::none()

  // Create text with null character
  let text = @cmark.Inline::Text(@cmark.Node::new("text\u{0000}more", meta~))

  // Should replace null with replacement character in output
  let id = text.id()
  inspect(id, content="text�more")
}

///|
test "Inline::normalize with Link type" {
  let meta = @cmark_base.Meta::none()

  // Create a link with text inside
  let text = @cmark.Inline::Text(@cmark.Node::new("link text", meta~))
  let link_def = @cmark.Node::new(
    @rami3l/cmark/cmark.LinkDefinition::new(),
    meta~,
  )
  let reference = @cmark.ReferenceKind::Inline(link_def)
  let link = @cmark.Inline::Link(@cmark.Node::new({ text, reference }, meta~))

  // Normalize should recursively normalize the link's text
  let normalized = link.normalize()

  // Check that the result is correctly normalized
  inspect(normalized.is_empty(), content="false")
}

///|
test "Inline::normalize with more complex Inlines structure" {
  let meta = @cmark_base.Meta::none()

  // Create two Text nodes to be concatenated
  let text1 = @cmark.Inline::Text(@cmark.Node::new("first", meta~))
  let text2 = @cmark.Inline::Text(@cmark.Node::new("second", meta~))

  // Create a nested Inlines with another Inlines inside
  let inner_inlines = @cmark.Inline::Inlines(
    @cmark.Node::new(@cmark.Seq::from_array([text1]), meta~),
  )
  let outer_inlines = @cmark.Inline::Inlines(
    @cmark.Node::new(@cmark.Seq::from_array([inner_inlines, text2]), meta~),
  )

  // The normalization should flatten the nested Inlines and concat consecutive texts
  let normalized = outer_inlines.normalize()
  @json.inspect(normalized, content=["Text", ["firstsecond"]])
}

///|
test "Inline::normalize with nested structures" {
  let meta = @cmark_base.Meta::none()

  // Test with Image type
  let text = @cmark.Inline::Text(@cmark.Node::new("alt text", meta~))
  let link_def = @cmark.Node::new(
    @rami3l/cmark/cmark.LinkDefinition::new(),
    meta~,
  )
  let reference = @cmark.ReferenceKind::Inline(link_def)
  let link = @cmark.InlineLink::new(text, reference)
  let image = @cmark.Inline::Image(@cmark.Node::new(link, meta~))

  // Normalize and check that it correctly processed nested elements
  let normalized = image.normalize()
  @json.inspect(normalized, content=[
    "Image",
    [
      {
        "text": ["Text", ["alt text"]],
        "reference": [
          "Inline",
          [
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
        ],
      },
    ],
  ])
}

///|
test "Inline::normalize with ExtStrikethrough type" {
  let meta = @cmark_base.Meta::none()

  // Create inner text
  let text = @cmark.Inline::Text(@cmark.Node::new("strikethrough", meta~))

  // Create strikethrough with the text
  let strikethrough = @cmark.Inline::ExtStrikethrough(
    @cmark.Node::new(text, meta~),
  )

  // Normalize and check
  let normalized = strikethrough.normalize()
  inspect(
    normalized,
    content=(
      #|ExtStrikethrough(Node::new(InlineStrikethrough(Text(Node::new("strikethrough")))))
    ),
  )
}

///|
test "Inline::normalize with complex structure - has nested inlines" {
  let meta = @cmark_base.Meta::none()

  // Create a nested structure with Inlines
  let text1 = @cmark.Inline::Text(@cmark.Node::new("text1", meta~))
  let nested = @cmark.Inline::Inlines(
    @cmark.Node::new(@cmark.Seq::from_array([text1]), meta~),
  )
  let text2 = @cmark.Inline::Text(@cmark.Node::new("text2", meta~))
  let outer = @cmark.Inline::Inlines(
    @cmark.Node::new(@cmark.Seq::from_array([nested, text2]), meta~),
  )

  // Normalize should flatten nested Inlines
  let normalized = outer.normalize()
  inspect(normalized.is_empty(), content="false")
}

///|
test "InlineCodeSpan::from_string with simple content" {
  // Test with string that needs spaces (contains backticks)
  let code_with_backticks = @cmark.InlineCodeSpan::from_string("`code`")
  inspect(code_with_backticks.code(), content="`code`")
}

///|
test "InlineCodeSpan::from_string with empty string" {
  // Test with empty string
  let empty_code = @cmark.InlineCodeSpan::from_string("")
  inspect(empty_code.code(), content="")
}

///|
test "InlineCodeSpan::from_string with newlines" {
  let meta = @cmark_base.Meta::none()
  // Test with string containing newlines
  let code_with_newlines = @cmark.InlineCodeSpan::from_string(
    meta~,
    "code\nwith\nnewlines",
  )
  inspect(code_with_newlines.code(), content="code with newlines")

  // Test with CRLF
  let code_with_crlf = @cmark.InlineCodeSpan::from_string(
    meta~,
    "code\r\nwith\r\ncrlf",
  )
  inspect(code_with_crlf.code(), content="code with crlf")
}

///|
test "InlineCodeSpan::new creates a code span directly" {
  let meta = @cmark_base.Meta::none()
  let tight = @cmark.Tight::{
    blanks: "",
    node: @cmark.Node::new("code", meta~),
  }
  let code_layout = @cmark.Seq::from_array([tight])

  // Create with explicit backtick count
  let code_span = @cmark.InlineCodeSpan::new(backticks=2, code_layout)
  inspect(code_span.backticks, content="2")
  inspect(code_span.code(), content="code")
}

///|
test "Inline::to_plain_text with hard line break" {
  let meta = @cmark_base.Meta::none()
  let hard_break = @cmark.Inline::Break(
    @cmark.Node::new(
      {
        layout_before: @cmark.Node::new("", meta~),
        ty: @cmark.InlineBreakType::Hard,
        layout_after: @cmark.Node::new("", meta~),
      },
      meta~,
    ),
  )
  let result = hard_break.to_plain_text(break_on_soft=false)
  inspect(result.length(), content="2")
}

///|
test "Inline::to_plain_text with soft line break" {
  let meta = @cmark_base.Meta::none()
  let soft_break = @cmark.Inline::Break(
    @cmark.Node::new(
      {
        layout_before: @cmark.Node::new("", meta~),
        ty: @cmark.InlineBreakType::Soft,
        layout_after: @cmark.Node::new("", meta~),
      },
      meta~,
    ),
  )

  // With break_on_soft=true
  let result_true = soft_break.to_plain_text(break_on_soft=true)
  inspect(result_true.length(), content="2")

  // With break_on_soft=false
  let result_false = soft_break.to_plain_text(break_on_soft=false)
  inspect(result_false.length(), content="1")
}

///|
test "Inline::to_plain_text with autolink" {
  let meta = @cmark_base.Meta::none()
  let link_node = @cmark.Node::new("example.com", meta~)
  let autolink = @cmark.Inline::Autolink(
    @cmark.Node::new(@cmark.InlineAutolink::new(link_node), meta~),
  )
  let result = autolink.to_plain_text(break_on_soft=false)
  inspect(result.length(), content="1")
}

///|
test "Inline::to_plain_text with emphasis and strong emphasis" {
  let meta = @cmark_base.Meta::none()
  let text = @cmark.Inline::Text(@cmark.Node::new("emphasized", meta~))

  // Test with Emphasis
  let emphasis = @cmark.Inline::Emphasis(
    @cmark.Node::new({ delim: '*', inline: text }, meta~),
  )
  let emphasis_result = emphasis.to_plain_text(break_on_soft=false)
  inspect(emphasis_result.length(), content="1")

  // Test with StrongEmphasis
  let strong = @cmark.Inline::StrongEmphasis(
    @cmark.Node::new({ delim: '*', inline: text }, meta~),
  )
  let strong_result = strong.to_plain_text(break_on_soft=false)
  inspect(strong_result.length(), content="1")
}

///|
test "Inline::to_plain_text with inlines and link" {
  let meta = @cmark_base.Meta::none()

  // Test with nested Inlines
  let text1 = @cmark.Inline::Text(@cmark.Node::new("text1", meta~))
  let text2 = @cmark.Inline::Text(@cmark.Node::new("text2", meta~))
  let inlines = @cmark.Inline::Inlines(
    @cmark.Node::new(@cmark.Seq::from_array([text1, text2]), meta~),
  )
  let inlines_result = inlines.to_plain_text(break_on_soft=false)
  inspect(inlines_result.length(), content="1")

  // Test with Link
  let link_def = @cmark.Node::new(@cmark.LinkDefinition::new(), meta~)
  let reference = @cmark.ReferenceKind::Inline(link_def)
  let link = @cmark.Inline::Link(
    @cmark.Node::new({ text: text1, reference }, meta~),
  )
  let link_result = link.to_plain_text(break_on_soft=false)
  inspect(link_result.length(), content="1")
}

///|
test "Inline::to_plain_text with raw html and strikethrough" {
  let meta = @cmark_base.Meta::none()

  // Test with RawHtml
  let raw_content = @cmark.Seq::from_array([@cmark.Tight::empty(meta~)])
  let raw_html = @cmark.Inline::RawHtml(@cmark.Node::new(raw_content, meta~))
  let raw_html_result = raw_html.to_plain_text(break_on_soft=false)
  inspect(raw_html_result.length(), content="1")

  // Test with Strikethrough
  let text = @cmark.Inline::Text(@cmark.Node::new("strikethrough", meta~))
  let strikethrough = @cmark.Inline::ExtStrikethrough(
    @cmark.Node::new(text, meta~),
  )
  let strikethrough_result = strikethrough.to_plain_text(break_on_soft=false)
  inspect(strikethrough_result.length(), content="1")
}

///|
test "Inline::to_plain_text with math span" {
  let meta = @cmark_base.Meta::none()

  // Test with MathSpan
  let tight = @cmark.Tight::{ blanks: "", node: @cmark.Node::new("x^2", meta~) }
  let tex_layout = @cmark.Seq::from_array([tight])
  let math_span = @cmark.Inline::ExtMathSpan(
    @cmark.Node::new({ display: false, tex_layout }, meta~),
  )
  let math_result = math_span.to_plain_text(break_on_soft=false)
  inspect(math_result.length(), content="1")
}

///|
test "Inline::normalize with singleton list" {
  let meta = @cmark_base.Meta::none()

  // Create inner text
  let text = @cmark.Inline::Text(@cmark.Node::new("single item", meta~))

  // Create inlines with just one item
  let inlines = @cmark.Inline::Inlines(
    @cmark.Node::new(@cmark.Seq::from_array([text]), meta~),
  )

  // Normalize should return just the inner item
  let normalized = inlines.normalize()
  inspect(normalized, content="Text(Node::new(\"single item\"))")
}

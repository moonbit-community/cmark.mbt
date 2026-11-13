///|
test "plain" {
  let source =
    #|Basic tests
    #|===========
    #|Basic tests for all CommonMark constructs.
  guard Doc::from_string(source).block
    is Blocks({ v: Seq([Heading(heading), Paragraph(paragraph)]), .. }) else {
    fail("expected a setext heading followed by a paragraph")
  }
  guard heading.v.layout is Setext(layout) else {
    fail("expected a setext heading")
  }
  @test.assert_eq((heading.v.level, layout.underline_count.v), (1, 11))
  guard heading.v.inline is Text(title) else { fail("expected heading text") }
  guard paragraph.v.inline is Text(text) else {
    fail("expected paragraph text")
  }
  @test.assert_eq(title.v, "Basic tests")
  @test.assert_eq(text.v, "Basic tests for all CommonMark constructs.")
}

///|
test "complex ref definitions" {
  let source =
    #|  to [c    d][]
    #|> [c d]: /ha "Multi
    #|>   line titles"
  let doc = Doc::from_string(source)
  guard doc.block
    is Blocks({ v: Seq([Paragraph(paragraph), BlockQuote(quote)]), .. }) else {
    fail("expected a paragraph and quoted reference definition")
  }
  @test.assert_eq(paragraph.v.leading_indent, 2)
  guard paragraph.v.inline
    is Inlines({ v: Seq([Text(prefix), Link(link)]), .. }) else {
    fail("expected a collapsed reference link")
  }
  @test.assert_eq(prefix.v, "to ")
  guard link.v.text is Text(text) else { fail("expected link text") }
  @test.assert_eq(text.v, "c    d")
  guard link.v.reference is Ref(Collapsed, reference, defined) else {
    fail("expected a collapsed reference")
  }
  @test.assert_eq((reference.key, defined.key), ("c d", "c d"))
  guard quote.v.block is LinkRefDefinition(definition) else {
    fail("expected a reference definition inside the quote")
  }
  @test.assert_eq(definition.v.dest.map(fn(dest) { dest.v }), Some("/ha"))
  guard definition.v.title is Some(title) else {
    fail("expected a multiline title")
  }
  @test.assert_eq(title.to_array().map(fn(line) { line.node.v }), [
    "Multi", "line titles",
  ])
  @test.assert_eq(doc.defs.length(), 1)
  guard link.v.reference_definition(doc.defs) is Some(LinkDef(registered)) else {
    fail("expected the link to resolve to the quoted definition")
  }
  @test.assert_eq(registered.v, definition.v)
}

///|
test "HTML block" {
  let source =
    #|<div>
    #|  hello
    #|</div>
    #|
    #| world
  guard Doc::from_string(source).block is Blocks(blocks) else {
    fail("expected multiple blocks")
  }
  guard blocks.v.to_array()
    is [HtmlBlock(html), BlankLine(_), Paragraph(paragraph)] else {
    fail("expected HTML followed by a separate paragraph")
  }
  @test.assert_eq(html.v.0.to_array().map(fn(line) { line.v }), [
    "<div>", "  hello", "</div>",
  ])
  guard paragraph.v.inline is Text(text) else {
    fail("expected paragraph text")
  }
  @test.assert_eq(text.v, "world")
}

///|
test "should tokenize inline image across multiple lines" {
  let doc =
    #|This is an ![inline image](
    #|  /heyho    (The
    #|    multiline title))
  debug_inspect(
    tokenize_only(doc),
    content=(
      #|(
      #|  CloserIndex({ RightBrack: [25], RightParen: [64, 65] }),
      #|  Tokens(
      #|    <Deque:
      #|      [
      #|        LinkStart({ start: 11, image: true }),
      #|        RightBrack({ start: 25 }),
      #|        Newline(
      #|          {
      #|            start: 27,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(2, 0), first: 28, last: 43 },
      #|          },
      #|        ),
      #|        Newline(
      #|          {
      #|            start: 44,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(3, 0), first: 45, last: 65 },
      #|          },
      #|        ),
      #|      ]>,
      #|  ),
      #|  { pos: LinePos(1, 0), first: 0, last: 26 },
      #|)
    ),
  )
}

///|
/// https://github.com/moonbit-community/cmark/issues/41
test "should parse normal raw HTML block" {
  let source =
    #|# My Document
    #|
    #|This is a standard paragraph in Markdown.
    #|
    #|<div class="custom-container">
    #|  <h2>Section Title</h2>
    #|  <p>This is a paragraph inside a custom HTML container.</p>
    #|</div>
  guard Doc::from_string(source).block is Blocks(blocks) else {
    fail("expected multiple blocks")
  }
  guard blocks.v.to_array()
    is [
      Heading(heading),
      BlankLine(_),
      Paragraph(paragraph),
      BlankLine(_),
      HtmlBlock(html),
    ] else {
    fail("expected a heading, paragraph and raw HTML block")
  }
  guard heading.v.inline is Text(title) else { fail("expected heading text") }
  guard paragraph.v.inline is Text(text) else {
    fail("expected paragraph text")
  }
  @test.assert_eq((heading.v.level, title.v), (1, "My Document"))
  @test.assert_eq(text.v, "This is a standard paragraph in Markdown.")
  @test.assert_eq(html.v.0.to_array().map(fn(line) { line.v }), [
    "<div class=\"custom-container\">", "  <h2>Section Title</h2>", "  <p>This is a paragraph inside a custom HTML container.</p>",
    "</div>",
  ])
}

///|
/// https://github.com/moonbit-community/cmark/issues/41
test "should parse normal code block" {
  let source =
    #| Checks if all elements in the array view match the condition.
    #| # Example
    #| ```
    #| let v = [1, 4, 6, 8, 9]
    #| assert_false!(v[:].all(fn(elem) { elem % 2 == 0 }))
    #| assert_true!(v[1:4].all(fn(elem) { elem % 2 == 0 }))
    #| ```
  guard Doc::from_string(source).block is Blocks(blocks) else {
    fail("expected multiple blocks")
  }
  guard blocks.v.to_array()
    is [Paragraph(paragraph), Heading(heading), CodeBlock(code)] else {
    fail("expected a paragraph, heading and fenced code block")
  }
  guard paragraph.v.inline is Text(text) else {
    fail("expected paragraph text")
  }
  @test.assert_eq(
    text.v,
    "Checks if all elements in the array view match the condition.",
  )
  guard heading.v.inline is Text(title) else { fail("expected heading text") }
  @test.assert_eq((heading.v.level, title.v), (1, "Example"))
  guard code.v.layout is Fenced(_) else { fail("expected fenced code") }
  @test.assert_eq(code.v.code.to_array().map(fn(line) { line.v }), [
    "let v = [1, 4, 6, 8, 9]", "assert_false!(v[:].all(fn(elem) { elem % 2 == 0 }))",
    "assert_true!(v[1:4].all(fn(elem) { elem % 2 == 0 }))",
  ])
}

///|
test "should parse link refs" {
  let source =
    #|This is an [Extism PDK] that can be used to write [Extism Plug-ins].
    #|
    #|[Extism PDK]: https://extism.org/docs/concepts/pdk
    #|[Extism Plug-ins]: https://extism.org/docs/concepts/plug-in
  let doc = Doc::from_string(source)
  guard doc.block is Blocks(blocks) else { fail("expected multiple blocks") }
  guard blocks.v.to_array()
    is [
      Paragraph(paragraph),
      BlankLine(_),
      LinkRefDefinition(_),
      LinkRefDefinition(_),
    ] else {
    fail("expected a paragraph and two reference definitions")
  }
  guard paragraph.v.inline is Inlines(inlines) else {
    fail("expected inline elements")
  }
  guard inlines.v.to_array()
    is [Text(prefix), Link(first), Text(separator), Link(second), Text(suffix)] else {
    fail("expected two shortcut reference links")
  }
  @test.assert_eq(
    (prefix.v, separator.v, suffix.v),
    ("This is an ", " that can be used to write ", "."),
  )
  @test.assert_eq(doc.defs.length(), 2)
  for
    (link, text, key, destination) in [
      (
        first.v,
        "Extism PDK",
        "extism pdk",
        "https://extism.org/docs/concepts/pdk",
      ),
      (
        second.v,
        "Extism Plug-ins",
        "extism plug-ins",
        "https://extism.org/docs/concepts/plug-in",
      ),
    ] {
    guard link.text is Text(label) else { fail("expected link text") }
    @test.assert_eq(label.v, text)
    guard link.reference is Ref(Shortcut, reference, defined) else {
      fail("expected a shortcut reference")
    }
    @test.assert_eq((reference.key, defined.key), (key, key))
    guard link.reference_definition(doc.defs) is Some(LinkDef(definition)) else {
      fail("expected a resolved reference")
    }
    @test.assert_eq(
      definition.v.dest.map(fn(dest) { dest.v }),
      Some(destination),
    )
  }
}

///|
test "should parse indented code block" {
  let source =
    #|The indented code block: 
    #|
    #|    a b c d 
    #|     a b c d
    #|     a b c d
    #|      
    #|
    #|    a
    #|       a b c
  guard Doc::from_string(source).block is Blocks(blocks) else {
    fail("expected multiple blocks")
  }
  guard blocks.v.to_array()
    is [Paragraph(paragraph), BlankLine(_), CodeBlock(code)] else {
    fail("expected a paragraph followed by indented code")
  }
  guard paragraph.v.inline is Text(text) else {
    fail("expected paragraph text")
  }
  @test.assert_eq(text.v, "The indented code block:")
  guard code.v.layout is Indented else { fail("expected indented code") }
  @test.assert_eq(code.v.code.to_array().map(fn(line) { line.v }), [
    "a b c d ", " a b c d", " a b c d", "  ", "", "a", "   a b c",
  ])
}

///|
test "should parse quoted bullets" {
  let source =
    #|> Quoted bullets
    #|> * Is this important ? 
    #|* Well it's in the spec
    #|*
    #|Empty list item above
  guard Doc::from_string(source).block
    is Blocks({ v: Seq([BlockQuote(quote), List(list), Paragraph(after)]), .. }) else {
    fail("expected separate quoted and unquoted lists")
  }
  guard quote.v.block
    is Blocks({ v: Seq([Paragraph(paragraph), List(quoted)]), .. }) else {
    fail("expected a paragraph and list inside the quote")
  }
  guard paragraph.v.inline is Text(text) else { fail("expected quoted text") }
  @test.assert_eq(text.v, "Quoted bullets")
  guard quoted.v.ty is Unordered('*') else { fail("expected quoted bullets") }
  @test.assert_eq(quoted.v.tight, true)
  guard quoted.v.items.to_array()
    is [
      { v: { block: Paragraph({ v: { inline: Text(text), .. }, .. }), .. }, .. },
    ] else {
    fail("expected a quoted list item")
  }
  @test.assert_eq(text.v, "Is this important ?")
  guard list.v.ty is Unordered('*') else { fail("expected unquoted bullets") }
  @test.assert_eq(list.v.tight, true)
  guard list.v.items.to_array()
    is [
      { v: { block: Paragraph({ v: { inline: Text(text), .. }, .. }), .. }, .. },
      { v: { block: BlankLine(_), .. }, .. },
    ] else {
    fail("expected one text item and one empty item outside the quote")
  }
  @test.assert_eq(text.v, "Well it's in the spec")
  guard after.v.inline is Text(text) else {
    fail("expected the following paragraph")
  }
  @test.assert_eq(text.v, "Empty list item above")
}

///|
test "should parse list item with multiple inlines" {
  let source =
    #|4.  What is the exact rule for determining when list items get
    #|    wrapped in `<p>` tags?  Can a list be partially "loose" and partially
    #|    "tight"?  What should we do with a list like this?
    #|
    #|    ``` markdown
    #|    1. one
    #|
    #|    2. two
    #|    3. three
    #|    ```
    #|
    #|    Or this?
    #|
    #|    ``` markdown
    #|    1.  one
    #|        - a
    #|
    #|        - b
    #|    2.  two
    #|    ```
    #|
    #|    (There are some relevant comments by John Gruber
    #|    [here](https://web.archive.org/web/20170611172104/http://article.gmane.org/gmane.text.markdown.general/2554).)
  guard Doc::from_string(source).block is List(list) else {
    fail("expected a list")
  }
  guard list.v.ty is Ordered(4, '.') else {
    fail("expected an ordered list starting at four")
  }
  @test.assert_eq(list.v.tight, false)
  guard list.v.items.to_array() is [item] else {
    fail("expected a single list item")
  }
  @test.assert_eq((item.v.before_marker, item.v.after_marker), (0, 2))
  guard item.v.block is Blocks(blocks) else {
    fail("expected multiple blocks in the item")
  }
  guard blocks.v.to_array()
    is [
      Paragraph(first),
      BlankLine(_),
      CodeBlock(first_code),
      BlankLine(_),
      Paragraph(middle),
      BlankLine(_),
      CodeBlock(second_code),
      BlankLine(_),
      Paragraph(last),
    ] else {
    fail("expected paragraphs and fenced code inside the list item")
  }
  guard first.v.inline is Inlines(inlines) else {
    fail("expected inline elements")
  }
  guard inlines.v.to_array()
    is [Text(_), Break(_), Text(_), CodeSpan(code), Text(_), Break(_), Text(_)] else {
    fail("expected an inline code span in the opening paragraph")
  }
  @test.assert_eq(code.v.code(), "<p>")
  for code in [first_code.v, second_code.v] {
    guard code.layout is Fenced(_) else { fail("expected fenced code") }
    @test.assert_eq(code.info_string.map(fn(info) { info.v }), Some("markdown"))
  }
  @test.assert_eq(first_code.v.code.to_array().map(fn(line) { line.v }), [
    "1. one", "", "2. two", "3. three",
  ])
  @test.assert_eq(second_code.v.code.to_array().map(fn(line) { line.v }), [
    "1.  one", "    - a", "", "    - b", "2.  two",
  ])
  guard middle.v.inline is Text(text) else {
    fail("expected the middle paragraph")
  }
  @test.assert_eq(text.v, "Or this?")
  guard last.v.inline
    is Inlines({ v: Seq([Text(_), Break(_), Link(link), Text(_)]), .. }) else {
    fail("expected a link in the closing paragraph")
  }
  guard link.v.text is Text(text) else { fail("expected link text") }
  @test.assert_eq(text.v, "here")
  guard link.v.reference is Inline(definition) else {
    fail("expected an inline link")
  }
  @test.assert_eq(
    definition.v.dest.map(fn(dest) { dest.v }),
    Some(
      "https://web.archive.org/web/20170611172104/http://article.gmane.org/gmane.text.markdown.general/2554",
    ),
  )
}

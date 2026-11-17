///|
test "display math shields Markdown in standalone and inline placements" {
  let body =
    #|\llbracket A+B\rrbracket_\gamma
    #| =
    #|# heading
    #|---
    #|> quote
    #|- item
    #|
    #|```code
    #|[label]: /url
  for (before, after) in [("", ""), ("Before ", " after")] {
    let source = before + "$$\n" + body + "\n$$" + after + "\n# After"
    guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) &&
      blocks.v.to_array() is [Paragraph(paragraph), Heading(_)] else {
      fail("expected one math-containing paragraph followed by a heading")
    }
    let math = match paragraph.v.inline {
      ExtMathSpan(math) => math
      Inlines(inlines) => {
        guard inlines.v.to_array()
          is [Text(prefix), ExtMathSpan(math), Text(suffix)] else {
          fail("expected math between the surrounding text")
        }
        @test.assert_eq(prefix.v, before)
        @test.assert_eq(suffix.v, after)
        math
      }
      _ => fail("expected an intact display math environment")
    }
    @test.assert_eq(math.v.display, true)
    @test.assert_eq(math.v.tex_layout.to_array().map(line => line.node.v), [
      "", "\\llbracket A+B\\rrbracket_\\gamma", "=", "# heading", "---", "> quote",
      "- item", "", "```code", "[label]: /url", "",
    ])
  }
}

///|
test "non-math dollar delimiters do not suppress block parsing" {
  guard @cmark.Doc::from_string("$$\nx\n =", strict=false).block is Heading(_) else {
    fail("an unpaired delimiter must remain literal")
  }
  for
    opener in [
      "\\$$", "$$$", "`$$`", "$a $$ b$", "a <span title=\"$$\">b</span>", "[a](https://example.com/$$)",
      "[a](/url \"$$\")", "<https://example.com/$$>",
    ] {
    let source = opener + "\nx\n =\n$$"
    guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) &&
      blocks.v.to_array() is [Heading(_), Paragraph(_)] else {
      fail(
        "literal dollars in non-math inline contexts must not suppress Markdown",
      )
    }
  }
  let source = "$$\nx\n =\n$$"
  guard @cmark.Doc::from_string(source, strict=true).block is Blocks(blocks) &&
    blocks.v.to_array() is [Heading(_), Paragraph(_)] else {
    fail("strict CommonMark parsing must remain unchanged")
  }
}

///|
test "display math in link text uses the inline grammar" {
  let source = "[Before $$\nx\n =\n$$ after](/url)"
  guard @cmark.Doc::from_string(source, strict=false).block
    is Paragraph({ v: { inline: Link(link), .. }, .. }) &&
    link.v.text is Inlines(inlines) &&
    inlines.v.to_array() is [Text(_), ExtMathSpan(math), Text(_)] else {
    fail("expected a link containing an intact display math environment")
  }
  @test.assert_eq(math.v.tex_layout.to_array().map(line => line.node.v), [
    "", "x", "=", "",
  ])
}

///|
test "display math continues inside Markdown containers" {
  for
    (opening, continuation) in [
      ("> $$", "> "),
      ("- $$", "  "),
      ("[^note]: $$", "    "),
      ("> - $$", ">   "),
      ("- > $$", "  > "),
    ] {
    let source = opening +
      "\n" +
      continuation +
      "x\n" +
      continuation +
      "\n" +
      continuation +
      "# TeX\n" +
      continuation +
      "$$"
    let math = for block = @cmark.Doc::from_string(source, strict=false).block {
      match block {
        BlockQuote(quote) => continue quote.v.block
        List(list) => {
          guard list.v.items.to_array() is [item] else {
            fail("expected one list item")
          }
          continue item.v.block
        }
        ExtFootnoteDefinition(footnote) => continue footnote.v.block
        Paragraph({ v: { inline: ExtMathSpan(math), .. }, .. }) => break math
        _ => fail("expected one intact math environment in its containers")
      }
    }
    @test.assert_eq(math.v.display, true)
    @test.assert_eq(math.v.tex_layout.to_array().map(line => line.node.v), [
      "", "x", "", "# TeX", "",
    ])
  }
}

///|
test "math does not extend outer Markdown containers" {
  for opening in ["> $$", "- $$", "[^note]: $$"] {
    let source = opening + "\nx\n\n# Outside\n\n$$"
    guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) else {
      fail("expected the outer container to end before the heading")
    }
    @test.assert_eq(
      blocks.v
      .iter()
      .any(block => {
        block is Heading({ v: { inline: Text({ v: "Outside", .. }), .. }, .. })
      }),
      true,
    )
  }
}

///|
test "dollars in reference definitions are not math openers" {
  let source = "[label]: /$$\nx\n =\n$$"
  guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) &&
    blocks.v.to_array() is [LinkRefDefinition(_), Heading(_), Paragraph(_)] else {
    fail("a reference destination must not suppress the following heading")
  }
}

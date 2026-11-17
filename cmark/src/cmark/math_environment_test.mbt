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
    #|  indented TeX
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
    @test.assert_eq(
      math.v.tex_layout.to_array().map(line => line.node.v).join("\n"),
      "\n" + body + "\n",
    )
  }
}

///|
test "non-math dollar delimiters do not suppress block parsing" {
  guard @cmark.Doc::from_string("$$\nx\n =", strict=false).block is Heading(_) else {
    fail("an unpaired delimiter must remain literal")
  }
  for opener in ["\\$$", "$$$", "`$$`", "$a $$ b$"] {
    let source = opener + "\nx\n =\n$$"
    guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) &&
      blocks.v.to_array() is [Heading(_), Paragraph(_)] else {
      fail(
        "escaped, long-run and code-contained delimiters are not display math",
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
test "display math continues inside Markdown containers" {
  for
    (opening, continuation) in [
      ("> $$", "> "),
      ("> $$", ""),
      ("- $$", "  "),
      ("- $$", ""),
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
    let block = match @cmark.Doc::from_string(source, strict=false).block {
      BlockQuote(quote) => quote.v.block
      List(list) => {
        guard list.v.items.to_array() is [item] else {
          fail("expected one list item")
        }
        item.v.block
      }
      _ => fail("expected the math environment to remain in its container")
    }
    guard block is Paragraph({ v: { inline: ExtMathSpan(math), .. }, .. }) else {
      fail("expected one intact math environment in the container")
    }
    @test.assert_eq(math.v.display, true)
    @test.assert_eq(math.v.tex_layout.to_array().map(line => line.node.v), [
      "", "x", "", "# TeX", "",
    ])
  }
}

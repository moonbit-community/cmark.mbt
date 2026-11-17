///|
test "display math shields block syntax in standalone and inline placements" {
  for (before, after) in [("", ""), ("Before ", " after")] {
    let source = before +
      "$$\n\\llbracket A+B\\rrbracket_\\gamma\n =\n\n# TeX\n$$" +
      after
    guard @cmark.Doc::from_string(source, strict=false).block
      is Paragraph(paragraph) else {
      fail("expected one math-containing paragraph")
    }
    let math = match paragraph.v.inline {
      ExtMathSpan(math) => math
      Inlines(inlines) => {
        guard inlines.v.to_array() is [Text(_), ExtMathSpan(math), Text(_)] else {
          fail("expected math between the surrounding text")
        }
        math
      }
      _ => fail("expected an intact display math environment")
    }
    @test.assert_eq(math.v.display, true)
    @test.assert_eq(math.v.tex_layout.to_array().map(line => line.node.v), [
      "", "\\llbracket A+B\\rrbracket_\\gamma", "=", "", "# TeX", "",
    ])
  }
}

///|
test "literal dollars do not protect a paragraph from block syntax" {
  guard @cmark.Doc::from_string("$$\nx\n =", strict=false).block is Heading(_) else {
    fail("an unpaired delimiter must remain literal")
  }
  for
    opener in [
      "a <span title=\"$$\">b</span>", "[a](https://example.com/$$)", "[label]: /$$",
    ] {
    let source = opener + "\nx\n =\n$$"
    guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) &&
      blocks.v.iter().any(block => block is Heading(_)) else {
      fail("literal dollars must not suppress the Setext heading")
    }
  }
}

///|
test "math blanks do not loosen a quoted list" {
  for blank in [">", ">   "] {
    let source = "> - $$\n>   x\n" + blank + "\n>   $$\n> - after"
    guard @cmark.Doc::from_string(source, strict=false).block
      is BlockQuote(quote) &&
      quote.v.block is List(list) &&
      list.v.items.to_array() is [first, _] &&
      first.v.block is Paragraph({ v: { inline: ExtMathSpan(_), .. }, .. }) else {
      fail("expected math and the following item in the quoted list")
    }
    @test.assert_eq(list.v.tight, true)
  }
}

///|
test "math does not extend outer Markdown containers" {
  for opening in ["> $$", "- $$"] {
    let source = opening + "\n\n# Outside\n\n$$"
    guard @cmark.Doc::from_string(source, strict=false).block is Blocks(blocks) &&
      blocks.v.iter().any(block => block is Heading(_)) else {
      fail("expected the outer container to end before the heading")
    }
  }
}

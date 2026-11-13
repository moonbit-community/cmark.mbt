# `cmark`

This package provides a CommonMark parser in MoonBit, with support for tables, task lists, math blocks, and more.

## Basic Usage

Parse Markdown and inspect the relevant parts of the resulting syntax tree:

```mbt check
///|
test "basic parsing" {
  let input =
    #|# Hello World
    #|
    #|This is a paragraph.
  let doc = @cmark.Doc::from_string(input)
  guard doc.block is Blocks(blocks) else { fail("expected multiple blocks") }
  guard blocks.v.to_array()
    is [Heading(heading), BlankLine(_), Paragraph(paragraph)] else {
    fail("expected a heading followed by a paragraph")
  }
  @test.assert_eq(heading.v.level, 1)
  guard heading.v.inline is Text(title) else { fail("expected heading text") }
  guard paragraph.v.inline is Text(text) else {
    fail("expected paragraph text")
  }
  @test.assert_eq(title.v, "Hello World")
  @test.assert_eq(text.v, "This is a paragraph.")
}
```

## Working with Inline Elements

### Emphasis and Strong Emphasis

```mbt check
///|
test "emphasis and strong emphasis" {
  let doc = @cmark.Doc::from_string("_Emphasis_ and **strong emphasis**")
  guard doc.block is Paragraph(paragraph) else { fail("expected a paragraph") }
  guard paragraph.v.inline is Inlines(inlines) else {
    fail("expected inline elements")
  }
  guard inlines.v.to_array()
    is [Emphasis(emphasis), Text(separator), StrongEmphasis(strong)] else {
    fail("expected emphasis and strong emphasis")
  }
  guard emphasis.v.inline is Text(text) else { fail("expected emphasis text") }
  guard strong.v.inline is Text(strong_text) else {
    fail("expected strong emphasis text")
  }
  @test.assert_eq((emphasis.v.delim, text.v), ('_', "Emphasis"))
  @test.assert_eq(separator.v, " and ")
  @test.assert_eq((strong.v.delim, strong_text.v), ('*', "strong emphasis"))
}
```

### Inline Code and Math

Extensions are enabled with `strict=false`:

```mbt check
///|
test "inline code and math" {
  let input =
    $|$E = mc^2$ in Python: `E = m * (c ** 2)`
  let doc = @cmark.Doc::from_string(input, strict=false)
  guard doc.block is Paragraph(paragraph) else { fail("expected a paragraph") }
  guard paragraph.v.inline is Inlines(inlines) else {
    fail("expected inline elements")
  }
  guard inlines.v.to_array()
    is [ExtMathSpan(math), Text(separator), CodeSpan(code)] else {
    fail("expected inline math and code")
  }
  @test.assert_eq((math.v.display, math.v.tex()), (false, "E = mc^2"))
  @test.assert_eq(separator.v, " in Python: ")
  @test.assert_eq(code.v.code(), "E = m * (c ** 2)")
}
```

## Working with Block-Level Elements

### Headings

```mbt check
///|
test "headings" {
  let doc = @cmark.Doc::from_string("# Level 1")
  guard doc.block is Heading(heading) else { fail("expected a heading") }
  guard heading.v.inline is Text(text) else { fail("expected heading text") }
  @test.assert_eq((heading.v.level, text.v), (1, "Level 1"))
}
```

### Lists

```mbt check
///|
test "lists" {
  let input =
    #|- First item
    #|- Second item
    #|  1. Nested item
  let doc = @cmark.Doc::from_string(input)
  guard doc.block is List(list) else { fail("expected a list") }
  guard list.v.ty is Unordered('-') else { fail("expected an unordered list") }
  guard list.v.items.to_array() is [first, second] else {
    fail("expected two items")
  }
  guard first.v.block is Paragraph({ v: { inline: Text(text), .. }, .. }) else {
    fail("expected the first item's paragraph")
  }
  @test.assert_eq(text.v, "First item")
  guard second.v.block is Blocks(blocks) else { fail("expected a nested list") }
  guard blocks.v.to_array()
    is [Paragraph({ v: { inline: Text(text), .. }, .. }), List(nested)] else {
    fail("expected a paragraph followed by a nested list")
  }
  @test.assert_eq(text.v, "Second item")
  guard nested.v.ty is Ordered(1, '.') else { fail("expected an ordered list") }
  guard nested.v.items.to_array()
    is [
      { v: { block: Paragraph({ v: { inline: Text(text), .. }, .. }), .. }, .. },
    ] else {
    fail("expected the nested item's paragraph")
  }
  @test.assert_eq(text.v, "Nested item")
}
```

### Code Blocks

```mbt check
///|
test "code blocks" {
  let tick3 = "`".repeat(3)
  let input =
    $|\{tick3}moonbit
    $|fn main {
    $|  println("Hello")
    $|}
    $|\{tick3}
  let doc = @cmark.Doc::from_string(input)
  guard doc.block is CodeBlock(code) else { fail("expected a code block") }
  guard code.v.layout is Fenced(_) else { fail("expected fenced code") }
  @test.assert_eq(code.v.info_string.map(fn(info) { info.v }), Some("moonbit"))
  @test.assert_eq(code.v.code.to_array().map(fn(line) { line.v }), [
    "fn main {", "  println(\"Hello\")", "}",
  ])
}
```

### Tables

```mbt check
///|
test "tables" {
  let input =
    #|| Header 1 | Header 2 |
    #||----------|----------|
    #|| Cell 1   | Cell 2   |
  let doc = @cmark.Doc::from_string(input, strict=false)
  guard doc.block is ExtTable(table) else { fail("expected a table") }
  @test.assert_eq(table.v.col_count, 2)
  guard table.v.rows.to_array() is [(header, _), (separator, _), (data, _)] else {
    fail("expected a header, separator and data row")
  }
  guard header.v is Header(cells) else { fail("expected a header row") }
  guard cells.to_array() is [(Text(first), _), (Text(second), _)] else {
    fail("expected two header cells")
  }
  @test.assert_eq((first.v, second.v), ("Header 1", "Header 2"))
  guard separator.v is Sep(columns) else { fail("expected a separator row") }
  guard columns.to_array()
    is [{ v: TableSep((None, 10)), .. }, { v: TableSep((None, 10)), .. }] else {
    fail("expected two unaligned separator cells with ten dashes")
  }
  guard data.v is Data(cells) else { fail("expected a data row") }
  guard cells.to_array() is [(Text(first), _), (Text(second), _)] else {
    fail("expected two data cells")
  }
  @test.assert_eq((first.v, second.v), ("Cell 1", "Cell 2"))
}
```

### Footnotes

```mbt check
///|
test "footnotes" {
  let input =
    #|Text[^1]
    #|
    #|[^1]: Footnote content
  let doc = @cmark.Doc::from_string(input, strict=false)
  guard doc.block is Blocks(blocks) else { fail("expected multiple blocks") }
  guard blocks.v.to_array()
    is [Paragraph(paragraph), BlankLine(_), ExtFootnoteDefinition(footnote)] else {
    fail("expected a footnote reference and definition")
  }
  guard paragraph.v.inline is Inlines(inlines) else {
    fail("expected a footnote reference")
  }
  guard inlines.v.to_array() is [Text(text), Link(reference)] else {
    fail("expected text followed by a footnote reference")
  }
  @test.assert_eq(text.v, "Text")
  @test.assert_eq(
    reference.v.referenced_label().map(fn(label) { label.key }),
    Some("^1"),
  )
  @test.assert_eq(footnote.v.label.key, "^1")
  @test.assert_eq(doc.defs.length(), 1)
  guard doc.defs.get("^1") is Some(FootnoteDef(definition)) else {
    fail("expected a registered footnote definition")
  }
  guard definition.v.block is Paragraph({ v: { inline: Text(text), .. }, .. }) else {
    fail("expected footnote text")
  }
  @test.assert_eq(text.v, "Footnote content")
}
```

## Document Transformation

Use the `Mapper` and `Folder` APIs to transform or traverse documents.

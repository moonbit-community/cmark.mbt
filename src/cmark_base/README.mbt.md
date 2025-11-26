# `cmark_base`

This package provides fundamental CommonMark parsing utilities and data structures for parsing various CommonMark elements.

## Text Location Tracking

The package includes utilities for tracking text locations in source files:

```moonbit
///|
test "text location handling" {
  let loc = @cmark_base.TextLoc::{
    file: "test.md",
    first_ccode: 0,
    last_ccode: 10,
    first_line: LinePos(1, 0),
    last_line: LinePos(1, 10),
  }
  let after_loc = loc.after()
  inspect(
    after_loc,
    content=(
      #|{file: "test.md", first_ccode: 1, last_ccode: -1, first_line: LinePos(1, 10), last_line: LinePos(-1, -1)}
    ),
  )
  let none_loc = @cmark_base.TextLoc::none()
  inspect(none_loc.is_none(), content="true")
}
```

## Link and URI Parsing

The package provides functions for parsing links, URIs and email addresses:

```moonbit
///|
test "link parsing" {
  let txt = "Visit <https://mooncakes.io/>!"
  inspect(@cmark_base.autolink_uri(txt, start=6), content="Some(28)")
  let email = "Contact <user@example.com> today!"
  inspect(@cmark_base.autolink_email(email, start=8), content="Some(25)")
}
```

## String Analysis Utilities

The package provides various string analysis functions:

```moonbit
///|
test "string analysis" {
  let start = 0

  // Find first non-blank character
  inspect(@cmark_base.first_non_blank("  hello", last=7, start~), content="2")

  // Count repeated characters
  inspect(@cmark_base.run_of(char='-', "---hello", last=8, start~), content="2")
}
```

## Line Types and Parsing Utilities

The package provides comprehensive line type detection for different CommonMark elements:

```moonbit
///|
test "line type detection" {
  let start = 0

  // ATX Heading
  inspect(
    @cmark_base.LineType::atx_heading("# Heading", last=8, start~),
    content="AtxHeadingLine(1, 1, 2, 8)",
  )

  // Thematic Break
  inspect(
    @cmark_base.LineType::thematic_break("---", last=2, start~),
    content="ThematicBreakLine(2)",
  )

  // List Items
  inspect(
    @cmark_base.LineType::list_marker("- Item", last=5, start~),
    content="ListMarkerLine(Unordered('-'), 0)",
  )
  inspect(
    @cmark_base.LineType::list_marker("1. Item", last=6, start~),
    content="ListMarkerLine(Ordered(1, '.'), 1)",
  )
}
```

## List Types

The package provides support for different types of lists:

```moonbit
///|
test "list types" {
  let unordered = @cmark_base.ListType::Unordered('-')
  let ordered = @cmark_base.ListType::Ordered(1, '.')

  // Check if lists are of same type
  inspect(unordered.is_same_type(unordered), content="true")
  inspect(unordered.is_same_type(ordered), content="false")
}
```

## HTML Block Parsing

Support for detecting and parsing HTML blocks:

```moonbit
///|
test "html blocks" {
  let start = 0
  inspect(
    @cmark_base.LineType::html_block_start("<div>", last=5, start~),
    content="HtmlBlockLine(EndBlank)",
  )
  inspect(
    @cmark_base.LineType::html_block_end(
      "</div></br>",
      end_cond=@cmark_base.HtmlBlockEndCond::EndStr("</div>"),
      start~,
      last=6,
    ),
    content="true",
  )
}
```

## Metadata Handling

The package includes structures for tracking metadata:

```moonbit
///|
test "metadata handling" {
  let loc = @cmark_base.TextLoc::{
    file: "test.md",
    first_ccode: 0,
    last_ccode: 10,
    first_line: LinePos(1, 0),
    last_line: LinePos(1, 10),
  }
  let meta = @cmark_base.Meta::new(loc~)
  inspect(meta.is_none(), content="false")
  let none_meta = @cmark_base.Meta::none()
  inspect(none_meta.is_none(), content="true")
}
```

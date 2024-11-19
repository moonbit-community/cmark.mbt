test "thematic break with empty input" {
  // Test case where start > last
  inspect!(
    LineType::thematic_break("hello", last=3, start=4),
    content="Nomatch",
  )
}

test "atx_heading empty" {
  inspect!(
    LineType::atx_heading("#", last=0, start=0),
    content="AtxHeadingLine(1, 1, 1, 0)",
  )
}

test "atx_heading too many hashes" {
  inspect!(LineType::atx_heading("#######", last=6, start=0), content="Nomatch")
}

test "atx_heading no blank after hash" {
  inspect!(LineType::atx_heading("#a", last=1, start=0), content="Nomatch")
}

test "setext_heading_underline empty string" {
  // Tests line 179: if start > last
  let s = ""
  inspect!(
    LineType::setext_heading_underline(s, last=0, start=1),
    content="Nomatch",
  )
}

test "setext_heading_underline invalid start char" {
  // Tests line 182: if "-=".contains_char(s[start]).not()
  let s = "abc"
  inspect!(
    LineType::setext_heading_underline(s, last=2, start=0),
    content="Nomatch",
  )
}

test "setext_heading_underline with non-marker char" {
  // Tests line 169: if " \t".contains_char(s[k]).not()
  let s = "=x"
  inspect!(
    LineType::setext_heading_underline(s, last=1, start=0),
    content="Nomatch",
  )
}

test "setext_heading_underline with trailing blank" {
  // Tests line 173: if end_blank > last
  let s = "=== \t"
  inspect!(
    LineType::setext_heading_underline(s, last=4, start=0),
    content="SetextUnderlineLine(1, 2)",
  )
}

test "fenced_code_block_start empty input" {
  let s = ""
  let result = LineType::fenced_code_block_start(s, last=0, start=1)
  inspect!(result, content="Nomatch")
}

test "fenced_code_block_start with insufficient fence chars" {
  let s = "``"
  let result = LineType::fenced_code_block_start(s, last=1, start=0)
  inspect!(result, content="Nomatch")
}

test "fenced_code_block_start with indentation" {
  let s = "   ```"
  let result = LineType::fenced_code_block_start(s, last=5, start=0)
  inspect!(result, content="FencedCodeBlockLine(3, 5, None)")
}

test "fenced_code_block_start with non-fence char" {
  let s = "abc"
  let result = LineType::fenced_code_block_start(s, last=2, start=0)
  inspect!(result, content="Nomatch")
}

test "fenced code block continue - not enough fence chars" {
  // This test covers line 277 - raise Exit when not enough fence chars
  let fence = ('`', 3) // Requiring 3 backticks
  let s = "``" // Only 2 backticks
  inspect!(
    FencedCodeBlockContinue::new(s, fence~, last=1, start=0),
    content="Code",
  )
}

test "fenced code block continue - fence failure" {
  // This test covers line 300 - Exit => Code
  let fence = ('`', 3)
  let s = "```abc" // Valid fence but with extra content
  inspect!(
    FencedCodeBlockContinue::new(s, fence~, last=5, start=0),
    content="Code",
  )
}

test "html block start negative cases" {
  // Test case for invalid '!' tag (lines 409, 418)
  inspect!(
    LineType::html_block_start("<!>", last=2, start=0),
    content="Nomatch",
  )
  inspect!(
    LineType::html_block_start("<!1>", last=3, start=0),
    content="Nomatch",
  )

  // Test case for invalid regular tag (line 423)
  inspect!(
    LineType::html_block_start("<1>", last=2, start=0),
    content="Nomatch",
  )
}

test "html block start with open tag" {
  // Test case for open tag (line 449)
  inspect!(
    LineType::html_block_start("<custom>", last=7, start=0),
    content="HtmlBlockLine(EndBlank7)",
  )
}

test "html_block_end with EndStr" {
  let s = "Hello -->World"
  let end_cond = HtmlBlockEndCond::EndStr("-->")
  inspect!(
    LineType::html_block_end(s, end_cond~, last=11, start=0),
    content="true",
  )
  let s2 = "Hello World"
  inspect!(
    LineType::html_block_end(s2, end_cond~, last=10, start=0),
    content="false",
  )
}

test "html_block_end with EndCond1" {
  let s = "Hello </pre>World"
  let end_cond = HtmlBlockEndCond::EndCond1
  inspect!(
    LineType::html_block_end(s, end_cond~, last=12, start=0),
    content="true",
  )
  let s2 = "Hello World"
  inspect!(
    LineType::html_block_end(s2, end_cond~, last=10, start=0),
    content="false",
  )
}

test "list_marker invalid bullet" {
  let s = "  hello"
  inspect!(LineType::list_marker(s, last=6, start=2), content="Nomatch")
}

test "list_marker bullet without space" {
  let s = "  -hello"
  inspect!(LineType::list_marker(s, last=7, start=2), content="Nomatch")
}

test "list_marker long ordered list" {
  let s = "  1234567890. "
  inspect!(LineType::list_marker(s, last=13, start=2), content="Nomatch")
}

test "list_marker ordered list without space" {
  let s = "  1.hello"
  inspect!(LineType::list_marker(s, last=8, start=2), content="Nomatch")
}

test "ext_task_marker returns None when start >= last" {
  inspect!(ext_task_marker("", last=0, start=1), content="None")
  inspect!(ext_task_marker("", last=0, start=0), content="None")
}

test "ext_task_marker returns None when input is invalid UTF-16" {
  // Create an invalid UTF-16 sequence by using a high surrogate without a low surrogate
  let s = "[\xD800]" // \xD800 is a high surrogate
  inspect!(ext_task_marker(s, last=s.length(), start=0), content="None")
}

test "atx_heading: empty heading" {
  inspect!(
    LineType::atx_heading("#     ", last=5, start=0),
    content="AtxHeadingLine(1, 1, 6, 5)",
  )
}

test "atx_heading: heading with trailing hashes" {
  inspect!(
    LineType::atx_heading("# test #", last=7, start=0),
    content="AtxHeadingLine(1, 1, 2, 5)",
  )
}

test "atx_heading: invalid start" {
  inspect!(LineType::atx_heading("test", last=3, start=4), content="Nomatch")
}

test "html_block_start_5 with CDATA" {
  let s = "<![CDATA[foo]]>"
  inspect!(
    LineType::html_block_start(s, last=s.length() - 1, start=0),
    content="HtmlBlockLine(EndStr(\"]]>\"))",
  )
}

test "html_block_start_5 with incomplete CDATA" {
  let s = "<![CDA"
  inspect!(
    LineType::html_block_start(s, last=s.length() - 1, start=0),
    content="Nomatch",
  )
}

test "table row - no opening pipe" {
  inspect!(
    LineType::ext_table_row("a | b |", last=6, start=0),
    content="Nomatch",
  )
}

test "table row - no closing pipe" {
  inspect!(
    LineType::ext_table_row("| a | b ", last=6, start=0),
    content="Nomatch",
  )
}

test "table row - escaped closing pipe" {
  inspect!(
    LineType::ext_table_row("| a | b \\|", last=8, start=0),
    content="Nomatch",
  )
}

test "list_marker: empty string" {
  inspect!(LineType::list_marker("", last=0, start=1), content="Nomatch")
}

test "list_marker: ordered list with invalid marker" {
  inspect!(LineType::list_marker("123x", last=3, start=0), content="Nomatch")
}

test "html_block_start_7_open_tag - no match due to invalid open tag" {
  // Test case where open_tag returns None
  // This should trigger the uncovered line 361
  let s = "<invalid"
  inspect!(
    LineType::html_block_start(s, last=s.length() - 1, start=0),
    content="Nomatch",
  )
}

test "html block start nomatch" {
  inspect!(LineType::html_block_start("", last=0, start=0), content="Nomatch")
  inspect!(
    LineType::html_block_start("abc", last=2, start=0),
    content="Nomatch",
  )
}

test "html block start type 3" {
  inspect!(
    LineType::html_block_start("<?xml", last=4, start=0),
    content="HtmlBlockLine(EndStr(\"?>\"))",
  )
}

test "html block start type 2" {
  inspect!(
    LineType::html_block_start("<!--", last=4, start=0),
    content="HtmlBlockLine(EndStr(\"-->\"))",
  )
}

test "html block start type 4" {
  inspect!(
    LineType::html_block_start("<!abc>", last=5, start=0),
    content="HtmlBlockLine(EndStr(\">\"))",
  )
}

test "ext_table_row with escaped pipe at the end" {
  // Test when there's a backslash before the closing pipe, should return Nomatch
  inspect!(
    LineType::ext_table_row("| a b c \\|", last=9, start=0),
    content="Nomatch",
  )
}

test "fenced code block with backtick in info string" {
  let s = "```rust`"
  // This should trigger line 197 by having a backtick in the info string
  inspect!(
    LineType::fenced_code_block_start(s, last=7, start=0),
    content="Nomatch",
  )
}

test "html_block_start_7_open_tag with non-blank after tag" {
  // Test case where there is content after the tag
  let s = "<tag>some content"
  let result = LineType::html_block_start(s, last=s.length() - 1, start=0)
  inspect!(result, content="Nomatch")
}

test "html_block_start empty after <!" {
  let s = "<!a"
  inspect!(LineType::html_block_start(s, last=1, start=0), content="Nomatch")
}

test "html_block_start with tags" {
  let s = "<pre>test</pre>"
  inspect!(
    LineType::html_block_start(s, last=13, start=0),
    content="HtmlBlockLine(EndCond1)",
  )
  let s2 = "</p test>"
  inspect!(
    LineType::html_block_start(s2, last=7, start=0),
    content="HtmlBlockLine(EndBlank)",
  )
  let s3 = "<p/>"
  inspect!(
    LineType::html_block_start(s3, last=3, start=0),
    content="HtmlBlockLine(EndBlank)",
  )
  let s4 = "</p>"
  inspect!(
    LineType::html_block_start(s4, last=3, start=0),
    content="HtmlBlockLine(EndBlank)",
  )
}

test "fenced code block continue - another short blank line" {
  let fence = ('`', 3)
  let s = " " // Single space string represents another short blank line
  let last = 0
  let start = 0
  inspect!(
    FencedCodeBlockContinue::new(s, fence~, last~, start~),
    content="Code",
  )
}

test "could_be_link_ref_definition empty input" {
  let s = ""
  inspect!(could_be_link_ref_definition(s, last=0, start=1), content="false")
}

test "could_be_link_ref_definition exceed boundary" {
  let s = "   "
  inspect!(could_be_link_ref_definition(s, last=2, start=3), content="false")
}

test "html block start with closing tag that is not in cond 6 set - no whitespace" {
  let s = "</unknown>something"
  inspect!(
    LineType::html_block_start(s, last=s.length() - 1, start=0),
    content="Nomatch",
  )
}

test "could_be_link_ref_definition no bracket" {
  inspect!(
    could_be_link_ref_definition("   ", last=2, start=0),
    content="false",
  )
}

test "html block start with closing tag that is not in cond 6 set" {
  let s = "</foo>"
  inspect!(
    LineType::html_block_start(s, last=s.length() - 1, start=0),
    content="HtmlBlockLine(EndBlank7)",
  )
}

test "html block start with closing tag that is not in cond 6 set - longer" {
  let s = "</unknown> "
  inspect!(
    LineType::html_block_start(s, last=s.length() - 1, start=0),
    content="HtmlBlockLine(EndBlank7)",
  )
}

test "atx_heading with ending hashes" {
  // Test case where the heading ends with hashes preceded by a space
  inspect!(
    LineType::atx_heading("# Test #", last=7, start=0),
    content="AtxHeadingLine(1, 1, 2, 5)",
  )

  // Test case where the heading has multiple ending hashes
  inspect!(
    LineType::atx_heading("## Test ###", last=9, start=0),
    content="AtxHeadingLine(2, 2, 3, 6)",
  )

  // Test case where the heading has ending hashes with trailing spaces
  inspect!(
    LineType::atx_heading("### Test # ", last=9, start=0),
    content="AtxHeadingLine(3, 3, 4, 7)",
  )

  // Test case where the heading only has spaces between start and end hashes
  inspect!(
    LineType::atx_heading("# #", last=2, start=0),
    content="AtxHeadingLine(1, 1, 2, 1)",
  )
}

test "test LineType::fenced_code_block_start with uncovered section" {
  let s = "   ```"
  let last = 2
  let start = 1
  let output = LineType::fenced_code_block_start(s, last~, start~)
  inspect!(output, content="Nomatch")
}

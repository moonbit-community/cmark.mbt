///|
test "render defaults to omitting raw HTML" {
  for
    case in [
      ("<script>alert(1)</script>", "<!--CommonMark HTML block omitted-->\n"),
      (
        "before <img src=x onerror=alert(1)> after", "<p>before <!--CommonMark raw HTML omitted--> after</p>\n",
      ),
    ] {
    let (input, expected) = case
    assert_eq(@cmark_html.render(input), expected)
    assert_eq(@cmark_html.render(input), @cmark_html.render(safe=true, input))
  }
}

///|
test "render defaults to removing unsafe link and image destinations" {
  for
    destination in [
      "javascript:alert(1)", "JaVaScRiPt:alert(1)", "javascript&#58;alert(1)", "vbscript:msgbox(1)",
      "file:///tmp/test", "data:text/html,test",
    ] {
    let link = "[link](\{destination})"
    assert_eq(@cmark_html.render(link), "<p><a href=\"\">link</a></p>\n")
    assert_eq(@cmark_html.render(link), @cmark_html.render(safe=true, link))
    assert_eq(
      @cmark_html.render("![image](\{destination})"),
      "<p><img src=\"\" alt=\"image\" ></p>\n",
    )
  }
}

///|
test "render safe false preserves explicit HTML and link opt in" {
  assert_eq(
    @cmark_html.render(safe=false, "<script>alert(1)</script>"),
    "<script>alert(1)</script>\n",
  )
  assert_eq(
    @cmark_html.render(safe=false, "before <img src=x onerror=alert(1)> after"),
    "<p>before <img src=x onerror=alert(1)> after</p>\n",
  )
  for destination in ["javascript:alert(1)", "vbscript:msgbox(1)"] {
    assert_eq(
      @cmark_html.render(safe=false, "[link](\{destination})"),
      "<p><a href=\"\{destination}\">link</a></p>\n",
    )
  }
}

///|
test "render safe default preserves ordinary Markdown" {
  for
    destination in ["https://example.com", "/relative", "mailto:a@example.com"] {
    assert_eq(
      @cmark_html.render("[link](\{destination}) **😀** `<script>`"),
      "<p><a href=\"\{destination}\">link</a> <strong>😀</strong> <code>&lt;script&gt;</code></p>\n",
    )
  }
}

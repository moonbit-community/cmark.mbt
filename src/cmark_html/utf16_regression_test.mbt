// Regression tests for valid non-BMP Unicode at UTF-16 boundaries.

///|
/// `language_of_info_string` must scan by UTF-16 code units, not use a
/// code-unit index as a character index.
test "astral char in fence info string" {
  inspect(
    @cmark_html.render("```😀\nx\n```"),
    content="<pre><code class=\"language-😀\">x\n</code></pre>\n",
  )
  inspect(
    @cmark_html.render("```a😀 b\nx\n```"),
    content="<pre><code class=\"language-a😀\">x\n</code></pre>\n",
  )
}

///|
/// `autolink_uri` used to step one UTF-16 code unit at a time with
/// `get_char`, landing on the trailing half of a surrogate pair.
test "astral char in autolink" {
  inspect(
    @cmark_html.render("<http://a😀>"),
    content="<p><a href=\"http://a%F0%9F%98%80\">http://a😀</a></p>\n",
  )
}

///|
/// Link label normalization must advance by UTF-16 length, not UTF-8
/// byte length.
test "astral char in link label" {
  inspect(
    @cmark_html.render("[😀]: /x\n\n[😀]"),
    content="<p><a href=\"/x\">😀</a></p>\n",
  )
}

///|
/// HTML block start detection must avoid slices whose boundaries can land
/// inside a surrogate pair.
test "astral char after html tag name" {
  inspect(@cmark_html.render("<d.😀"), content="<p>&lt;d.😀</p>\n")
  inspect(@cmark_html.render("<div😀>"), content="<p>&lt;div😀&gt;</p>\n")
}

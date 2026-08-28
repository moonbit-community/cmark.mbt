// Regression tests for parser/scanner reads at end of input.

///|
/// `Parser::accept_cols` read past the end of input when a list marker
/// was the last thing in the input, with no trailing newline.
test "list marker at end of input" {
  inspect(@cmark_html.render("-"), content="<ul>\n<li></li>\n</ul>\n")
  inspect(@cmark_html.render("*"), content="<ul>\n<li></li>\n</ul>\n")
  inspect(@cmark_html.render("+"), content="<ul>\n<li></li>\n</ul>\n")
  inspect(@cmark_html.render("1."), content="<ol>\n<li></li>\n</ol>\n")
  inspect(@cmark_html.render("1)"), content="<ol>\n<li></li>\n</ol>\n")
  inspect(
    @cmark_html.render("> -"),
    content="<blockquote>\n<ul>\n<li></li>\n</ul>\n</blockquote>\n",
  )
}

///|
/// The `info` helper of `fenced_code_block_start` read the code unit at
/// `k` before checking `k <= last`.
test "fence info string at end of input" {
  inspect(
    @cmark_html.render("```#"),
    content="<pre><code class=\"language-#\"></code></pre>\n",
  )
  inspect(@cmark_html.render("```"), content="<pre><code></code></pre>\n")
}

///|
/// `ext_footnote_label` read `start + 1` guarded only by `start <= last`.
test "bracket at end of input with extensions" {
  inspect(@cmark_html.render(strict=false, "["), content="<p>[</p>\n")
  inspect(@cmark_html.render(strict=false, "[^"), content="<p>[^</p>\n")
}

///|
/// `autolink_email` used `||` instead of `&&` before checking `s[start]`.
test "empty email autolink input" {
  inspect(@cmark_html.render("<"), content="<p>&lt;</p>\n")
}

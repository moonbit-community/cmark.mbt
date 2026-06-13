// Regression tests for inputs that used to abort the parser or renderer.
// Each test documents the panic site it guards against.

///|
/// Builds a string containing code units that cannot be written as
/// literals (e.g. unpaired surrogates).
fn string_of_code_units(units : Array[Int]) -> String {
  let b = StringBuilder::new()
  for u in units {
    b.write_char(u.unsafe_to_char())
  }
  b.to_string()
}

///|
/// `Parser::accept_cols` read past the end of input when a list marker
/// was the last thing in the input, with no trailing newline.
test "list marker at end of input" {
  inspect(@cmark_html.render("-"), content="<ul>\n<li></li>\n</ul>\n")
  inspect(@cmark_html.render("*"), content="<ul>\n<li></li>\n</ul>\n")
  inspect(@cmark_html.render("+"), content="<ul>\n<li></li>\n</ul>\n")
  inspect(@cmark_html.render("1."), content="<ol>\n<li></li>\n</ol>\n")
  inspect(@cmark_html.render("1)"), content="<ol>\n<li></li>\n</ol>\n")
  // Markers at end of input inside other blocks.
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
/// `language_of_info_string` indexed chars by code-unit position and
/// aborted on the trailing half of any surrogate pair.
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
/// `autolink_uri` called `get_char(k).unwrap()` while stepping by single
/// code units, landing on the trailing half of a surrogate pair.
test "astral char in autolink" {
  inspect(
    @cmark_html.render("<http://a😀>"),
    content="<p><a href=\"http://a%F0%9F%98%80\">http://a😀</a></p>\n",
  )
}

///|
/// `html_block_start` checked for `/>` after the tag name with a string
/// view whose end boundary can land on the trailing half of a surrogate
/// pair.
test "astral char after html tag name" {
  inspect(@cmark_html.render("<d.😀"), content="<p>&lt;d.😀</p>\n")
  inspect(@cmark_html.render("<div😀>"), content="<p>&lt;div😀&gt;</p>\n")
}

///|
/// `prev_char`/`next_char` aborted on unpaired surrogates next to an
/// emphasis run; unpaired surrogates anywhere in text made
/// `utf_16_clean_raw` abort while slicing.
test "unpaired surrogates never abort" {
  let lead = string_of_code_units([0xD800])
  let trail = string_of_code_units([0xDC00])
  let cases = [
    trail,
    lead,
    trail + "*a*",
    "*a*" + lead,
    "> " + trail,
    "```" + lead + "\nx\n```",
    "[a]: <" + trail + ">",
    "<http://" + lead + ">",
  ]
  for case in cases {
    // Must not abort; unpaired surrogates render as U+FFFD. (A pure
    // link definition renders to nothing, so empty output is fine.)
    let rendered = @cmark_html.render(case)
    for k in 0..<rendered.length() {
      let u = rendered.code_unit_at(k).to_int()
      assert_false(0xD800 <= u && u <= 0xDFFF)
    }
  }
  inspect(@cmark_html.render(trail), content="<p>\u{FFFD}</p>\n")
}

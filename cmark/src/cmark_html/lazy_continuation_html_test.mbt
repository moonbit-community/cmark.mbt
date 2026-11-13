// A line starting with a complete HTML tag (HTML block start condition 7)
// can't interrupt a paragraph, so it is a lazy continuation line.
// https://spec.commonmark.org/0.31.2/#html-blocks

///|
test "HTML block start condition 7 is a lazy continuation line" {
  inspect(
    @cmark_html.render(safe=false, "- a\n</kbd>\n"),
    content=(
      #|<ul>
      #|<li>a
      #|</kbd></li>
      #|</ul>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "> a\n<x y=\"z\">\n"),
    content=(
      #|<blockquote>
      #|<p>a
      #|<x y="z"></p>
      #|</blockquote>
      #|
    ),
  )
  let footnote = @cmark_html.render(
    safe=false,
    strict=false,
    "x[^1]\n\n[^1]: a\n</kbd>\n",
  )
  inspect(footnote.contains("<p>a\n</kbd></p>"), content="true")
}

///|
test "other HTML block starts interrupt a lazy paragraph" {
  inspect(
    @cmark_html.render(safe=false, "- a\n<div>\n"),
    content=(
      #|<ul>
      #|<li>a</li>
      #|</ul>
      #|<div>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "> a\n<div>\n"),
    content=(
      #|<blockquote>
      #|<p>a</p>
      #|</blockquote>
      #|<div>
      #|
    ),
  )
}

// Blanks after the `[` of a link or image are part of the link text.
// https://spec.commonmark.org/0.31.2/#link-text

///|
test "blanks at the start of link text are kept" {
  inspect(
    @cmark_html.render(
      safe=false,
      "[ foo](/u) [  bar ][x] ![ baz](/i)\n\n[x]: /v\n",
    ),
    content=(
      #|<p><a href="/u"> foo</a> <a href="/v">  bar </a> <img src="/i" alt=" baz" ></p>
      #|
    ),
  )
  // Blanks starting the following lines are still stripped
  inspect(
    @cmark_html.render(safe=false, "[ a\n   b](/u)\n"),
    content=(
      #|<p><a href="/u"> a
      #|b</a></p>
      #|
    ),
  )
}

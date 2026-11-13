// A backslash at the end of a line is a hard line break only if it is not
// itself escaped.
// https://spec.commonmark.org/0.31.2/#hard-line-breaks

///|
test "escaped backslash before a line ending is not a hard break" {
  inspect(
    @cmark_html.render(safe=false, "a\\\\\nb\n"),
    content=(
      #|<p>a\
      #|b</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "c\\\\\\\nd\n"),
    content=(
      #|<p>c\<br>
      #|d</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "\\\\\\\\\ne\n"),
    content=(
      #|<p>\\
      #|e</p>
      #|
    ),
  )
}

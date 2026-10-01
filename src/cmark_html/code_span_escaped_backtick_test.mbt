// A backslash escapes only the first backtick of a backtick string: the
// rest of the string can still open a code span.
// https://spec.commonmark.org/0.31.2/#code-spans

///|
test "code span after an escaped backtick" {
  inspect(
    @cmark_html.render(safe=false, "\\``a` \\```b``\n"),
    content=(
      #|<p>`<code>a</code> `<code>b</code></p>
      #|
    ),
  )
  // A single escaped backtick opens nothing
  inspect(
    @cmark_html.render(safe=false, "\\`a`\n"),
    content=(
      #|<p>`a`</p>
      #|
    ),
  )
}

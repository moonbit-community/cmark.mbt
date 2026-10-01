// Only blanks may follow the title of a link reference definition.
// https://spec.commonmark.org/0.31.2/#link-reference-definitions

///|
test "link reference definition with text after the title" {
  // Spec example 209
  inspect(
    @cmark_html.render(safe=false, "[foo]: /url \"title\" ok\n"),
    content=(
      #|<p>[foo]: /url &quot;title&quot; ok</p>
      #|
    ),
  )
  // Spec example 210: the title on the next line is not part of the
  // definition
  inspect(
    @cmark_html.render(safe=false, "[foo]: /url\n\"title\" ok\n\n[foo]\n"),
    content=(
      #|<p>&quot;title&quot; ok</p>
      #|<p><a href="/url">foo</a></p>
      #|
    ),
  )
  // Trailing blanks are fine
  inspect(
    @cmark_html.render(safe=false, "[foo]: /url \"title\"  \n\n[foo]\n"),
    content=(
      #|<p><a href="/url" title="title">foo</a></p>
      #|
    ),
  )
}

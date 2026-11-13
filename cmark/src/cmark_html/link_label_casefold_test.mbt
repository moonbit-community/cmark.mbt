// Link labels match case-insensitively with Unicode case folding.
// https://spec.commonmark.org/0.31.2/#matches

///|
test "link labels match with Unicode case folding" {
  // Spec example 206
  inspect(
    @cmark_html.render(safe=false, "[ΑΓΩ]: /φου\n\n[αγω]\n"),
    content=(
      #|<p><a href="/%CF%86%CE%BF%CF%85">αγω</a></p>
      #|
    ),
  )
  // Spec example 540: ẞ folds to "ss"
  inspect(
    @cmark_html.render(safe=false, "[ẞ]\n\n[SS]: /url\n"),
    content=(
      #|<p><a href="/url">ẞ</a></p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "[Straße]\n\n[STRASSE]: /url\n"),
    content=(
      #|<p><a href="/url">Straße</a></p>
      #|
    ),
  )
}

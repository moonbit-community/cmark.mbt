// Unicode punctuation characters for emphasis flanking are the Unicode P
// (punctuation) and S (symbol) general categories.
// https://spec.commonmark.org/0.31.2/#unicode-punctuation-character

///|
test "Unicode symbols are punctuation for emphasis flanking" {
  // Spec example 354
  inspect(
    @cmark_html.render(safe=false, "*$*alpha.\n\n*£*bravo.\n\n*€*charlie.\n"),
    content=(
      #|<p>*$*alpha.</p>
      #|<p>*£*bravo.</p>
      #|<p>*€*charlie.</p>
      #|
    ),
  )
  // `+` and `=` are symbols: the second `*` is not right-flanking, so it
  // can't close
  inspect(
    @cmark_html.render(safe=false, "*a+*b *a=*c\n"),
    content=(
      #|<p>*a+*b *a=*c</p>
      #|
    ),
  )
}

///|
test "symbols around underscores and astral symbols" {
  // `_` after a symbol and before a letter is left-flanking only
  inspect(
    @cmark_html.render(safe=false, "_a+_b _a_ *😀*a\n"),
    content=(
      #|<p>_a+_b <em>a</em> *😀*a</p>
      #|
    ),
  )
}

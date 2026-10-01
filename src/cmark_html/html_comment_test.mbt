// HTML comments as defined by CommonMark 0.31.
// https://spec.commonmark.org/0.31.2/#html-comment

///|
test "<!--> and <!---> are HTML comments" {
  // Spec example 626
  inspect(
    @cmark_html.render(safe=false, "foo <!--> foo -->\n\nfoo <!---> foo -->\n"),
    content=(
      #|<p>foo <!--> foo --&gt;</p>
      #|<p>foo <!---> foo --&gt;</p>
      #|
    ),
  )
}

///|
test "HTML comments end at the first -->" {
  inspect(
    @cmark_html.render(
      safe=false,
      "a <!----> b <!-- c--> d <!-- e --- f --> g <!-- h -- i --> j\n",
    ),
    content=(
      #|<p>a <!----> b <!-- c--> d <!-- e --- f --> g <!-- h -- i --> j</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "a <!-- b\nc --> d\n"),
    content=(
      #|<p>a <!-- b
      #|c --> d</p>
      #|
    ),
  )
}

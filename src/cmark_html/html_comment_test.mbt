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

///|
test "unterminated comments are not rescanned" {
  // A comment now runs to the first -->, so each unterminated one would
  // otherwise scan to the end of the paragraph: this must stay linear.
  let unterminated = "a " + "<!-- ".repeat(50000)
  inspect(
    @cmark_html.render(safe=false, unterminated).length(),
    content="400009",
  )
  let unterminated = "a <!--\n".repeat(20000)
  inspect(
    @cmark_html.render(safe=false, unterminated).length(),
    content="200007",
  )
}

///|
test "unterminated comment containing -- keeps the following lines" {
  inspect(
    @cmark_html.render(safe=false, "a <!-- b -- c\nz\n"),
    content=(
      #|<p>a &lt;!-- b -- c
      #|z</p>
      #|
    ),
  )
}

// An attribute without a value can be followed by a line break.

///|
test "raw HTML with a value-less attribute before a line break" {
  inspect(
    @cmark_html.render(safe=false, "<b then\nc >\n"),
    content=(
      #|<p><b then
      #|c ></p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "a <a b\nc=\"d\"> e\n"),
    content=(
      #|<p>a <a b
      #|c="d"> e</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "a <a b\nc\nd/> e\n"),
    content=(
      #|<p>a <a b
      #|c
      #|d/> e</p>
      #|
    ),
  )
}

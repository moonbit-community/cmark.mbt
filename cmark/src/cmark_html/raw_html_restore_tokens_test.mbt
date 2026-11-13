// Inline raw HTML that spans lines and then fails to match must not drop
// the lines it looked at.

///|
test "failed multi-line raw HTML keeps the following lines" {
  inspect(
    @cmark_html.render(safe=false, "x <a\nb\n"),
    content=(
      #|<p>x &lt;a
      #|b</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "a <!-- b\nc\nd\n"),
    content=(
      #|<p>a &lt;!-- b
      #|c
      #|d</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "a <!--\nb <? <![CDATA[ <!X\nc <!-- d <?\n"),
    content=(
      #|<p>a &lt;!--
      #|b &lt;? &lt;![CDATA[ &lt;!X
      #|c &lt;!-- d &lt;?</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "<a b=\n\"c\"d>\ne\n"),
    content=(
      #|<p>&lt;a b=
      #|&quot;c&quot;d&gt;
      #|e</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "*a <b\nc* d\n*e*\n"),
    content=(
      #|<p><em>a &lt;b
      #|c</em> d
      #|<em>e</em></p>
      #|
    ),
  )
  // In link text
  inspect(
    @cmark_html.render(safe=false, "[a <!-- b\nc](/u) d\n"),
    content=(
      #|<p><a href="/u">a &lt;!-- b
      #|c</a> d</p>
      #|
    ),
  )
}

///|
test "unterminated raw HTML is not rescanned" {
  // Each unterminated comment, processing instruction, CDATA section and
  // declaration would otherwise scan to the end of the paragraph: this
  // must stay linear.
  let unterminated = "a <!-- <? <![CDATA[ <!X\n".repeat(20000)
  inspect(
    @cmark_html.render(safe=false, unterminated).length(),
    content="720007",
  )
  let unterminated = "a " + "<!-- <? <![CDATA[ <!X ".repeat(20000)
  inspect(
    @cmark_html.render(safe=false, unterminated).length(),
    content="680009",
  )
  // Other kinds of constructs are still raw HTML
  inspect(
    @cmark_html.render(safe=false, "a <!-- b <? c ?> d <![CDATA[ e ]]> f\n"),
    content=(
      #|<p>a &lt;!-- b <? c ?> d <![CDATA[ e ]]> f</p>
      #|
    ),
  )
}

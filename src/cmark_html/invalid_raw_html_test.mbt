// Constructs that look like raw HTML or autolinks but are not.

///|
test "tag names start with an ASCII letter" {
  // Spec examples 618 and 621
  inspect(
    @cmark_html.render(safe=false, "<33> <__> < a> </1a> <a> </a>\n"),
    content=(
      #|<p>&lt;33&gt; &lt;__&gt; &lt; a&gt; &lt;/1a&gt; <a> </a></p>
      #|
    ),
  )
}

///|
test "attribute names start with a letter, _ or :" {
  inspect(
    @cmark_html.render(safe=false, "a <b 1=c> <b _1=c> <b :c=d> d\n"),
    content=(
      #|<p>a &lt;b 1=c&gt; <b _1=c> <b :c=d> d</p>
      #|
    ),
  )
}

///|
test "unquoted attribute values are non-empty" {
  inspect(
    @cmark_html.render(safe=false, "a <a b=>c> <a b=`c> <a b=c> d\n"),
    content=(
      #|<p>a &lt;a b=&gt;c&gt; &lt;a b=`c&gt; <a b=c> d</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "<a c=</a>\nb\n"),
    content=(
      #|<p>&lt;a c=</a>
      #|b</p>
      #|
    ),
  )
}

///|
test "email autolinks use the atext character set" {
  // Spec example 606: `\` is not allowed (but `'` is)
  inspect(
    @cmark_html.render(safe=false, "<foo\\+@bar.example.com>\n"),
    content=(
      #|<p>&lt;foo+@bar.example.com&gt;</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(
      safe=false,
      "<foo+bar@example.com> <o'neil@example.com>\n",
    ),
    content=(
      #|<p><a href="mailto:foo+bar@example.com">foo+bar@example.com</a> <a href="mailto:o&apos;neil@example.com">o'neil@example.com</a></p>
      #|
    ),
  )
}

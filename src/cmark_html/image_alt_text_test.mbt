// The alt text of an image is the plain text content of its description.
// https://spec.commonmark.org/0.31.2/#images

///|
test "image alt text concatenates the text of inlines" {
  // As in spec examples 520, 573-577, 585 and 589
  inspect(
    @cmark_html.render(safe=false, "![foo *bar*](/url)\n"),
    content=(
      #|<p><img src="/url" alt="foo bar" ></p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "![foo *bar* [baz](/u)](/url)\n"),
    content=(
      #|<p><img src="/url" alt="foo bar baz" ></p>
      #|
    ),
  )
  // Spec example 574
  inspect(
    @cmark_html.render(safe=false, "![foo ![bar](/b)](/url)\n"),
    content=(
      #|<p><img src="/url" alt="foo bar" ></p>
      #|
    ),
  )
}

///|
test "image alt text keeps hard breaks as newlines" {
  inspect(
    @cmark_html.render(safe=false, "![foo\\\nbar](/url)\n"),
    content=(
      #|<p><img src="/url" alt="foo
      #|bar" ></p>
      #|
    ),
  )
}

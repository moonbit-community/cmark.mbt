// A fenced code block left open at the end of the document is closed
// there, without the empty line that ends the input.

///|
test "unclosed fenced code block at the end of a list item" {
  inspect(
    @cmark_html.render(safe=false, "- ```\n  a\n"),
    content=(
      #|<ul>
      #|<li>
      #|<pre><code>a
      #|</code></pre>
      #|</li>
      #|</ul>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "1. - ```\n     a\n"),
    content=(
      #|<ol>
      #|<li>
      #|<ul>
      #|<li>
      #|<pre><code>a
      #|</code></pre>
      #|</li>
      #|</ul>
      #|</li>
      #|</ol>
      #|
    ),
  )
  // The list stays tight
  inspect(
    @cmark_html.render(safe=false, "- a\n- ```\n  b\n"),
    content=(
      #|<ul>
      #|<li>a</li>
      #|<li>
      #|<pre><code>b
      #|</code></pre>
      #|</li>
      #|</ul>
      #|
    ),
  )
}

///|
test "unclosed fenced code block at the end of a footnote" {
  let html = @cmark_html.render(
    safe=false,
    strict=false,
    "x[^1]\n\n[^1]:\n  ```\n  a\n",
  )
  inspect(html.contains("<pre><code>a\n</code></pre>"), content="true")
}

///|
test "blank last line without a final newline is code block content" {
  // The last line is blank after removing the container's indentation or
  // marker, but it is a line of the input, not the end of the input.
  inspect(
    @cmark_html.render(safe=false, "- ```\n  a\n  "),
    content=(
      #|<ul>
      #|<li>
      #|<pre><code>a
      #|
      #|</code></pre>
      #|</li>
      #|</ul>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "> ```\n> a\n>"),
    content=(
      #|<blockquote>
      #|<pre><code>a
      #|
      #|</code></pre>
      #|</blockquote>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, " ```\n a\n "),
    content=(
      #|<pre><code>a
      #|
      #|</code></pre>
      #|
    ),
  )
}

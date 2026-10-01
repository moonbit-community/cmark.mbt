// Regression tests for CommonMark conformance bugs. Expected outputs follow
// the CommonMark 0.31.2 spec (and its reference implementations).

///|
fn render_xhtml(md : String, strict? : Bool = true) -> String raise {
  @cmark_html.xhtml_renderer(safe=false).doc_to_string(
    Doc::from_string(md, strict~),
  )
}

///|
test "failed multi-line raw HTML keeps the following lines" {
  inspect(
    render_xhtml("x <a\nb\n"),
    content=(
      #|<p>x &lt;a
      #|b</p>
      #|
    ),
  )
  inspect(
    render_xhtml("a <!-- b\nc\nd\n"),
    content=(
      #|<p>a &lt;!-- b
      #|c
      #|d</p>
      #|
    ),
  )
  inspect(
    render_xhtml("<a b=\n\"c\"d>\ne\n"),
    content=(
      #|<p>&lt;a b=
      #|&quot;c&quot;d&gt;
      #|e</p>
      #|
    ),
  )
  inspect(
    render_xhtml("*a <b\nc* d\n*e*\n"),
    content=(
      #|<p><em>a &lt;b
      #|c</em> d
      #|<em>e</em></p>
      #|
    ),
  )
}

///|
test "raw HTML with a value-less attribute before a line break" {
  inspect(
    render_xhtml("<b then\nc >\n"),
    content=(
      #|<p><b then
      #|c ></p>
      #|
    ),
  )
  inspect(
    render_xhtml("a <a b\nc=\"d\"> e\n"),
    content=(
      #|<p>a <a b
      #|c="d"> e</p>
      #|
    ),
  )
}

///|
test "type 7 HTML block start is a lazy continuation line" {
  inspect(
    render_xhtml("- a\n</kbd>\n"),
    content=(
      #|<ul>
      #|<li>a
      #|</kbd></li>
      #|</ul>
      #|
    ),
  )
  inspect(
    render_xhtml("> a\n<x y=\"z\">\n"),
    content=(
      #|<blockquote>
      #|<p>a
      #|<x y="z"></p>
      #|</blockquote>
      #|
    ),
  )
  // Other HTML blocks can interrupt a paragraph
  inspect(
    render_xhtml("- a\n<div>\n"),
    content=(
      #|<ul>
      #|<li>a</li>
      #|</ul>
      #|<div>
      #|
    ),
  )
}

///|
test "link labels match with Unicode case folding" {
  inspect(
    render_xhtml("[ΑΓΩ]: /φου\n\n[αγω]\n"),
    content=(
      #|<p><a href="/%CF%86%CE%BF%CF%85">αγω</a></p>
      #|
    ),
  )
  inspect(
    render_xhtml("[ẞ]\n\n[SS]: /url\n"),
    content=(
      #|<p><a href="/url">ẞ</a></p>
      #|
    ),
  )
  inspect(
    render_xhtml("[Straße]\n\n[STRASSE]: /url\n"),
    content=(
      #|<p><a href="/url">Straße</a></p>
      #|
    ),
  )
}

///|
test "invalid raw HTML and autolinks" {
  inspect(
    render_xhtml("<33> <__> < a> </1a>\n"),
    content=(
      #|<p>&lt;33&gt; &lt;__&gt; &lt; a&gt; &lt;/1a&gt;</p>
      #|
    ),
  )
  inspect(
    render_xhtml("<foo\\+@bar.example.com>\n"),
    content=(
      #|<p>&lt;foo+@bar.example.com&gt;</p>
      #|
    ),
  )
  inspect(
    render_xhtml("<foo+bar@example.com>\n"),
    content=(
      #|<p><a href="mailto:foo+bar@example.com">foo+bar@example.com</a></p>
      #|
    ),
  )
}

///|
test "HTML comments" {
  inspect(
    render_xhtml("foo <!--> foo -->\n\nfoo <!---> foo -->\n"),
    content=(
      #|<p>foo <!--> foo --&gt;</p>
      #|<p>foo <!---> foo --&gt;</p>
      #|
    ),
  )
  inspect(
    render_xhtml("a <!----> b <!-- c--> d <!-- e --- f --> g\n"),
    content=(
      #|<p>a <!----> b <!-- c--> d <!-- e --- f --> g</p>
      #|
    ),
  )
}

///|
test "unclosed fenced code block at the end of a list item or footnote" {
  inspect(
    render_xhtml("- ```\n  a\n"),
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
    render_xhtml("1. - ```\n     a\n"),
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
  inspect(
    render_xhtml("x[^1]\n\n[^1]:\n  ```\n  a\n", strict=false).contains(
      "<pre><code>a\n</code></pre>",
    ),
    content="true",
  )
}

///|
test "emphasis rule of 3" {
  inspect(
    render_xhtml("*foo**bar**baz*\n"),
    content=(
      #|<p><em>foo<strong>bar</strong>baz</em></p>
      #|
    ),
  )
  inspect(
    render_xhtml("*foo**bar*\n"),
    content=(
      #|<p><em>foo**bar</em></p>
      #|
    ),
  )
  inspect(
    render_xhtml("*foo**bar***\n"),
    content=(
      #|<p><em>foo<strong>bar</strong></em></p>
      #|
    ),
  )
  inspect(
    render_xhtml("**foo*bar*baz**\n"),
    content=(
      #|<p><strong>foo<em>bar</em>baz</strong></p>
      #|
    ),
  )
}

///|
test "Unicode symbols are punctuation for emphasis flanking" {
  inspect(
    render_xhtml("*$*alpha.\n\n*£*bravo.\n\n*€*charlie.\n"),
    content=(
      #|<p>*$*alpha.</p>
      #|<p>*£*bravo.</p>
      #|<p>*€*charlie.</p>
      #|
    ),
  )
}

///|
test "link reference definition with text after the title" {
  inspect(
    render_xhtml("[foo]: /url \"title\" ok\n"),
    content=(
      #|<p>[foo]: /url &quot;title&quot; ok</p>
      #|
    ),
  )
  inspect(
    render_xhtml("[foo]: /url\n\"title\" ok\n\n[foo]\n"),
    content=(
      #|<p>&quot;title&quot; ok</p>
      #|<p><a href="/url">foo</a></p>
      #|
    ),
  )
}

///|
test "image alt text" {
  inspect(
    render_xhtml("![foo *bar* [baz](/u)](/url)\n"),
    content=(
      #|<p><img src="/url" alt="foo bar baz" /></p>
      #|
    ),
  )
  inspect(
    render_xhtml("![foo\\\nbar](/url)\n"),
    content=(
      #|<p><img src="/url" alt="foo
      #|bar" /></p>
      #|
    ),
  )
}

///|
test "blanks at the start of link text are kept" {
  inspect(
    render_xhtml("[ foo](/u) [  bar ][x] ![ baz](/i)\n\n[x]: /v\n"),
    content=(
      #|<p><a href="/u"> foo</a> <a href="/v">  bar </a> <img src="/i" alt=" baz" /></p>
      #|
    ),
  )
}

///|
test "escaped backslash before a line ending is not a hard break" {
  inspect(
    render_xhtml("a\\\\\nb\n\nc\\\\\\\nd\n"),
    content=(
      #|<p>a\
      #|b</p>
      #|<p>c\<br />
      #|d</p>
      #|
    ),
  )
}

///|
test "emphasis marks that fail to open can still close" {
  inspect(
    render_xhtml("*a **b* c\n"),
    content=(
      #|<p>*a *<em>b</em> c</p>
      #|

    ),
  )
  inspect(
    render_xhtml("x *y\n**['_*>~_\n"),
    content=(
      #|<p>x <em>y
      #|**['_</em>&gt;~_</p>
      #|
    ),
  )
}

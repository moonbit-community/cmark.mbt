// Emphasis is resolved with the spec's process emphasis procedure.
// https://spec.commonmark.org/0.31.2/#phase-2-inline-structure

///|
test "emphasis rule of 3" {
  // Spec examples 411, 412, 415 and 429
  inspect(
    @cmark_html.render(safe=false, "*foo**bar**baz*\n"),
    content=(
      #|<p><em>foo<strong>bar</strong>baz</em></p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "*foo**bar*\n"),
    content=(
      #|<p><em>foo**bar</em></p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "*foo**bar***\n"),
    content=(
      #|<p><em>foo<strong>bar</strong></em></p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "**foo*bar*baz**\n"),
    content=(
      #|<p><strong>foo<em>bar</em>baz</strong></p>
      #|
    ),
  )
  // The rule of 3 uses the length of the delimiter runs
  inspect(
    @cmark_html.render(safe=false, "******._*****_>\n"),
    content=(
      #|<p>*<em><strong><strong>._</strong></strong></em>_&gt;</p>
      #|
    ),
  )
}

///|
test "closers match the nearest possible opener" {
  // A delimiter run that can both open and close is first a closer
  inspect(
    @cmark_html.render(safe=false, "*a **b*c* d\n"),
    content=(
      #|<p><em>a **b</em>c* d</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "**a *b**c* d\n"),
    content=(
      #|<p><strong>a *b</strong>c* d</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "x *y\n**['_*>~_\n"),
    content=(
      #|<p>x <em>y
      #|**['_</em>&gt;~_</p>
      #|
    ),
  )
  inspect(
    @cmark_html.render(safe=false, "**._+~=*=\\__*\n"),
    content=(
      #|<p>*<em>.<em>+~=*=_</em></em></p>
      #|
    ),
  )
}

///|
test "strikethrough is processed with emphasis" {
  inspect(
    @cmark_html.render(
      safe=false,
      strict=false,
      "~~a *b~~ c* ~~*d*~~ *~~e*~~\n",
    ),
    content=(
      #|<p><del>a *b</del> c* <del><em>d</em></del> <em>~~e</em>~~</p>
      #|
    ),
  )
}

///|
test "emphasis spanning lines" {
  inspect(
    @cmark_html.render(safe=false, "a *b\nc* **d\n*e*\nf**\n"),
    content=(
      #|<p>a <em>b
      #|c</em> <strong>d
      #|<em>e</em>
      #|f</strong></p>
      #|
    ),
  )
}

# `cmark_html`

This package provides basic facilities for rendering CommonMark documents as HTML.
It also serves as a concrete implementation example for the `cmark_renderer` abstraction.

To use this package in a quick way, you can use the `@cmark_html.render!` function:

```moonbit
test "basic rendering" {
  let doc =
    #|# Hello World
    #|
    #|This is a paragraph.
  let rendered = @cmark_html.render!(safe=false, strict=false, doc)
  inspect!(
    rendered,
    content=
      #|<h1>Hello World</h1>
      #|<p>This is a paragraph.</p>
      #|
    ,
  )
}
```

To convert a `cmark` syntax tree to HTML, you can use the `@cmark_html.from_doc` function like so:

```moonbit
test "rendering from @cmark.Doc" {
  let doc = @cmark.Doc::from_string(
    strict=false,
    #|# Hello World
    #|
    #|This is a paragraph.
    ,
  )
  let rendered = @cmark_html.from_doc!(safe=false, doc)
  inspect!(
    rendered,
    content=
      #|<h1>Hello World</h1>
      #|<p>This is a paragraph.</p>
      #|
    ,
  )
}
```

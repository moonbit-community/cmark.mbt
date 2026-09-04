# `cmark_html`

This package provides basic facilities for rendering CommonMark documents as HTML.
It also serves as a concrete implementation example for the `cmark_renderer` abstraction.

To use this package in a quick way, you can use the `@cmark_html.render` function:

```mbt check
///|
test "basic rendering" {
  let doc =
    #|# Hello World
    #|
    #|This is a paragraph.
  let rendered = @cmark_html.render(strict=false, doc)
  inspect(
    rendered,
    content=(
      #|<h1>Hello World</h1>
      #|<p>This is a paragraph.</p>
      #|
    ),
  )
}
```

## Safe rendering and compatibility

`render` enables `safe=true` by default. Raw HTML blocks and inline tags are
replaced by comments, and link/image destinations rejected by the existing
unsafe-URL check (such as `javascript:` and `vbscript:`) become empty strings.
Ordinary Markdown, HTTPS links, and escaped code remain available.

This is a behavior change from the previous `safe=false` default. Callers that
need raw HTML passthrough must explicitly pass `safe=false` and should only do
so for trusted input. Explicit `safe=true` and `safe=false` retain their existing
behavior. Safe mode omits raw HTML; it is not a general-purpose HTML sanitizer.

```mbt check
///|
test "safe default and trusted HTML opt in" {
  inspect(
    @cmark_html.render("<div>trusted HTML</div>"),
    content="<!--CommonMark HTML block omitted-->\n",
  )
  inspect(
    @cmark_html.render(safe=false, "<div>trusted HTML</div>"),
    content="<div>trusted HTML</div>\n",
  )
}
```

## Rendering a parsed document

The lower-level `from_doc`, `renderer`, and `xhtml_renderer` APIs still require
an explicit `safe` argument; this change only affects the default of `render`.
To convert a `cmark` syntax tree to HTML, use `@cmark_html.from_doc`:

```mbt check
///|
test "rendering from @cmark.Doc" {
  let doc = @cmark.Doc::from_string(
    strict=false,
    (
      #|# Hello World
      #|
      #|This is a paragraph.
    ),
  )
  let rendered = @cmark_html.from_doc(safe=true, doc)
  inspect(
    rendered,
    content=(
      #|<h1>Hello World</h1>
      #|<p>This is a paragraph.</p>
      #|
    ),
  )
}
```

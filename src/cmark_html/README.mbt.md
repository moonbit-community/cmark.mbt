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

## Attributes on source-owning elements

`renderer`, `xhtml_renderer`, `from_doc`, and `render` accept an optional
`node_attributes` callback. It receives a node's original `Meta` and the
lowercase HTML tag name, and returns additional `(name, value)` attributes.
Omitting it or returning an empty array preserves the existing output.
Metadata is passed through unchanged; elements may share one `Meta`, such as
a blockquote and its sole paragraph.

Parse with `locs=true` when the attributes need source positions or node IDs.
The convenience `render` function keeps its existing parsing defaults; use a
parsed `Doc` with `from_doc` or a renderer for location-aware rendering.

```mbt check
///|
test "source identities on rendered Markdown" {
  let doc = @cmark.Doc::from_string("**selected** text", locs=true)
  let html = @cmark_html.from_doc(
    safe=true,
    node_attributes=fn(meta, _) {
      [("data-source-start", "\{meta.loc.first_ccode}")]
    },
    doc,
  )
  assert_eq(
    html, "<p data-source-start=\"0\"><strong>selected</strong> text</p>\n",
  )
}
```

The callback runs once per source-owning element written by the default
renderer: `p`, `h1` through `h6`, `blockquote`, `pre`, `hr`, `ul`, `ol`, `li`,
and table `tr`, `th`, and `td` elements. A table's block attributes belong to
its outer `div role="region"`, which owns both the table and its layout wrapper.
Tight-list paragraphs have no `p`; their containing `li` still receives its
list-item metadata. Table cells synthesized to pad a short row have no source
node, so they do not call the hook.

Raw HTML, omitted blocks, plain-text math, inline markup, and synthetic
presentation tags do not call the hook. A composed renderer that handles a
block itself owns that block's output and attributes.

Attribute names must match `[A-Za-z_:][A-Za-z0-9_.:-]*`. Values are escaped by
the HTML renderer. Duplicate names are rejected case-insensitively, including
attributes already written on the same element by cmark (`id` on an anchored
heading, `start` on an ordered list, `class` on an aligned table cell, and
`role` on the table wrapper). Invalid attributes raise `RenderError`; errors
raised by the callback propagate to the rendering caller. Callbacks run as
application code and may intentionally add active attributes such as `style`
or event handlers; `safe=true` continues to apply to parsed Markdown input.

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

///|
test "node attributes retain same-parse metadata on block and list owners" {
  let source =
    #|# Title
    #|
    #|Paragraph.
    #|
    #|> quote
    #|
    #|3. first
    #|4. second
    #|
    #|- task
    #|
    #|```text
    #|code
    #|```
    #|
    #|---
  let doc = @cmark.Doc::from_string(source, locs=true, file="example.md")
  let owners : Array[(String, String)] = []
  let identities : Array[(String, Int)] = []
  let html = @cmark_html.from_doc(
    safe=true,
    node_attributes=fn(meta, tag) {
      assert_eq(meta.loc.file, "example.md")
      owners.push(
        (
          tag,
          source[meta.loc.first_ccode:meta.loc.last_ccode + 1].trim().to_owned(),
        ),
      )
      identities.push((tag, meta.id))
      [("data-node", "\{meta.id}")]
    },
    doc,
  )
  assert_eq(owners, [
    ("h1", "# Title"),
    ("p", "Paragraph."),
    // cmark shares metadata between this one-child quote and its paragraph.
    ("blockquote", "quote"),
    ("p", "quote"),
    ("ol", "3. first\n4. second"),
    ("li", "3. first"),
    ("li", "4. second"),
    ("ul", "- task"),
    ("li", "- task"),
    ("pre", "```text\ncode\n```"),
    ("hr", "---"),
  ])
  guard doc.block is Blocks({ v: blocks, .. }) else {
    fail("expected the fixture's block sequence")
  }
  let rendered_blocks = blocks
    .to_array()
    .filter(block => !(block is BlankLine(_)))
  guard rendered_blocks
    is [
      Heading(heading),
      Paragraph(paragraph),
      BlockQuote(quote),
      List(ordered),
      List(unordered),
      CodeBlock(code),
      ThematicBreak(rule),
    ] else {
    fail("unexpected blocks in the fixture")
  }
  assert_eq(identities, [
    ("h1", heading.meta.id),
    ("p", paragraph.meta.id),
    ("blockquote", quote.meta.id),
    ("p", quote.v.block.meta().id),
    ("ol", ordered.meta.id),
    ("li", ordered.v.items[0].meta.id),
    ("li", ordered.v.items[1].meta.id),
    ("ul", unordered.meta.id),
    ("li", unordered.v.items[0].meta.id),
    ("pre", code.meta.id),
    ("hr", rule.meta.id),
  ])
  for (tag, id) in identities {
    assert_true(html.contains("<\{tag} data-node=\"\{id}\""))
  }
}

///|
test "table owners retain cell markup and skip synthetic padding cells" {
  let source =
    #|| Name | 中文 |
    #||:---|---:|
    #|| **one** | 😀 *two* |
    #|| short |
  let doc = @cmark.Doc::from_string(source, strict=false, locs=true)
  let owners : Array[(String, String)] = []
  let html = @cmark_html.from_doc(
    safe=true,
    node_attributes=fn(meta, tag) {
      owners.push(
        (
          tag,
          source[meta.loc.first_ccode:meta.loc.last_ccode + 1].trim().to_owned(),
        ),
      )
      [("data-kind", tag)]
    },
    doc,
  )
  assert_eq(owners, [
    ("div", source),
    ("tr", "| Name | 中文 |"),
    ("th", "Name"),
    ("th", "中文"),
    ("tr", "| **one** | 😀 *two* |"),
    ("td", "**one**"),
    ("td", "😀 *two*"),
    ("tr", "| short |"),
    ("td", "short"),
  ])
  assert_eq(
    html, "<div role=\"region\" data-kind=\"div\"><table>\n<tr data-kind=\"tr\">\n<th data-kind=\"th\" class=\"left\">Name</th>\n<th data-kind=\"th\" class=\"right\">中文</th>\n</tr>\n<tr data-kind=\"tr\">\n<td data-kind=\"td\" class=\"left\"><strong>one</strong></td>\n<td data-kind=\"td\" class=\"right\">😀 <em>two</em></td>\n</tr>\n<tr data-kind=\"tr\">\n<td data-kind=\"td\" class=\"left\">short</td>\n<td class=\"right\"></td>\n</tr>\n</table></div>",
  )
}

///|
test "attribute values are escaped through the convenience rendering API" {
  assert_eq(
    @cmark_html.render(
      node_attributes=fn(_, _) {
        [("data-value", "<&\"😀>"), ("aria-label", "source & quote")]
      },
      "text",
    ),
    "<p data-value=\"&lt;&amp;&quot;😀&gt;\" aria-label=\"source &amp; quote\">text</p>\n",
  )
}

///|
test "invalid attribute names fail rather than injecting markup" {
  for
    name in ["", "bad name", "bad\nname", "x\"", "x'", "x=", "x>", "x/", "3bad"] {
    try
      @cmark_html.render(node_attributes=fn(_, _) { [(name, "value")] }, "text")
    catch {
      @cmark_renderer.RenderError(message) =>
        assert_eq(message, "invalid HTML attribute name: \{name}")
      _ => fail("expected an attribute-name RenderError")
    } noraise {
      _ => fail("expected invalid attribute name to fail")
    }
  }
}

///|
test "duplicate attributes and renderer-owned attributes fail case-insensitively" {
  for
    (source, attributes, duplicate) in [
      ("text", [("data-id", "one"), ("DATA-ID", "two")], "DATA-ID"),
      ("# Title", [("ID", "override")], "ID"),
      ("3. item", [("start", "1")], "start"),
      ("| A |\n| :--- |\n| B |", [("CLASS", "extra")], "CLASS"),
      ("| A |\n| --- |\n| B |", [("role", "other")], "role"),
    ] {
    let doc = @cmark.Doc::from_string(
      source,
      strict=false,
      heading_auto_ids=true,
    )
    try
      @cmark_html.from_doc(
        safe=true,
        node_attributes=fn(_, _) { attributes },
        doc,
      )
    catch {
      @cmark_renderer.RenderError(message) =>
        assert_eq(message, "duplicate HTML attribute: \{duplicate}")
      _ => fail("expected a duplicate-attribute RenderError")
    } noraise {
      _ => fail("expected duplicate attribute to fail")
    }
  }
}

///|
test "empty attributes preserve default HTML and XHTML output" {
  let source =
    #|# Heading
    #|
    #|- item
    #|
    #|| A |
    #|| --- |
    #|| B |
    #|
    #|![image](https://example.test/image.png)
    #|
    #|---
    #|
    #|<div>raw HTML</div>
    #|
    #|```=html
    #|<b>backend HTML</b>
    #|```
  let doc = @cmark.Doc::from_string(source, strict=false, heading_auto_ids=true)
  for safe in [true, false] {
    for backend_blocks in [true, false] {
      assert_eq(
        @cmark_html.renderer(safe~, backend_blocks~, node_attributes=fn(_, _) {
          []
        }).doc_to_string(doc),
        @cmark_html.renderer(safe~, backend_blocks~).doc_to_string(doc),
      )
      assert_eq(
        @cmark_html.xhtml_renderer(safe~, backend_blocks~, node_attributes=fn(
          _,
          _,
        ) {
          []
        }).doc_to_string(doc),
        @cmark_html.xhtml_renderer(safe~, backend_blocks~).doc_to_string(doc),
      )
    }
  }
  let xhtml = @cmark_html.xhtml_renderer(safe=true, node_attributes=fn(_, tag) {
    [("data-kind", tag)]
  }).doc_to_string(doc)
  assert_true(xhtml.contains("<hr data-kind=\"hr\" />"))
  assert_true(xhtml.contains("<p data-kind=\"p\"><img"))
  assert_true(xhtml.contains("image.png\" alt=\"image\" />"))
}

///|
test "node attributes compose with overrides and survive renderer reuse" {
  let doc = @cmark.Doc::from_string(
    "# Heading\n\nplain\n\n```text\ncode\n```",
    heading_auto_ids=true,
  )
  let calls : Array[String] = []
  let r = @cmark_html.renderer(safe=true, node_attributes=fn(_, tag) {
    calls.push(tag)
    [("data-kind", tag)]
  }).compose(
    @cmark_renderer.Renderer::new(block=fn(c, block) {
      if block is CodeBlock(_) {
        c.string("<pre class=\"custom\">custom code</pre>\n")
        true
      } else {
        false
      }
    }),
  )
  let first = r.doc_to_string(doc)
  let second = r.doc_to_string(doc)
  assert_eq(first, second)
  assert_eq(calls, ["h1", "p", "h1", "p"])
  assert_eq(
    first, "<h1 data-kind=\"h1\" id=\"heading\"><a class=\"anchor\" aria-hidden=\"true\" href=\"#heading\"></a>Heading</h1>\n<p data-kind=\"p\">plain</p>\n<pre class=\"custom\">custom code</pre>\n",
  )
}

///|
test "attribute callback errors propagate to the rendering caller" {
  try
    @cmark_html.render(
      node_attributes=fn(_, _) {
        raise @cmark_renderer.RenderError("attribute provider failed")
      },
      "text",
    )
  catch {
    @cmark_renderer.RenderError(message) =>
      assert_eq(message, "attribute provider failed")
    _ => fail("expected the callback error")
  } noraise {
    _ => fail("expected the callback error to propagate")
  }
}

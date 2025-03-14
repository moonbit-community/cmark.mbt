---
moonbit: true
---

# `cmark`

This package provides a CommonMark parser in MoonBit, with support for tables, task lists, math blocks, and more.

## Basic Usage

Let's start with a simple example of parsing Markdown text:

```moonbit
test "basic parsing" {
  let input =
    #|# Hello World
    #|
    #|This is a paragraph.
  let doc = @cmark.Doc::from_string(input)
  // Should contain a heading and a paragraph
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "Blocks",
      "0": [
        [
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 1,
                "inline": { "$tag": "Text", "0": ["Hello World"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": { "$tag": "Text", "0": ["This is a paragraph."] },
                "trailing_blanks": "",
              },
            ],
          },
        ],
      ],
    },
    "defs": {},
  })
}
```

Below are some simple examples showing how to parse Markdown text with `cmark` and
what the resulting syntax tree looks like. For more examples, please checkout the test suite.

## Working with Inline Elements

### Emphasis and Strong Emphasis

```moonbit
test "emphasis and strong emphasis" {
  let input =
    #|_Emphasis_ and **strong emphasis**
  let doc = @cmark.Doc::from_string(input)
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "Paragraph",
      "0": [
        {
          "leading_indent": 0,
          "inline": {
            "$tag": "Inlines",
            "0": [
              [
                {
                  "$tag": "Emphasis",
                  "0": [
                    {
                      "delim": "_",
                      "inline": { "$tag": "Text", "0": ["Emphasis"] },
                    },
                  ],
                },
                { "$tag": "Text", "0": [" and "] },
                {
                  "$tag": "StrongEmphasis",
                  "0": [
                    {
                      "delim": "*",
                      "inline": { "$tag": "Text", "0": ["strong emphasis"] },
                    },
                  ],
                },
              ],
            ],
          },
          "trailing_blanks": "",
        },
      ],
    },
    "defs": {},
  })
}
```

### Inline Code and Math

```moonbit
test "inline code and math" {
  let input =
    $|$E = mc^2$ in Python: `E = m * (c ** 2)`
  let doc = @cmark.Doc::from_string(input, strict=false)
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "Paragraph",
      "0": [
        {
          "leading_indent": 0,
          "inline": {
            "$tag": "Inlines",
            "0": [
              [
                {
                  "$tag": "ExtMathSpan",
                  "0": [
                    {
                      "display": false,
                      "tex_layout": [{ "blanks": "", "node": ["E = mc^2"] }],
                    },
                  ],
                },
                { "$tag": "Text", "0": [" in Python: "] },
                {
                  "$tag": "CodeSpan",
                  "0": [
                    {
                      "backticks": 1,
                      "code_layout": [
                        { "blanks": "", "node": ["E = m * (c ** 2)"] },
                      ],
                    },
                  ],
                },
              ],
            ],
          },
          "trailing_blanks": "",
        },
      ],
    },
    "defs": {},
  })
}
```

## Working with Block-Level Elements

### Headings

```moonbit
test "headings" {
  let input =
    #|# Level 1
  let doc = @cmark.Doc::from_string(input)
  // Should contain a heading and a paragraph
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "Heading",
      "0": [
        {
          "layout": {
            "$tag": "Atx",
            "0": { "indent": 0, "after_opening": "", "closing": "" },
          },
          "level": 1,
          "inline": { "$tag": "Text", "0": ["Level 1"] },
        },
      ],
    },
    "defs": {},
  })
}
```

### Lists

```moonbit
test "lists" {
  let input =
    #|- First item
    #|- Second item
    #|  1. Nested item
  let doc = @cmark.Doc::from_string(input)
  // Should find an ordered list within an unordered one.
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "List",
      "0": [
        {
          "ty": { "$tag": "Unordered", "0": "-" },
          "tight": true,
          "items": [
            [
              {
                "before_marker": 0,
                "marker": ["-"],
                "after_marker": 1,
                "block": {
                  "$tag": "Paragraph",
                  "0": [
                    {
                      "leading_indent": 0,
                      "inline": { "$tag": "Text", "0": ["First item"] },
                      "trailing_blanks": "",
                    },
                  ],
                },
              },
            ],
            [
              {
                "before_marker": 0,
                "marker": ["-"],
                "after_marker": 1,
                "block": {
                  "$tag": "Blocks",
                  "0": [
                    [
                      {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": { "$tag": "Text", "0": ["Second item"] },
                            "trailing_blanks": "",
                          },
                        ],
                      },
                      {
                        "$tag": "List",
                        "0": [
                          {
                            "ty": { "$tag": "Ordered", "0": 1, "1": "." },
                            "tight": true,
                            "items": [
                              [
                                {
                                  "before_marker": 0,
                                  "marker": ["1."],
                                  "after_marker": 1,
                                  "block": {
                                    "$tag": "Paragraph",
                                    "0": [
                                      {
                                        "leading_indent": 0,
                                        "inline": {
                                          "$tag": "Text",
                                          "0": ["Nested item"],
                                        },
                                        "trailing_blanks": "",
                                      },
                                    ],
                                  },
                                },
                              ],
                            ],
                          },
                        ],
                      },
                    ],
                  ],
                },
              },
            ],
          ],
        },
      ],
    },
    "defs": {},
  })
}
```

### Code Blocks

```moonbit
test "code blocks" {
  let tick3 = "`".repeat(3)
  let input =
    $|\{tick3}moonbit
    #|fn main {
    #|  println("Hello")
    #|}
    $|\{tick3}
  let doc = @cmark.Doc::from_string(input)
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "CodeBlock",
      "0": [
        {
          "layout": {
            "$tag": "Fenced",
            "0": { "indent": 0, "opening_fence": [""], "closing_fence": [""] },
          },
          "info_string": ["moonbit"],
          "code": [["fn main {"], ["  println(\"Hello\")"], ["}"]],
        },
      ],
    },
    "defs": {},
  })
}
```

### Tables

```moonbit
test "tables" {
  let input =
    #|| Header 1 | Header 2 |
    #||----------|----------|
    #|| Cell 1   | Cell 2   |
  let doc = @cmark.Doc::from_string(input, strict=false)
  let null = Null
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "ExtTable",
      "0": [
        {
          "indent": 0,
          "col_count": 2,
          "rows": [
            [
              [
                {
                  "$tag": "Header",
                  "0": [
                    [{ "$tag": "Text", "0": ["Header 1"] }, ["", ""]],
                    [{ "$tag": "Text", "0": ["Header 2"] }, ["", ""]],
                  ],
                },
              ],
              "",
            ],
            [[{ "$tag": "Sep", "0": [[[null, 10]], [[null, 10]]] }], ""],
            [
              [
                {
                  "$tag": "Data",
                  "0": [
                    [{ "$tag": "Text", "0": ["Cell 1"] }, ["", ""]],
                    [{ "$tag": "Text", "0": ["Cell 2"] }, ["", ""]],
                  ],
                },
              ],
              "",
            ],
          ],
        },
      ],
    },
    "defs": {},
  })
}
```

### Footnotes

```moonbit
test "footnotes" {
  let input =
    #|Text[^1]
    #|
    #|[^1]: Footnote content
  let doc = @cmark.Doc::from_string(input, strict=false)
  @json.inspect!(doc, content={
    "nl": "\n",
    "block": {
      "$tag": "Blocks",
      "0": [
        [
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["Text"] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["^1"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Shortcut" },
                              "1": {
                                "meta": {},
                                "key": "^1",
                                "text": [{ "blanks": "", "node": ["^1"] }],
                              },
                              "2": {
                                "meta": {},
                                "key": "^1",
                                "text": [{ "blanks": "", "node": ["^1"] }],
                              },
                            },
                          },
                        ],
                      },
                    ],
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "ExtFootnoteDefinition",
            "0": [
              {
                "indent": 0,
                "label": {
                  "meta": {},
                  "key": "^1",
                  "text": [{ "blanks": "", "node": ["^1"] }],
                },
                "defined_label": {
                  "meta": {},
                  "key": "^1",
                  "text": [{ "blanks": "", "node": ["^1"] }],
                },
                "block": {
                  "$tag": "Paragraph",
                  "0": [
                    {
                      "leading_indent": 1,
                      "inline": { "$tag": "Text", "0": ["Footnote content"] },
                      "trailing_blanks": "",
                    },
                  ],
                },
              },
            ],
          },
        ],
      ],
    },
    "defs": {
      "^1": {
        "$tag": "FootnoteDef",
        "0": [
          {
            "indent": 0,
            "label": {
              "meta": {},
              "key": "^1",
              "text": [{ "blanks": "", "node": ["^1"] }],
            },
            "defined_label": {
              "meta": {},
              "key": "^1",
              "text": [{ "blanks": "", "node": ["^1"] }],
            },
            "block": {
              "$tag": "Paragraph",
              "0": [
                {
                  "leading_indent": 1,
                  "inline": { "$tag": "Text", "0": ["Footnote content"] },
                  "trailing_blanks": "",
                },
              ],
            },
          },
        ],
      },
    },
  })
}
```

## Document Transformation

In addition, this package provides powerful APIs for transforming documents using the `Mapper` and `Folder` APIs.

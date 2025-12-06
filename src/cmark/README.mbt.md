# `cmark`

This package provides a CommonMark parser in MoonBit, with support for tables, task lists, math blocks, and more.

## Basic Usage

Let's start with a simple example of parsing Markdown text:

```mbt check
///|
test "basic parsing" {
  let input =
    #|# Hello World
    #|
    #|This is a paragraph.
  let doc = @cmark.Doc::from_string(input)
  // Should contain a heading and a paragraph
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "Blocks",
      [
        [
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 1,
                "inline": ["Text", ["Hello World"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": ["Text", ["This is a paragraph."]],
                "trailing_blanks": "",
              },
            ],
          ],
        ],
      ],
    ],
    "defs": {},
  })
}
```

Below are some simple examples showing how to parse Markdown text with `cmark` and
what the resulting syntax tree looks like. For more examples, please checkout the test suite.

## Working with Inline Elements

### Emphasis and Strong Emphasis

```mbt check
///|
test "emphasis and strong emphasis" {
  let input =
    #|_Emphasis_ and **strong emphasis**
  let doc = @cmark.Doc::from_string(input)
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "Paragraph",
      [
        {
          "leading_indent": 0,
          "inline": [
            "Inlines",
            [
              [
                [
                  "Emphasis",
                  [{ "delim": "_", "inline": ["Text", ["Emphasis"]] }],
                ],
                ["Text", [" and "]],
                [
                  "StrongEmphasis",
                  [{ "delim": "*", "inline": ["Text", ["strong emphasis"]] }],
                ],
              ],
            ],
          ],
          "trailing_blanks": "",
        },
      ],
    ],
    "defs": {},
  })
}
```

### Inline Code and Math

```mbt check
///|
test "inline code and math" {
  let input =
    $|$E = mc^2$ in Python: `E = m * (c ** 2)`
  let doc = @cmark.Doc::from_string(input, strict=false)
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "Paragraph",
      [
        {
          "leading_indent": 0,
          "inline": [
            "Inlines",
            [
              [
                [
                  "ExtMathSpan",
                  [
                    {
                      "display": false,
                      "tex_layout": [{ "blanks": "", "node": ["E = mc^2"] }],
                    },
                  ],
                ],
                ["Text", [" in Python: "]],
                [
                  "CodeSpan",
                  [
                    {
                      "backticks": 1,
                      "code_layout": [
                        { "blanks": "", "node": ["E = m * (c ** 2)"] },
                      ],
                    },
                  ],
                ],
              ],
            ],
          ],
          "trailing_blanks": "",
        },
      ],
    ],
    "defs": {},
  })
}
```

## Working with Block-Level Elements

### Headings

```mbt check
///|
test "headings" {
  let input =
    #|# Level 1
  let doc = @cmark.Doc::from_string(input)
  // Should contain a heading and a paragraph
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "Heading",
      [
        {
          "layout": ["Atx", { "indent": 0, "after_opening": "", "closing": "" }],
          "level": 1,
          "inline": ["Text", ["Level 1"]],
        },
      ],
    ],
    "defs": {},
  })
}
```

### Lists

```mbt check
///|
test "lists" {
  let input =
    #|- First item
    #|- Second item
    #|  1. Nested item
  let doc = @cmark.Doc::from_string(input)
  // Should find an ordered list within an unordered one.
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "List",
      [
        {
          "ty": ["Unordered", "-"],
          "tight": true,
          "items": [
            [
              {
                "before_marker": 0,
                "marker": ["-"],
                "after_marker": 1,
                "block": [
                  "Paragraph",
                  [
                    {
                      "leading_indent": 0,
                      "inline": ["Text", ["First item"]],
                      "trailing_blanks": "",
                    },
                  ],
                ],
              },
            ],
            [
              {
                "before_marker": 0,
                "marker": ["-"],
                "after_marker": 1,
                "block": [
                  "Blocks",
                  [
                    [
                      [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": ["Text", ["Second item"]],
                            "trailing_blanks": "",
                          },
                        ],
                      ],
                      [
                        "List",
                        [
                          {
                            "ty": ["Ordered", 1, "."],
                            "tight": true,
                            "items": [
                              [
                                {
                                  "before_marker": 0,
                                  "marker": ["1."],
                                  "after_marker": 1,
                                  "block": [
                                    "Paragraph",
                                    [
                                      {
                                        "leading_indent": 0,
                                        "inline": ["Text", ["Nested item"]],
                                        "trailing_blanks": "",
                                      },
                                    ],
                                  ],
                                },
                              ],
                            ],
                          },
                        ],
                      ],
                    ],
                  ],
                ],
              },
            ],
          ],
        },
      ],
    ],
    "defs": {},
  })
}
```

### Code Blocks

```mbt check
///|
test "code blocks" {
  let tick3 = "`".repeat(3)
  let input =
    $|\{tick3}moonbit
    #|fn main {
    #|  println("Hello")
    #|}
    $|\{tick3}
  let doc = @cmark.Doc::from_string(input)
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "CodeBlock",
      [
        {
          "layout": [
            "Fenced",
            { "indent": 0, "opening_fence": [""], "closing_fence": [""] },
          ],
          "info_string": ["moonbit"],
          "code": [["fn main {"], ["  println(\"Hello\")"], ["}"]],
        },
      ],
    ],
    "defs": {},
  })
}
```

### Tables

```mbt check
///|
test "tables" {
  let input =
    #|| Header 1 | Header 2 |
    #||----------|----------|
    #|| Cell 1   | Cell 2   |
  let doc = @cmark.Doc::from_string(input, strict=false)
  let null = Json::null()
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "ExtTable",
      [
        {
          "indent": 0,
          "col_count": 2,
          "rows": [
            [
              [
                [
                  "Header",
                  [
                    [["Text", ["Header 1"]], ["TableCellLayout", ["", ""]]],
                    [["Text", ["Header 2"]], ["TableCellLayout", ["", ""]]],
                  ],
                ],
              ],
              "",
            ],
            [
              [
                [
                  "Sep",
                  [[["TableSep", [null, 10]]], [["TableSep", [null, 10]]]],
                ],
              ],
              "",
            ],
            [
              [
                [
                  "Data",
                  [
                    [["Text", ["Cell 1"]], ["TableCellLayout", ["", ""]]],
                    [["Text", ["Cell 2"]], ["TableCellLayout", ["", ""]]],
                  ],
                ],
              ],
              "",
            ],
          ],
        },
      ],
    ],
    "defs": {},
  })
}
```

### Footnotes

```mbt check
///|
test "footnotes" {
  let input =
    #|Text[^1]
    #|
    #|[^1]: Footnote content
  let doc = @cmark.Doc::from_string(input, strict=false)
  @json.inspect(doc, content={
    "nl": "\n",
    "block": [
      "Blocks",
      [
        [
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": [
                  "Inlines",
                  [
                    [
                      ["Text", ["Text"]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["^1"]],
                            "reference": [
                              "Ref",
                              "Shortcut",
                              {
                                "meta": {},
                                "key": "^1",
                                "text": [{ "blanks": "", "node": ["^1"] }],
                              },
                              {
                                "meta": {},
                                "key": "^1",
                                "text": [{ "blanks": "", "node": ["^1"] }],
                              },
                            ],
                          },
                        ],
                      ],
                    ],
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "ExtFootnoteDefinition",
            [
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
                "block": [
                  "Paragraph",
                  [
                    {
                      "leading_indent": 1,
                      "inline": ["Text", ["Footnote content"]],
                      "trailing_blanks": "",
                    },
                  ],
                ],
              },
            ],
          ],
        ],
      ],
    ],
    "defs": {
      "^1": [
        "FootnoteDef",
        [
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
            "block": [
              "Paragraph",
              [
                {
                  "leading_indent": 1,
                  "inline": ["Text", ["Footnote content"]],
                  "trailing_blanks": "",
                },
              ],
            ],
          },
        ],
      ],
    },
  })
}
```

## Document Transformation

In addition, this package provides powerful APIs for transforming documents using the `Mapper` and `Folder` APIs.

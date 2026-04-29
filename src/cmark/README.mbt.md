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
  let doc = @cmark.Doc(input)
  // Should contain a heading and a paragraph
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Blocks(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "Hello World",
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                id: None,
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|          BlankLine(
      #|            {
      #|              v: "",
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|          Paragraph(
      #|            {
      #|              v: {
      #|                leading_indent: 0,
      #|                inline: Text(
      #|                  {
      #|                    v: "This is a paragraph.",
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                trailing_blanks: "",
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|        ],
      #|      ),
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
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
  let doc = @cmark.Doc(input)
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Paragraph(
      #|    {
      #|      v: {
      #|        leading_indent: 0,
      #|        inline: Inlines(
      #|          {
      #|            v: Seq(
      #|              [
      #|                Emphasis(
      #|                  {
      #|                    v: {
      #|                      delim: '_',
      #|                      inline: Text(
      #|                        {
      #|                          v: "Emphasis",
      #|                          meta: {
      #|                            id: 0,
      #|                            loc: {
      #|                              file: "-",
      #|                              first_ccode: -1,
      #|                              last_ccode: -1,
      #|                              first_line: LinePos(-1, -1),
      #|                              last_line: LinePos(-1, -1),
      #|                            },
      #|                            extra: None,
      #|                          },
      #|                        },
      #|                      ),
      #|                    },
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                Text(
      #|                  {
      #|                    v: " and ",
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                StrongEmphasis(
      #|                  {
      #|                    v: {
      #|                      delim: '*',
      #|                      inline: Text(
      #|                        {
      #|                          v: "strong emphasis",
      #|                          meta: {
      #|                            id: 0,
      #|                            loc: {
      #|                              file: "-",
      #|                              first_ccode: -1,
      #|                              last_ccode: -1,
      #|                              first_line: LinePos(-1, -1),
      #|                              last_line: LinePos(-1, -1),
      #|                            },
      #|                            extra: None,
      #|                          },
      #|                        },
      #|                      ),
      #|                    },
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|              ],
      #|            ),
      #|            meta: {
      #|              id: 0,
      #|              loc: {
      #|                file: "-",
      #|                first_ccode: -1,
      #|                last_ccode: -1,
      #|                first_line: LinePos(-1, -1),
      #|                last_line: LinePos(-1, -1),
      #|              },
      #|              extra: None,
      #|            },
      #|          },
      #|        ),
      #|        trailing_blanks: "",
      #|      },
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
}
```

### Inline Code and Math

```mbt check
///|
test "inline code and math" {
  let input =
    $|$E = mc^2$ in Python: `E = m * (c ** 2)`
  let doc = @cmark.Doc(input, strict=false)
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Paragraph(
      #|    {
      #|      v: {
      #|        leading_indent: 0,
      #|        inline: Inlines(
      #|          {
      #|            v: Seq(
      #|              [
      #|                ExtMathSpan(
      #|                  {
      #|                    v: {
      #|                      display: false,
      #|                      tex_layout: Seq(
      #|                        [
      #|                          {
      #|                            blanks: "",
      #|                            node: { v: "E = mc^2", meta: { id: 0, loc: ..., extra: None } },
      #|                          },
      #|                        ],
      #|                      ),
      #|                    },
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                Text(
      #|                  {
      #|                    v: " in Python: ",
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                CodeSpan(
      #|                  {
      #|                    v: {
      #|                      backticks: 1,
      #|                      code_layout: Seq(
      #|                        [
      #|                          {
      #|                            blanks: "",
      #|                            node: { v: "E = m * (c ** 2)", meta: { id: 0, loc: ..., extra: None } },
      #|                          },
      #|                        ],
      #|                      ),
      #|                    },
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|              ],
      #|            ),
      #|            meta: {
      #|              id: 0,
      #|              loc: {
      #|                file: "-",
      #|                first_ccode: -1,
      #|                last_ccode: -1,
      #|                first_line: LinePos(-1, -1),
      #|                last_line: LinePos(-1, -1),
      #|              },
      #|              extra: None,
      #|            },
      #|          },
      #|        ),
      #|        trailing_blanks: "",
      #|      },
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
}
```

## Working with Block-Level Elements

### Headings

```mbt check
///|
test "headings" {
  let input =
    #|# Level 1
  let doc = @cmark.Doc(input)
  // Should contain a heading and a paragraph
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Heading(
      #|    {
      #|      v: {
      #|        layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|        level: 1,
      #|        inline: Text(
      #|          {
      #|            v: "Level 1",
      #|            meta: {
      #|              id: 0,
      #|              loc: {
      #|                file: "-",
      #|                first_ccode: -1,
      #|                last_ccode: -1,
      #|                first_line: LinePos(-1, -1),
      #|                last_line: LinePos(-1, -1),
      #|              },
      #|              extra: None,
      #|            },
      #|          },
      #|        ),
      #|        id: None,
      #|      },
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
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
  let doc = @cmark.Doc(input)
  // Should find an ordered list within an unordered one.
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: List(
      #|    {
      #|      v: {
      #|        ty: Unordered('-'),
      #|        tight: true,
      #|        items: Seq(
      #|          [
      #|            {
      #|              v: {
      #|                before_marker: 0,
      #|                marker: {
      #|                  v: "-",
      #|                  meta: {
      #|                    id: 0,
      #|                    loc: {
      #|                      file: "-",
      #|                      first_ccode: -1,
      #|                      last_ccode: -1,
      #|                      first_line: LinePos(-1, -1),
      #|                      last_line: LinePos(-1, -1),
      #|                    },
      #|                    extra: None,
      #|                  },
      #|                },
      #|                after_marker: 1,
      #|                block: Paragraph(
      #|                  {
      #|                    v: {
      #|                      leading_indent: 0,
      #|                      inline: Text(
      #|                        {
      #|                          v: "First item",
      #|                          meta: {
      #|                            id: 0,
      #|                            loc: {
      #|                              file: "-",
      #|                              first_ccode: -1,
      #|                              last_ccode: -1,
      #|                              first_line: LinePos(-1, -1),
      #|                              last_line: LinePos(-1, -1),
      #|                            },
      #|                            extra: None,
      #|                          },
      #|                        },
      #|                      ),
      #|                      trailing_blanks: "",
      #|                    },
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                ext_task_marker: None,
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|            {
      #|              v: {
      #|                before_marker: 0,
      #|                marker: {
      #|                  v: "-",
      #|                  meta: {
      #|                    id: 0,
      #|                    loc: {
      #|                      file: "-",
      #|                      first_ccode: -1,
      #|                      last_ccode: -1,
      #|                      first_line: LinePos(-1, -1),
      #|                      last_line: LinePos(-1, -1),
      #|                    },
      #|                    extra: None,
      #|                  },
      #|                },
      #|                after_marker: 1,
      #|                block: Blocks(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Paragraph(
      #|                          {
      #|                            v: { leading_indent: 0, inline: Text(...), trailing_blanks: "" },
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                        List(
      #|                          {
      #|                            v: { ty: Ordered(1, '.'), tight: true, items: Seq(...) },
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                      ],
      #|                    ),
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                ext_task_marker: None,
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ],
      #|        ),
      #|      },
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
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
  let doc = @cmark.Doc(input)
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: CodeBlock(
      #|    {
      #|      v: {
      #|        layout: Fenced(
      #|          {
      #|            indent: 0,
      #|            opening_fence: {
      #|              v: "",
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|            closing_fence: Some(
      #|              {
      #|                v: "",
      #|                meta: {
      #|                  id: 0,
      #|                  loc: {
      #|                    file: "-",
      #|                    first_ccode: -1,
      #|                    last_ccode: -1,
      #|                    first_line: LinePos(-1, -1),
      #|                    last_line: LinePos(-1, -1),
      #|                  },
      #|                  extra: None,
      #|                },
      #|              },
      #|            ),
      #|          },
      #|        ),
      #|        info_string: Some(
      #|          {
      #|            v: "moonbit",
      #|            meta: {
      #|              id: 0,
      #|              loc: {
      #|                file: "-",
      #|                first_ccode: -1,
      #|                last_ccode: -1,
      #|                first_line: LinePos(-1, -1),
      #|                last_line: LinePos(-1, -1),
      #|              },
      #|              extra: None,
      #|            },
      #|          },
      #|        ),
      #|        code: Seq(
      #|          [
      #|            {
      #|              v: "fn main {",
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|            {
      #|              v: "  println(\"Hello\")",
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|            {
      #|              v: "}",
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ],
      #|        ),
      #|      },
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
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
  let doc = @cmark.Doc(input, strict=false)
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: ExtTable(
      #|    {
      #|      v: {
      #|        indent: 0,
      #|        col_count: 2,
      #|        rows: Seq(
      #|          [
      #|            (
      #|              {
      #|                v: Header(
      #|                  Seq(
      #|                    [
      #|                      (
      #|                        Text(
      #|                          {
      #|                            v: "Header 1",
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                        TableCellLayout(("", "")),
      #|                      ),
      #|                      (
      #|                        Text(
      #|                          {
      #|                            v: "Header 2",
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                        TableCellLayout(("", "")),
      #|                      ),
      #|                    ],
      #|                  ),
      #|                ),
      #|                meta: {
      #|                  id: 0,
      #|                  loc: {
      #|                    file: "-",
      #|                    first_ccode: -1,
      #|                    last_ccode: -1,
      #|                    first_line: LinePos(-1, -1),
      #|                    last_line: LinePos(-1, -1),
      #|                  },
      #|                  extra: None,
      #|                },
      #|              },
      #|              "",
      #|            ),
      #|            (
      #|              {
      #|                v: Sep(
      #|                  Seq(
      #|                    [
      #|                      {
      #|                        v: TableSep((None, 10)),
      #|                        meta: {
      #|                          id: 0,
      #|                          loc: {
      #|                            file: "-",
      #|                            first_ccode: -1,
      #|                            last_ccode: -1,
      #|                            first_line: LinePos(-1, -1),
      #|                            last_line: LinePos(-1, -1),
      #|                          },
      #|                          extra: None,
      #|                        },
      #|                      },
      #|                      {
      #|                        v: TableSep((None, 10)),
      #|                        meta: {
      #|                          id: 0,
      #|                          loc: {
      #|                            file: "-",
      #|                            first_ccode: -1,
      #|                            last_ccode: -1,
      #|                            first_line: LinePos(-1, -1),
      #|                            last_line: LinePos(-1, -1),
      #|                          },
      #|                          extra: None,
      #|                        },
      #|                      },
      #|                    ],
      #|                  ),
      #|                ),
      #|                meta: {
      #|                  id: 0,
      #|                  loc: {
      #|                    file: "-",
      #|                    first_ccode: -1,
      #|                    last_ccode: -1,
      #|                    first_line: LinePos(-1, -1),
      #|                    last_line: LinePos(-1, -1),
      #|                  },
      #|                  extra: None,
      #|                },
      #|              },
      #|              "",
      #|            ),
      #|            (
      #|              {
      #|                v: Data(
      #|                  Seq(
      #|                    [
      #|                      (
      #|                        Text(
      #|                          {
      #|                            v: "Cell 1",
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                        TableCellLayout(("", "")),
      #|                      ),
      #|                      (
      #|                        Text(
      #|                          {
      #|                            v: "Cell 2",
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                        TableCellLayout(("", "")),
      #|                      ),
      #|                    ],
      #|                  ),
      #|                ),
      #|                meta: {
      #|                  id: 0,
      #|                  loc: {
      #|                    file: "-",
      #|                    first_ccode: -1,
      #|                    last_ccode: -1,
      #|                    first_line: LinePos(-1, -1),
      #|                    last_line: LinePos(-1, -1),
      #|                  },
      #|                  extra: None,
      #|                },
      #|              },
      #|              "",
      #|            ),
      #|          ],
      #|        ),
      #|      },
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {},
      #|}
    ),
  )
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
  let doc = @cmark.Doc(input, strict=false)
  debug_inspect(
    doc,
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Blocks(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Paragraph(
      #|            {
      #|              v: {
      #|                leading_indent: 0,
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "Text",
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                        Link(
      #|                          {
      #|                            v: { text: Text(...), reference: Ref(Shortcut, ..., ...) },
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        ),
      #|                      ],
      #|                    ),
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                trailing_blanks: "",
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|          BlankLine(
      #|            {
      #|              v: "",
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|          ExtFootnoteDefinition(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                label: {
      #|                  meta: {
      #|                    id: 0,
      #|                    loc: {
      #|                      file: "-",
      #|                      first_ccode: -1,
      #|                      last_ccode: -1,
      #|                      first_line: LinePos(-1, -1),
      #|                      last_line: LinePos(-1, -1),
      #|                    },
      #|                    extra: None,
      #|                  },
      #|                  key: "^1",
      #|                  text: Seq(
      #|                    [
      #|                      {
      #|                        blanks: "",
      #|                        node: {
      #|                          v: "^1",
      #|                          meta: {
      #|                            id: 0,
      #|                            loc: {
      #|                              file: "-",
      #|                              first_ccode: -1,
      #|                              last_ccode: -1,
      #|                              first_line: LinePos(-1, -1),
      #|                              last_line: LinePos(-1, -1),
      #|                            },
      #|                            extra: None,
      #|                          },
      #|                        },
      #|                      },
      #|                    ],
      #|                  ),
      #|                },
      #|                defined_label: Some(
      #|                  {
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                    key: "^1",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "^1",
      #|                            meta: {
      #|                              id: 0,
      #|                              loc: {
      #|                                file: "-",
      #|                                first_ccode: -1,
      #|                                last_ccode: -1,
      #|                                first_line: ...,
      #|                                last_line: ...,
      #|                              },
      #|                              extra: None,
      #|                            },
      #|                          },
      #|                        },
      #|                      ],
      #|                    ),
      #|                  },
      #|                ),
      #|                block: Paragraph(
      #|                  {
      #|                    v: {
      #|                      leading_indent: 1,
      #|                      inline: Text(
      #|                        {
      #|                          v: "Footnote content",
      #|                          meta: {
      #|                            id: 0,
      #|                            loc: {
      #|                              file: "-",
      #|                              first_ccode: -1,
      #|                              last_ccode: -1,
      #|                              first_line: LinePos(-1, -1),
      #|                              last_line: LinePos(-1, -1),
      #|                            },
      #|                            extra: None,
      #|                          },
      #|                        },
      #|                      ),
      #|                      trailing_blanks: "",
      #|                    },
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|        ],
      #|      ),
      #|      meta: {
      #|        id: 0,
      #|        loc: {
      #|          file: "-",
      #|          first_ccode: -1,
      #|          last_ccode: -1,
      #|          first_line: LinePos(-1, -1),
      #|          last_line: LinePos(-1, -1),
      #|        },
      #|        extra: None,
      #|      },
      #|    },
      #|  ),
      #|  defs: {
      #|    "^1": FootnoteDef(
      #|      {
      #|        v: {
      #|          indent: 0,
      #|          label: {
      #|            meta: {
      #|              id: 0,
      #|              loc: {
      #|                file: "-",
      #|                first_ccode: -1,
      #|                last_ccode: -1,
      #|                first_line: LinePos(-1, -1),
      #|                last_line: LinePos(-1, -1),
      #|              },
      #|              extra: None,
      #|            },
      #|            key: "^1",
      #|            text: Seq(
      #|              [
      #|                {
      #|                  blanks: "",
      #|                  node: {
      #|                    v: "^1",
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                },
      #|              ],
      #|            ),
      #|          },
      #|          defined_label: Some(
      #|            {
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|              key: "^1",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "^1",
      #|                      meta: {
      #|                        id: 0,
      #|                        loc: {
      #|                          file: "-",
      #|                          first_ccode: -1,
      #|                          last_ccode: -1,
      #|                          first_line: LinePos(-1, -1),
      #|                          last_line: LinePos(-1, -1),
      #|                        },
      #|                        extra: None,
      #|                      },
      #|                    },
      #|                  },
      #|                ],
      #|              ),
      #|            },
      #|          ),
      #|          block: Paragraph(
      #|            {
      #|              v: {
      #|                leading_indent: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "Footnote content",
      #|                    meta: {
      #|                      id: 0,
      #|                      loc: {
      #|                        file: "-",
      #|                        first_ccode: -1,
      #|                        last_ccode: -1,
      #|                        first_line: LinePos(-1, -1),
      #|                        last_line: LinePos(-1, -1),
      #|                      },
      #|                      extra: None,
      #|                    },
      #|                  },
      #|                ),
      #|                trailing_blanks: "",
      #|              },
      #|              meta: {
      #|                id: 0,
      #|                loc: {
      #|                  file: "-",
      #|                  first_ccode: -1,
      #|                  last_ccode: -1,
      #|                  first_line: LinePos(-1, -1),
      #|                  last_line: LinePos(-1, -1),
      #|                },
      #|                extra: None,
      #|              },
      #|            },
      #|          ),
      #|        },
      #|        meta: {
      #|          id: 0,
      #|          loc: {
      #|            file: "-",
      #|            first_ccode: -1,
      #|            last_ccode: -1,
      #|            first_line: LinePos(-1, -1),
      #|            last_line: LinePos(-1, -1),
      #|          },
      #|          extra: None,
      #|        },
      #|      },
      #|    ),
      #|  },
      #|}
    ),
  )
}
```

## Document Transformation

In addition, this package provides powerful APIs for transforming documents using the `Mapper` and `Folder` APIs.

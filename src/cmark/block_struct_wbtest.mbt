///|
test "plain" {
  let doc =
    #|Basic tests
    #|===========
    #|Basic tests for all CommonMark constructs.
  debug_inspect(
    Doc(doc),
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
      #|                layout: Setext(
      #|                  {
      #|                    leading_indent: 0,
      #|                    trailing_blanks: "",
      #|                    underline_indent: 0,
      #|                    underline_count: {
      #|                      v: 11,
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
      #|                    underline_blanks: "",
      #|                  },
      #|                ),
      #|                level: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "Basic tests",
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
      #|          Paragraph(
      #|            {
      #|              v: {
      #|                leading_indent: 0,
      #|                inline: Text(
      #|                  {
      #|                    v: "Basic tests for all CommonMark constructs.",
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

///|
test "complex ref definitions" {
  let doc =
    #|  to [c    d][]
    #|> [c d]: /ha "Multi
    #|>   line titles"
  debug_inspect(
    Doc(doc),
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
      #|                leading_indent: 2,
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "to ",
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
      #|                            v: { text: Text(...), reference: Ref(Collapsed, ..., ...) },
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: LinkRefDefinition(
      #|                  {
      #|                    v: {
      #|                      layout: {
      #|                        indent: 0,
      #|                        angled_dest: false,
      #|                        before_dest: Seq([{ v: " ", meta: { id: 0, loc: ..., extra: None } }]),
      #|                        after_dest: Seq([{ v: " ", meta: { id: 0, loc: ..., extra: None } }]),
      #|                        title_open_delim: '"',
      #|                        after_title: Seq([{ v: "", meta: { id: 0, loc: ..., extra: None } }]),
      #|                      },
      #|                      label: Some(
      #|                        {
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
      #|                          key: "c d",
      #|                          text: Seq([{ blanks: "", node: ... }]),
      #|                        },
      #|                      ),
      #|                      defined_label: Some(
      #|                        {
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
      #|                          key: "c d",
      #|                          text: Seq([{ blanks: "", node: ... }]),
      #|                        },
      #|                      ),
      #|                      dest: Some(
      #|                        {
      #|                          v: "/ha",
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
      #|                      title: Some(
      #|                        Seq(
      #|                          [
      #|                            { blanks: "", node: { v: "Multi", meta: ... } },
      #|                            { blanks: "", node: { v: "line titles", meta: ... } },
      #|                          ],
      #|                        ),
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
      #|    "c d": LinkDef(
      #|      {
      #|        v: {
      #|          layout: {
      #|            indent: 0,
      #|            angled_dest: false,
      #|            before_dest: Seq(
      #|              [
      #|                {
      #|                  v: " ",
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
      #|              ],
      #|            ),
      #|            after_dest: Seq(
      #|              [
      #|                {
      #|                  v: " ",
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
      #|              ],
      #|            ),
      #|            title_open_delim: '"',
      #|            after_title: Seq(
      #|              [
      #|                {
      #|                  v: "",
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
      #|              ],
      #|            ),
      #|          },
      #|          label: Some(
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
      #|              key: "c d",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "c d",
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
      #|              key: "c d",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "c d",
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
      #|          dest: Some(
      #|            {
      #|              v: "/ha",
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
      #|          title: Some(
      #|            Seq(
      #|              [
      #|                {
      #|                  blanks: "",
      #|                  node: {
      #|                    v: "Multi",
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
      #|                {
      #|                  blanks: "",
      #|                  node: {
      #|                    v: "line titles",
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

///|
test "HTML block" {
  let doc =
    #|<div>
    #|  hello
    #|</div>
    #|
    #| world
  debug_inspect(
    Doc(doc),
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Blocks(
      #|    {
      #|      v: Seq(
      #|        [
      #|          HtmlBlock(
      #|            {
      #|              v: HtmlBlock(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      v: "<div>",
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
      #|                    {
      #|                      v: "  hello",
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
      #|                    {
      #|                      v: "</div>",
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
      #|                  ],
      #|                ),
      #|              ),
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
      #|                leading_indent: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "world",
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

///|
test "should tokenize inline image across multiple lines" {
  let doc =
    #|This is an ![inline image](
    #|  /heyho    (The
    #|    multiline title))
  debug_inspect(
    tokenize_only(doc),
    content=(
      #|(
      #|  CloserIndex({ RightBrack: <Set: [25]>, RightParen: <Set: [64, 65]> }),
      #|  Tokens(
      #|    <Deque:
      #|      [
      #|        LinkStart({ start: 11, image: true }),
      #|        RightBrack({ start: 25 }),
      #|        Newline(
      #|          {
      #|            start: 27,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(2, 0), first: 28, last: 43 },
      #|          },
      #|        ),
      #|        Newline(
      #|          {
      #|            start: 44,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(3, 0), first: 45, last: 65 },
      #|          },
      #|        ),
      #|      ]>,
      #|  ),
      #|  { pos: LinePos(1, 0), first: 0, last: 26 },
      #|)
    ),
  )
}

///|
/// https://github.com/moonbit-community/cmark/issues/41
test "should parse normal raw HTML block" {
  let doc =
    #|# My Document
    #|
    #|This is a standard paragraph in Markdown.
    #|
    #|<div class="custom-container">
    #|  <h2>Section Title</h2>
    #|  <p>This is a paragraph inside a custom HTML container.</p>
    #|</div>
  debug_inspect(
    Doc(doc),
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
      #|                    v: "My Document",
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
      #|                    v: "This is a standard paragraph in Markdown.",
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
      #|          HtmlBlock(
      #|            {
      #|              v: HtmlBlock(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      v: "<div class=\"custom-container\">",
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
      #|                    {
      #|                      v: "  <h2>Section Title</h2>",
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
      #|                    {
      #|                      v: "  <p>This is a paragraph inside a custom HTML container.</p>",
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
      #|                    {
      #|                      v: "</div>",
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
      #|                  ],
      #|                ),
      #|              ),
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

///|
/// https://github.com/moonbit-community/cmark/issues/41
test "should parse normal code block" {
  let doc =
    #| Checks if all elements in the array view match the condition.
    #| # Example
    #| ```
    #| let v = [1, 4, 6, 8, 9]
    #| assert_false!(v[:].all(fn(elem) { elem % 2 == 0 }))
    #| assert_true!(v[1:4].all(fn(elem) { elem % 2 == 0 }))
    #| ```
  debug_inspect(
    Doc(doc),
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
      #|                leading_indent: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "Checks if all elements in the array view match the condition.",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 1, after_opening: "", closing: "" }),
      #|                level: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "Example",
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
      #|          CodeBlock(
      #|            {
      #|              v: {
      #|                layout: Fenced(
      #|                  {
      #|                    indent: 1,
      #|                    opening_fence: {
      #|                      v: "",
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
      #|                    closing_fence: Some(
      #|                      {
      #|                        v: "",
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
      #|                    ),
      #|                  },
      #|                ),
      #|                info_string: None,
      #|                code: Seq(
      #|                  [
      #|                    {
      #|                      v: "let v = [1, 4, 6, 8, 9]",
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
      #|                    {
      #|                      v: "assert_false!(v[:].all(fn(elem) { elem % 2 == 0 }))",
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
      #|                    {
      #|                      v: "assert_true!(v[1:4].all(fn(elem) { elem % 2 == 0 }))",
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
      #|                  ],
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
      #|  defs: {},
      #|}
    ),
  )
}

///|
test "should parse link refs" {
  let doc =
    #|This is an [Extism PDK] that can be used to write [Extism Plug-ins].
    #|
    #|[Extism PDK]: https://extism.org/docs/concepts/pdk
    #|[Extism Plug-ins]: https://extism.org/docs/concepts/plug-in
  debug_inspect(
    Doc(doc),
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
      #|                            v: "This is an ",
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
      #|                        Text(
      #|                          {
      #|                            v: " that can be used to write ",
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
      #|                        Text(
      #|                          {
      #|                            v: ".",
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
      #|          LinkRefDefinition(
      #|            {
      #|              v: {
      #|                layout: {
      #|                  indent: 0,
      #|                  angled_dest: false,
      #|                  before_dest: Seq(
      #|                    [
      #|                      {
      #|                        v: " ",
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
      #|                  after_dest: Seq([]),
      #|                  title_open_delim: '"',
      #|                  after_title: Seq([]),
      #|                },
      #|                label: Some(
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
      #|                    key: "extism pdk",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "Extism PDK",
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
      #|                    key: "extism pdk",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "Extism PDK",
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
      #|                dest: Some(
      #|                  {
      #|                    v: "https://extism.org/docs/concepts/pdk",
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
      #|                title: None,
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
      #|          LinkRefDefinition(
      #|            {
      #|              v: {
      #|                layout: {
      #|                  indent: 0,
      #|                  angled_dest: false,
      #|                  before_dest: Seq(
      #|                    [
      #|                      {
      #|                        v: " ",
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
      #|                  after_dest: Seq([]),
      #|                  title_open_delim: '"',
      #|                  after_title: Seq([]),
      #|                },
      #|                label: Some(
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
      #|                    key: "extism plug-ins",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "Extism Plug-ins",
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
      #|                    key: "extism plug-ins",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "Extism Plug-ins",
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
      #|                dest: Some(
      #|                  {
      #|                    v: "https://extism.org/docs/concepts/plug-in",
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
      #|                title: None,
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
      #|    "extism pdk": LinkDef(
      #|      {
      #|        v: {
      #|          layout: {
      #|            indent: 0,
      #|            angled_dest: false,
      #|            before_dest: Seq(
      #|              [
      #|                {
      #|                  v: " ",
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
      #|              ],
      #|            ),
      #|            after_dest: Seq([]),
      #|            title_open_delim: '"',
      #|            after_title: Seq([]),
      #|          },
      #|          label: Some(
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
      #|              key: "extism pdk",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "Extism PDK",
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
      #|              key: "extism pdk",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "Extism PDK",
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
      #|          dest: Some(
      #|            {
      #|              v: "https://extism.org/docs/concepts/pdk",
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
      #|          title: None,
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
      #|    "extism plug-ins": LinkDef(
      #|      {
      #|        v: {
      #|          layout: {
      #|            indent: 0,
      #|            angled_dest: false,
      #|            before_dest: Seq(
      #|              [
      #|                {
      #|                  v: " ",
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
      #|              ],
      #|            ),
      #|            after_dest: Seq([]),
      #|            title_open_delim: '"',
      #|            after_title: Seq([]),
      #|          },
      #|          label: Some(
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
      #|              key: "extism plug-ins",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "Extism Plug-ins",
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
      #|              key: "extism plug-ins",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "Extism Plug-ins",
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
      #|          dest: Some(
      #|            {
      #|              v: "https://extism.org/docs/concepts/plug-in",
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
      #|          title: None,
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

///|
test "should parse indented code block" {
  let doc =
    #|The indented code block: 
    #|
    #|    a b c d 
    #|     a b c d
    #|     a b c d
    #|      
    #|
    #|    a
    #|       a b c
  debug_inspect(
    Doc(doc),
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
      #|                inline: Text(
      #|                  {
      #|                    v: "The indented code block:",
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
      #|          CodeBlock(
      #|            {
      #|              v: {
      #|                layout: Indented,
      #|                info_string: None,
      #|                code: Seq(
      #|                  [
      #|                    {
      #|                      v: "a b c d ",
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
      #|                    {
      #|                      v: " a b c d",
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
      #|                    {
      #|                      v: " a b c d",
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
      #|                    {
      #|                      v: "  ",
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
      #|                    {
      #|                      v: "",
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
      #|                    {
      #|                      v: "a",
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
      #|                    {
      #|                      v: "   a b c",
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
      #|                  ],
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
      #|  defs: {},
      #|}
    ),
  )
}

///|
test "should parse quoted bullets" {
  let doc =
    #|> Quoted bullets
    #|> * Is this important ? 
    #|* Well it's in the spec
    #|*
    #|Empty list item above
  debug_inspect(
    Doc(doc),
    content=(
      #|{
      #|  nl: "\n",
      #|  block: Blocks(
      #|    {
      #|      v: Seq(
      #|        [
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
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
      #|                            v: { ty: Unordered('*'), tight: true, items: Seq(...) },
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
      #|          List(
      #|            {
      #|              v: {
      #|                ty: Unordered('*'),
      #|                tight: true,
      #|                items: Seq(
      #|                  [
      #|                    {
      #|                      v: {
      #|                        before_marker: 0,
      #|                        marker: {
      #|                          v: "*",
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
      #|                        after_marker: 1,
      #|                        block: Paragraph(
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
      #|                        ext_task_marker: None,
      #|                      },
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
      #|                    {
      #|                      v: {
      #|                        before_marker: 0,
      #|                        marker: {
      #|                          v: "*",
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
      #|                        after_marker: 1,
      #|                        block: BlankLine(
      #|                          {
      #|                            v: "",
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
      #|                        ext_task_marker: None,
      #|                      },
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
      #|                  ],
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
      #|          Paragraph(
      #|            {
      #|              v: {
      #|                leading_indent: 0,
      #|                inline: Text(
      #|                  {
      #|                    v: "Empty list item above",
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

///|
test "should parse list item with multiple inlines" {
  let doc =
    #|4.  What is the exact rule for determining when list items get
    #|    wrapped in `<p>` tags?  Can a list be partially "loose" and partially
    #|    "tight"?  What should we do with a list like this?
    #|
    #|    ``` markdown
    #|    1. one
    #|
    #|    2. two
    #|    3. three
    #|    ```
    #|
    #|    Or this?
    #|
    #|    ``` markdown
    #|    1.  one
    #|        - a
    #|
    #|        - b
    #|    2.  two
    #|    ```
    #|
    #|    (There are some relevant comments by John Gruber
    #|    [here](https://web.archive.org/web/20170611172104/http://article.gmane.org/gmane.text.markdown.general/2554).)
  debug_inspect(
    Doc(doc),
    content=(
      #|{
      #|  nl: "\n",
      #|  block: List(
      #|    {
      #|      v: {
      #|        ty: Ordered(4, '.'),
      #|        tight: false,
      #|        items: Seq(
      #|          [
      #|            {
      #|              v: {
      #|                before_marker: 0,
      #|                marker: {
      #|                  v: "4.",
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
      #|                after_marker: 2,
      #|                block: Blocks(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Paragraph(
      #|                          {
      #|                            v: { leading_indent: 0, inline: Inlines(...), trailing_blanks: "" },
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
      #|                        BlankLine(
      #|                          {
      #|                            v: "",
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
      #|                        CodeBlock(
      #|                          {
      #|                            v: { layout: Fenced(...), info_string: Some(...), code: Seq(...) },
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
      #|                        BlankLine(
      #|                          {
      #|                            v: "",
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
      #|                        BlankLine(
      #|                          {
      #|                            v: "",
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
      #|                        CodeBlock(
      #|                          {
      #|                            v: { layout: Fenced(...), info_string: Some(...), code: Seq(...) },
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
      #|                        BlankLine(
      #|                          {
      #|                            v: "",
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
      #|                        Paragraph(
      #|                          {
      #|                            v: { leading_indent: 0, inline: Inlines(...), trailing_blanks: "" },
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

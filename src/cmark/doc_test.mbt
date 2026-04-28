///|
test "basic" {
  let rendered = @cmark.Doc::from_string(test_base_md_str)
  debug_inspect(
    rendered,
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing autolinks",
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
      #|                        Autolink(
      #|                          {
      #|                            v: { is_email: false, link: { v: "http://example.org", meta: ... } },
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
      #|                            v: " and another one ",
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
      #|                        Autolink(
      #|                          {
      #|                            v: { is_email: true, link: { v: "you@example.org", meta: ... } },
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing breaks",
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
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "A line ending (not in a code span or HTML tag) that is preceded by two",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "or more spaces and does not occur at the end of a block is parsed as a",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "hard line break.",
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
      #|                            v: "So this means we had softbreaks so far and now we get  ",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Hard,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "a hard break",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Hard,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "and another one.",
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: Paragraph(
      #|                  {
      #|                    v: {
      #|                      leading_indent: 0,
      #|                      inline: Inlines(
      #|                        {
      #|                          v: Seq(
      #|                            [
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                            ],
      #|                          ),
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing code spans",
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
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "This is a multi-line code",
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
      #|                        CodeSpan(
      #|                          {
      #|                            v: { backticks: 1, code_layout: Seq(...) },
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
      #|                            v: "Sometimes code spans ",
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
      #|                        CodeSpan(
      #|                          {
      #|                            v: { backticks: 2, code_layout: Seq(...) },
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
      #|                            v: ". Do you fancy ",
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
      #|                        CodeSpan(
      #|                          {
      #|                            v: { backticks: 2, code_layout: Seq(...) },
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
      #|                            v: " ?",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing emphasis",
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
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "There is ",
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
      #|                        Emphasis(
      #|                          {
      #|                            v: { delim: '_', inline: Text(...) },
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
      #|                            v: " than ",
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
      #|                        Emphasis(
      #|                          {
      #|                            v: { delim: '*', inline: Text(...) },
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
      #|                            v: " for ",
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
      #|                        StrongEmphasis(
      #|                          {
      #|                            v: { delim: '_', inline: Text(...) },
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
      #|                            v: " and ",
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
      #|                        StrongEmphasis(
      #|                          {
      #|                            v: { delim: '*', inline: Inlines(...) },
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
      #|                            v: ".  We should be careful about ",
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
      #|                        StrongEmphasis(
      #|                          {
      #|                            v: { delim: '*', inline: Text(...) },
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
      #|                            v: ". This",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "will be ",
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
      #|                        StrongEmphasis(
      #|                          {
      #|                            v: { delim: '*', inline: Text(...) },
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
      #|                            v: ". This ",
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
      #|                        Emphasis(
      #|                          {
      #|                            v: { delim: '*', inline: Text(...) },
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
      #|                            v: " you want ?",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing links, images and link reference definitions",
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
      #|                        Image(
      #|                          {
      #|                            v: { text: Text(...), reference: Inline(...) },
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
      #|                            v: "That is totally ",
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
      #|                        Text(
      #|                          {
      #|                            v: " and",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "that is ",
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
      #|                            v: { text: CodeSpan(...), reference: Ref(Shortcut, ..., ...) },
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
      #|                            v: "Shortcuts can be better than ",
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
      #|                            v: { text: Text(...), reference: Ref(Full, ..., ...) },
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
      #|                            v: " but not",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "always and we'd like to trip their ",
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
      #|                            v: { text: Text(...), reference: Ref(Full, ..., ...) },
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
      #|                          key: "colla psed",
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
      #|                          key: "colla psed",
      #|                          text: Seq([{ blanks: "", node: ... }]),
      #|                        },
      #|                      ),
      #|                      dest: Some(
      #|                        {
      #|                          v: "/hohoho",
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
      #|                            { blanks: "", node: { v: "And again these ", meta: ... } },
      #|                            { blanks: "", node: { v: "multi", meta: ... } },
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
      #|                  indent: 1,
      #|                  angled_dest: false,
      #|                  before_dest: Seq(
      #|                    [
      #|                      {
      #|                        v: "    ",
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
      #|                  after_dest: Seq(
      #|                    [
      #|                      {
      #|                        v: "   ",
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
      #|                  title_open_delim: '"',
      #|                  after_title: Seq(
      #|                    [
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
      #|                    ],
      #|                  ),
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
      #|                    key: "`short cuted`",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "`short cuted`",
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
      #|                    key: "`short cuted`",
      #|                    text: Seq(
      #|                      [
      #|                        {
      #|                          blanks: "",
      #|                          node: {
      #|                            v: "`short cuted`",
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
      #|                    v: "/veryshort",
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
      #|                title: Some(
      #|                  Seq(
      #|                    [
      #|                      {
      #|                        blanks: "",
      #|                        node: {
      #|                          v: "But very",
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
      #|                      {
      #|                        blanks: "",
      #|                        node: {
      #|                          v: "important",
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
      #|          BlankLine(
      #|            {
      #|              v: "  ",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing raw HTML",
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
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "Haha ",
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
      #|                        RawHtml(
      #|                          {
      #|                            v: InlineRawHtml(Seq(...)),
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
      #|                            v: "a",
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
      #|                        RawHtml(
      #|                          {
      #|                            v: InlineRawHtml(Seq(...)),
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
      #|                        RawHtml(
      #|                          {
      #|                            v: InlineRawHtml(Seq(...)),
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
      #|                            v: " hihi this is not the end yet.",
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
      #|                            v: "foo ",
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
      #|                        RawHtml(
      #|                          {
      #|                            v: InlineRawHtml(Seq(...)),
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
      #|                            v: "u",
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
      #|                        RawHtml(
      #|                          {
      #|                            v: InlineRawHtml(Seq(...)),
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: Paragraph(
      #|                  {
      #|                    v: {
      #|                      leading_indent: 1,
      #|                      inline: Inlines(
      #|                        {
      #|                          v: Seq(
      #|                            [
      #|                              Text(...),
      #|                              RawHtml(...),
      #|                              Text(...),
      #|                              RawHtml(...),
      #|                              RawHtml(...),
      #|                              Text(...),
      #|                            ],
      #|                          ),
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing blank lines",
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
      #|          BlankLine(
      #|            {
      #|              v: "    ",
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
      #|              v: "     ",
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
      #|                    v: "Impressive isn't it ?",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing block quotes",
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 2,
      #|                block: BlockQuote(
      #|                  {
      #|                    v: {
      #|                      indent: 2,
      #|                      block: Paragraph(
      #|                        {
      #|                          v: {
      #|                            leading_indent: 0,
      #|                            inline: Inlines({ v: ..., meta: ... }),
      #|                            trailing_blanks: "",
      #|                          },
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: Heading(
      #|                  {
      #|                    v: {
      #|                      layout: Atx({ indent: 1, after_opening: "", closing: "" }),
      #|                      level: 2,
      #|                      inline: Text(
      #|                        {
      #|                          v: "Further tests",
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
      #|                      id: None,
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
      #|                leading_indent: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "We need a little quote here",
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
      #|                block: Paragraph(
      #|                  {
      #|                    v: {
      #|                      leading_indent: 1,
      #|                      inline: Text(
      #|                        {
      #|                          v: "It's warranted.",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing code blocks",
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
      #|          CodeBlock(
      #|            {
      #|              v: {
      #|                layout: Fenced(
      #|                  {
      #|                    indent: 0,
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
      #|                info_string: Some(
      #|                  {
      #|                    v: "layout after info is not kept",
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
      #|                code: Seq([]),
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
      #|                info_string: Some(
      #|                  {
      #|                    v: "ocaml module M",
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
      #|                code: Seq(
      #|                  [
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
      #|                      v: "type t = ",
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
      #|                      v: "| A of int",
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
      #|                      v: "| B of string",
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
      #|                      v: "let square x = x *. x",
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: CodeBlock(
      #|                  {
      #|                    v: {
      #|                      layout: Fenced(
      #|                        {
      #|                          indent: 0,
      #|                          opening_fence: {
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
      #|                          closing_fence: Some({ v: "", meta: { id: 0, loc: ..., extra: None } }),
      #|                        },
      #|                      ),
      #|                      info_string: Some(
      #|                        {
      #|                          v: "ocaml module M",
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
      #|                      code: Seq(
      #|                        [
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
      #|                          {
      #|                            v: "type t = ",
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
      #|                          {
      #|                            v: "| A of int",
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
      #|                          {
      #|                            v: "| B of string",
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
      #|                          {
      #|                            v: "let square x = x *. x",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing headings",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Setext(
      #|                  {
      #|                    leading_indent: 0,
      #|                    trailing_blanks: "",
      #|                    underline_indent: 0,
      #|                    underline_count: {
      #|                      v: 8,
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
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "aaa",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "aaaa",
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: Heading(
      #|                  {
      #|                    v: {
      #|                      layout: Setext(
      #|                        {
      #|                          leading_indent: 0,
      #|                          trailing_blanks: "",
      #|                          underline_indent: 0,
      #|                          underline_count: {
      #|                            v: 8,
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
      #|                          underline_blanks: "",
      #|                        },
      #|                      ),
      #|                      level: 2,
      #|                      inline: Inlines(
      #|                        {
      #|                          v: Seq([Text(...), CodeSpan(...), Break(...), Text(...)]),
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
      #|                      id: None,
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 2, after_opening: "", closing: "" }),
      #|                level: 1,
      #|                inline: Text(
      #|                  {
      #|                    v: "That's one way",
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
      #|              v: "  ",
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
      #|                layout: Atx({ indent: 3, after_opening: "", closing: "" }),
      #|                level: 3,
      #|                inline: Text(
      #|                  {
      #|                    v: "It's a long way to the heading",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing HTML block",
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
      #|          HtmlBlock(
      #|            {
      #|              v: HtmlBlock(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      v: "<aside>",
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
      #|                      v: "<p>There is no aside</p>",
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
      #|                      v: "</aside>",
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
      #|                        block: HtmlBlock(
      #|                          {
      #|                            v: HtmlBlock(Seq(...)),
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing lists",
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
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "The ",
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
      #|                        CodeSpan(
      #|                          {
      #|                            v: { backticks: 1, code_layout: Seq(...) },
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
      #|                            v: " function is the root. There are reasons for this:",
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
      #|          List(
      #|            {
      #|              v: {
      #|                ty: Ordered(1, '.'),
      #|                tight: true,
      #|                items: Seq(
      #|                  [
      #|                    {
      #|                      v: {
      #|                        before_marker: 1,
      #|                        marker: {
      #|                          v: "1.",
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
      #|                          v: "2.",
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
      #|                        before_marker: 1,
      #|                        marker: {
      #|                          v: "3.",
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
      #|                        block: List(
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing paragraphs",
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
      #|                leading_indent: 3,
      #|                inline: Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
      #|                        Text(
      #|                          {
      #|                            v: "We really want your paragraph layout preserved.",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "Really ?",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "Really.",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "Really.",
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
      #|                        Break(
      #|                          {
      #|                            v: {
      #|                              layout_before: { v: "", meta: ... },
      #|                              ty: Soft,
      #|                              layout_after: { v: "", meta: ... },
      #|                            },
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
      #|                            v: "Really.",
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: Paragraph(
      #|                  {
      #|                    v: {
      #|                      leading_indent: 2,
      #|                      inline: Inlines(
      #|                        {
      #|                          v: Seq(
      #|                            [
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                              Break(...),
      #|                              Text(...),
      #|                            ],
      #|                          ),
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
      #|          BlankLine(
      #|            {
      #|              v: " ",
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
      #|          Heading(
      #|            {
      #|              v: {
      #|                layout: Atx({ indent: 0, after_opening: "", closing: "" }),
      #|                level: 2,
      #|                inline: Text(
      #|                  {
      #|                    v: "Testing thematic breaks",
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
      #|          ThematicBreak(
      #|            {
      #|              v: { indent: 1, layout: "***" },
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
      #|          ThematicBreak(
      #|            {
      #|              v: { indent: 2, layout: "---" },
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
      #|          ThematicBreak(
      #|            {
      #|              v: { indent: 3, layout: "___" },
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
      #|          ThematicBreak(
      #|            {
      #|              v: { indent: 0, layout: "_ _ _ _ _ " },
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
      #|          BlockQuote(
      #|            {
      #|              v: {
      #|                indent: 0,
      #|                block: ThematicBreak(
      #|                  {
      #|                    v: { indent: 1, layout: "*******" },
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
      #|    "colla psed": LinkDef(
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
      #|              key: "colla psed",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "colla psed",
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
      #|              key: "colla psed",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "colla psed",
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
      #|              v: "/hohoho",
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
      #|                    v: "And again these ",
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
      #|                    v: "multi",
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
      #|    "`short cuted`": LinkDef(
      #|      {
      #|        v: {
      #|          layout: {
      #|            indent: 1,
      #|            angled_dest: false,
      #|            before_dest: Seq(
      #|              [
      #|                {
      #|                  v: "    ",
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
      #|                  v: "   ",
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
      #|              key: "`short cuted`",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "`short cuted`",
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
      #|              key: "`short cuted`",
      #|              text: Seq(
      #|                [
      #|                  {
      #|                    blanks: "",
      #|                    node: {
      #|                      v: "`short cuted`",
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
      #|              v: "/veryshort",
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
      #|                    v: "But very",
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
      #|                    v: "important",
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

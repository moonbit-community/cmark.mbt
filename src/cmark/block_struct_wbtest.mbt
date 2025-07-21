///|
test "plain" {
  let doc =
    #|Basic tests
    #|===========
    #|Basic tests for all CommonMark constructs.
  @json.inspect(Doc::from_string(doc), content={
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
                  "$tag": "Setext",
                  "0": {
                    "leading_indent": 0,
                    "trailing_blanks": "",
                    "underline_indent": 0,
                    "underline_count": [11],
                    "underline_blanks": "",
                  },
                },
                "level": 1,
                "inline": { "$tag": "Text", "0": ["Basic tests"] },
              },
            ],
          },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": {
                  "$tag": "Text",
                  "0": ["Basic tests for all CommonMark constructs."],
                },
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

///|
test "complex ref definitions" {
  let doc =
    #|  to [c    d][]
    #|> [c d]: /ha "Multi
    #|>   line titles"
  @json.inspect(Doc::from_string(doc), content={
    "nl": "\n",
    "block": {
      "$tag": "Blocks",
      "0": [
        [
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 2,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["to "] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["c    d"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Collapsed" },
                              "1": {
                                "meta": {},
                                "key": "c d",
                                "text": [{ "blanks": "", "node": ["c    d"] }],
                              },
                              "2": {
                                "meta": {},
                                "key": "c d",
                                "text": [{ "blanks": "", "node": ["c d"] }],
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
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
                  "$tag": "LinkRefDefinition",
                  "0": [
                    {
                      "layout": {
                        "indent": 0,
                        "angled_dest": false,
                        "before_dest": [[" "]],
                        "after_dest": [[" "]],
                        "title_open_delim": "\"",
                        "after_title": [[""]],
                      },
                      "label": {
                        "meta": {},
                        "key": "c d",
                        "text": [{ "blanks": "", "node": ["c d"] }],
                      },
                      "defined_label": {
                        "meta": {},
                        "key": "c d",
                        "text": [{ "blanks": "", "node": ["c d"] }],
                      },
                      "dest": ["/ha"],
                      "title": [
                        { "blanks": "", "node": ["Multi"] },
                        { "blanks": "", "node": ["line titles"] },
                      ],
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
      "c d": {
        "$tag": "LinkDef",
        "0": [
          {
            "layout": {
              "indent": 0,
              "angled_dest": false,
              "before_dest": [[" "]],
              "after_dest": [[" "]],
              "title_open_delim": "\"",
              "after_title": [[""]],
            },
            "label": {
              "meta": {},
              "key": "c d",
              "text": [{ "blanks": "", "node": ["c d"] }],
            },
            "defined_label": {
              "meta": {},
              "key": "c d",
              "text": [{ "blanks": "", "node": ["c d"] }],
            },
            "dest": ["/ha"],
            "title": [
              { "blanks": "", "node": ["Multi"] },
              { "blanks": "", "node": ["line titles"] },
            ],
          },
        ],
      },
    },
  })
}

///|
test "HTML block" {
  let doc =
    #|<div>
    #|  hello
    #|</div>
    #|
    #| world
  @json.inspect(Doc::from_string(doc), content={
    "nl": "\n",
    "block": {
      "$tag": "Blocks",
      "0": [
        [
          { "$tag": "HtmlBlock", "0": [[["<div>"], ["  hello"], ["</div>"]]] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 1,
                "inline": { "$tag": "Text", "0": ["world"] },
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

///|
test "should tokenize inline image across multiple lines" {
  let doc =
    #|This is an ![inline image](
    #|  /heyho    (The
    #|    multiline title))
  @json.inspect(tokenize_only(doc), content=[
    { "RightBrack": [25], "RightParen": [64, 65] },
    [
      { "$tag": "LinkStart", "0": { "start": 11, "image": true } },
      { "$tag": "RightBrack", "0": { "start": 25 } },
      {
        "$tag": "Newline",
        "0": {
          "start": 27,
          "break_ty": { "$tag": "Soft" },
          "newline": { "pos": [2, 0], "first": 28, "last": 43 },
        },
      },
      {
        "$tag": "Newline",
        "0": {
          "start": 44,
          "break_ty": { "$tag": "Soft" },
          "newline": { "pos": [3, 0], "first": 45, "last": 65 },
        },
      },
    ],
    { "pos": [1, 0], "first": 0, "last": 26 },
  ])
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
  @json.inspect(Doc::from_string(doc), content={
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
                "inline": { "$tag": "Text", "0": ["My Document"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": {
                  "$tag": "Text",
                  "0": ["This is a standard paragraph in Markdown."],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "HtmlBlock",
            "0": [
              [
                ["<div class=\"custom-container\">"],
                ["  <h2>Section Title</h2>"],
                ["  <p>This is a paragraph inside a custom HTML container.</p>"],
                ["</div>"],
              ],
            ],
          },
        ],
      ],
    },
    "defs": {},
  })
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
  @json.inspect(Doc::from_string(doc), content={
    "nl": "\n",
    "block": {
      "$tag": "Blocks",
      "0": [
        [
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 1,
                "inline": {
                  "$tag": "Text",
                  "0": [
                    "Checks if all elements in the array view match the condition.",
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 1, "after_opening": "", "closing": "" },
                },
                "level": 1,
                "inline": { "$tag": "Text", "0": ["Example"] },
              },
            ],
          },
          {
            "$tag": "CodeBlock",
            "0": [
              {
                "layout": {
                  "$tag": "Fenced",
                  "0": {
                    "indent": 1,
                    "opening_fence": [""],
                    "closing_fence": [""],
                  },
                },
                "code": [
                  ["let v = [1, 4, 6, 8, 9]"],
                  ["assert_false!(v[:].all(fn(elem) { elem % 2 == 0 }))"],
                  ["assert_true!(v[1:4].all(fn(elem) { elem % 2 == 0 }))"],
                ],
              },
            ],
          },
        ],
      ],
    },
    "defs": {},
  })
}

///|
test "should parse link refs" {
  let doc =
    #|This is an [Extism PDK] that can be used to write [Extism Plug-ins].
    #|
    #|[Extism PDK]: https://extism.org/docs/concepts/pdk
    #|[Extism Plug-ins]: https://extism.org/docs/concepts/plug-in
  @json.inspect(Doc::from_string(doc), content={
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
                      { "$tag": "Text", "0": ["This is an "] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["Extism PDK"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Shortcut" },
                              "1": {
                                "meta": {},
                                "key": "extism pdk",
                                "text": [
                                  { "blanks": "", "node": ["Extism PDK"] },
                                ],
                              },
                              "2": {
                                "meta": {},
                                "key": "extism pdk",
                                "text": [
                                  { "blanks": "", "node": ["Extism PDK"] },
                                ],
                              },
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" that can be used to write "] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["Extism Plug-ins"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Shortcut" },
                              "1": {
                                "meta": {},
                                "key": "extism plug-ins",
                                "text": [
                                  { "blanks": "", "node": ["Extism Plug-ins"] },
                                ],
                              },
                              "2": {
                                "meta": {},
                                "key": "extism plug-ins",
                                "text": [
                                  { "blanks": "", "node": ["Extism Plug-ins"] },
                                ],
                              },
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": ["."] },
                    ],
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "LinkRefDefinition",
            "0": [
              {
                "layout": {
                  "indent": 0,
                  "angled_dest": false,
                  "before_dest": [[" "]],
                  "after_dest": [],
                  "title_open_delim": "\"",
                  "after_title": [],
                },
                "label": {
                  "meta": {},
                  "key": "extism pdk",
                  "text": [{ "blanks": "", "node": ["Extism PDK"] }],
                },
                "defined_label": {
                  "meta": {},
                  "key": "extism pdk",
                  "text": [{ "blanks": "", "node": ["Extism PDK"] }],
                },
                "dest": ["https://extism.org/docs/concepts/pdk"],
              },
            ],
          },
          {
            "$tag": "LinkRefDefinition",
            "0": [
              {
                "layout": {
                  "indent": 0,
                  "angled_dest": false,
                  "before_dest": [[" "]],
                  "after_dest": [],
                  "title_open_delim": "\"",
                  "after_title": [],
                },
                "label": {
                  "meta": {},
                  "key": "extism plug-ins",
                  "text": [{ "blanks": "", "node": ["Extism Plug-ins"] }],
                },
                "defined_label": {
                  "meta": {},
                  "key": "extism plug-ins",
                  "text": [{ "blanks": "", "node": ["Extism Plug-ins"] }],
                },
                "dest": ["https://extism.org/docs/concepts/plug-in"],
              },
            ],
          },
        ],
      ],
    },
    "defs": {
      "extism pdk": {
        "$tag": "LinkDef",
        "0": [
          {
            "layout": {
              "indent": 0,
              "angled_dest": false,
              "before_dest": [[" "]],
              "after_dest": [],
              "title_open_delim": "\"",
              "after_title": [],
            },
            "label": {
              "meta": {},
              "key": "extism pdk",
              "text": [{ "blanks": "", "node": ["Extism PDK"] }],
            },
            "defined_label": {
              "meta": {},
              "key": "extism pdk",
              "text": [{ "blanks": "", "node": ["Extism PDK"] }],
            },
            "dest": ["https://extism.org/docs/concepts/pdk"],
          },
        ],
      },
      "extism plug-ins": {
        "$tag": "LinkDef",
        "0": [
          {
            "layout": {
              "indent": 0,
              "angled_dest": false,
              "before_dest": [[" "]],
              "after_dest": [],
              "title_open_delim": "\"",
              "after_title": [],
            },
            "label": {
              "meta": {},
              "key": "extism plug-ins",
              "text": [{ "blanks": "", "node": ["Extism Plug-ins"] }],
            },
            "defined_label": {
              "meta": {},
              "key": "extism plug-ins",
              "text": [{ "blanks": "", "node": ["Extism Plug-ins"] }],
            },
            "dest": ["https://extism.org/docs/concepts/plug-in"],
          },
        ],
      },
    },
  })
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
  @json.inspect(Doc::from_string(doc), content={
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
                "inline": { "$tag": "Text", "0": ["The indented code block:"] },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "CodeBlock",
            "0": [
              {
                "layout": { "$tag": "Indented" },
                "code": [
                  ["a b c d "],
                  [" a b c d"],
                  [" a b c d"],
                  ["  "],
                  [""],
                  ["a"],
                  ["   a b c"],
                ],
              },
            ],
          },
        ],
      ],
    },
    "defs": {},
  })
}

///|
test "should parse quoted bullets" {
  let doc =
    #|> Quoted bullets
    #|> * Is this important ? 
    #|* Well it's in the spec
    #|*
    #|Empty list item above
  @json.inspect(Doc::from_string(doc), content={
    "nl": "\n",
    "block": {
      "$tag": "Blocks",
      "0": [
        [
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
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
                              "$tag": "Text",
                              "0": ["Quoted bullets"],
                            },
                            "trailing_blanks": "",
                          },
                        ],
                      },
                      {
                        "$tag": "List",
                        "0": [
                          {
                            "ty": { "$tag": "Unordered", "0": "*" },
                            "tight": true,
                            "items": [
                              [
                                {
                                  "before_marker": 0,
                                  "marker": ["*"],
                                  "after_marker": 1,
                                  "block": {
                                    "$tag": "Paragraph",
                                    "0": [
                                      {
                                        "leading_indent": 0,
                                        "inline": {
                                          "$tag": "Text",
                                          "0": ["Is this important ?"],
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
          },
          {
            "$tag": "List",
            "0": [
              {
                "ty": { "$tag": "Unordered", "0": "*" },
                "tight": true,
                "items": [
                  [
                    {
                      "before_marker": 0,
                      "marker": ["*"],
                      "after_marker": 1,
                      "block": {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": {
                              "$tag": "Text",
                              "0": ["Well it's in the spec"],
                            },
                            "trailing_blanks": "",
                          },
                        ],
                      },
                    },
                  ],
                  [
                    {
                      "before_marker": 0,
                      "marker": ["*"],
                      "after_marker": 1,
                      "block": { "$tag": "BlankLine", "0": [""] },
                    },
                  ],
                ],
              },
            ],
          },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": { "$tag": "Text", "0": ["Empty list item above"] },
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
  @json.inspect(Doc::from_string(doc), content={
    "nl": "\n",
    "block": {
      "$tag": "List",
      "0": [
        {
          "ty": { "$tag": "Ordered", "0": 4, "1": "." },
          "tight": false,
          "items": [
            [
              {
                "before_marker": 0,
                "marker": ["4."],
                "after_marker": 2,
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
                                  {
                                    "$tag": "Text",
                                    "0": [
                                      "What is the exact rule for determining when list items get",
                                    ],
                                  },
                                  {
                                    "$tag": "Break",
                                    "0": [
                                      {
                                        "layout_before": [""],
                                        "ty": { "$tag": "Soft" },
                                        "layout_after": [""],
                                      },
                                    ],
                                  },
                                  { "$tag": "Text", "0": ["wrapped in "] },
                                  {
                                    "$tag": "CodeSpan",
                                    "0": [
                                      {
                                        "backticks": 1,
                                        "code_layout": [
                                          { "blanks": "", "node": ["<p>"] },
                                        ],
                                      },
                                    ],
                                  },
                                  {
                                    "$tag": "Text",
                                    "0": [
                                      " tags?  Can a list be partially \"loose\" and partially",
                                    ],
                                  },
                                  {
                                    "$tag": "Break",
                                    "0": [
                                      {
                                        "layout_before": [""],
                                        "ty": { "$tag": "Soft" },
                                        "layout_after": [""],
                                      },
                                    ],
                                  },
                                  {
                                    "$tag": "Text",
                                    "0": [
                                      "\"tight\"?  What should we do with a list like this?",
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
                        "$tag": "CodeBlock",
                        "0": [
                          {
                            "layout": {
                              "$tag": "Fenced",
                              "0": {
                                "indent": 0,
                                "opening_fence": [""],
                                "closing_fence": [""],
                              },
                            },
                            "info_string": ["markdown"],
                            "code": [["1. one"], [""], ["2. two"], ["3. three"]],
                          },
                        ],
                      },
                      { "$tag": "BlankLine", "0": [""] },
                      {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": { "$tag": "Text", "0": ["Or this?"] },
                            "trailing_blanks": "",
                          },
                        ],
                      },
                      { "$tag": "BlankLine", "0": [""] },
                      {
                        "$tag": "CodeBlock",
                        "0": [
                          {
                            "layout": {
                              "$tag": "Fenced",
                              "0": {
                                "indent": 0,
                                "opening_fence": [""],
                                "closing_fence": [""],
                              },
                            },
                            "info_string": ["markdown"],
                            "code": [
                              ["1.  one"],
                              ["    - a"],
                              [""],
                              ["    - b"],
                              ["2.  two"],
                            ],
                          },
                        ],
                      },
                      { "$tag": "BlankLine", "0": [""] },
                      {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": {
                              "$tag": "Inlines",
                              "0": [
                                [
                                  {
                                    "$tag": "Text",
                                    "0": [
                                      "(There are some relevant comments by John Gruber",
                                    ],
                                  },
                                  {
                                    "$tag": "Break",
                                    "0": [
                                      {
                                        "layout_before": [""],
                                        "ty": { "$tag": "Soft" },
                                        "layout_after": [""],
                                      },
                                    ],
                                  },
                                  {
                                    "$tag": "Link",
                                    "0": [
                                      {
                                        "text": {
                                          "$tag": "Text",
                                          "0": ["here"],
                                        },
                                        "reference": {
                                          "$tag": "Inline",
                                          "0": [
                                            {
                                              "layout": {
                                                "indent": 0,
                                                "angled_dest": false,
                                                "before_dest": [],
                                                "after_dest": [],
                                                "title_open_delim": "\"",
                                                "after_title": [],
                                              },
                                              "dest": [
                                                "https://web.archive.org/web/20170611172104/http://article.gmane.org/gmane.text.markdown.general/2554",
                                              ],
                                            },
                                          ],
                                        },
                                      },
                                    ],
                                  },
                                  { "$tag": "Text", "0": [".]"] },
                                ],
                              ],
                            },
                            "trailing_blanks": "",
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

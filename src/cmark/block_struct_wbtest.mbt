///|
test "plain" {
  let doc =
    #|Basic tests
    #|===========
    #|Basic tests for all CommonMark constructs.
  @json.inspect(Doc::from_string(doc), content={
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
                  "Setext",
                  {
                    "leading_indent": 0,
                    "trailing_blanks": "",
                    "underline_indent": 0,
                    "underline_count": [11],
                    "underline_blanks": "",
                  },
                ],
                "level": 1,
                "inline": ["Text", ["Basic tests"]],
              },
            ],
          ],
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": [
                  "Text",
                  ["Basic tests for all CommonMark constructs."],
                ],
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

///|
test "complex ref definitions" {
  let doc =
    #|  to [c    d][]
    #|> [c d]: /ha "Multi
    #|>   line titles"
  @json.inspect(Doc::from_string(doc), content={
    "nl": "\n",
    "block": [
      "Blocks",
      [
        [
          [
            "Paragraph",
            [
              {
                "leading_indent": 2,
                "inline": [
                  "Inlines",
                  [
                    [
                      ["Text", ["to "]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["c    d"]],
                            "reference": [
                              "Ref",
                              "Collapsed",
                              {
                                "meta": {},
                                "key": "c d",
                                "text": [{ "blanks": "", "node": ["c    d"] }],
                              },
                              {
                                "meta": {},
                                "key": "c d",
                                "text": [{ "blanks": "", "node": ["c d"] }],
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
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "LinkRefDefinition",
                  [
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
                ],
              },
            ],
          ],
        ],
      ],
    ],
    "defs": {
      "c d": [
        "LinkDef",
        [
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
      ],
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
    "block": [
      "Blocks",
      [
        [
          ["HtmlBlock", [["HtmlBlock", [["<div>"], ["  hello"], ["</div>"]]]]],
          ["BlankLine", [""]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 1,
                "inline": ["Text", ["world"]],
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

///|
test "should tokenize inline image across multiple lines" {
  let doc =
    #|This is an ![inline image](
    #|  /heyho    (The
    #|    multiline title))
  @json.inspect(tokenize_only(doc), content=[
    ["CloserIndex", { "RightBrack": [25], "RightParen": [64, 65] }],
    [
      ["LinkStart", { "start": 11, "image": true }],
      ["RightBrack", { "start": 25 }],
      [
        "Newline",
        {
          "start": 27,
          "break_ty": "Soft",
          "newline": { "pos": ["LinePos", 2, 0], "first": 28, "last": 43 },
        },
      ],
      [
        "Newline",
        {
          "start": 44,
          "break_ty": "Soft",
          "newline": { "pos": ["LinePos", 3, 0], "first": 45, "last": 65 },
        },
      ],
    ],
    { "pos": ["LinePos", 1, 0], "first": 0, "last": 26 },
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
                "inline": ["Text", ["My Document"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": [
                  "Text",
                  ["This is a standard paragraph in Markdown."],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "HtmlBlock",
            [
              [
                "HtmlBlock",
                [
                  ["<div class=\"custom-container\">"],
                  ["  <h2>Section Title</h2>"],
                  [
                    "  <p>This is a paragraph inside a custom HTML container.</p>",
                  ],
                  ["</div>"],
                ],
              ],
            ],
          ],
        ],
      ],
    ],
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
    "block": [
      "Blocks",
      [
        [
          [
            "Paragraph",
            [
              {
                "leading_indent": 1,
                "inline": [
                  "Text",
                  [
                    "Checks if all elements in the array view match the condition.",
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 1, "after_opening": "", "closing": "" },
                ],
                "level": 1,
                "inline": ["Text", ["Example"]],
              },
            ],
          ],
          [
            "CodeBlock",
            [
              {
                "layout": [
                  "Fenced",
                  { "indent": 1, "opening_fence": [""], "closing_fence": [""] },
                ],
                "code": [
                  ["let v = [1, 4, 6, 8, 9]"],
                  ["assert_false!(v[:].all(fn(elem) { elem % 2 == 0 }))"],
                  ["assert_true!(v[1:4].all(fn(elem) { elem % 2 == 0 }))"],
                ],
              },
            ],
          ],
        ],
      ],
    ],
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
                      ["Text", ["This is an "]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["Extism PDK"]],
                            "reference": [
                              "Ref",
                              "Shortcut",
                              {
                                "meta": {},
                                "key": "extism pdk",
                                "text": [
                                  { "blanks": "", "node": ["Extism PDK"] },
                                ],
                              },
                              {
                                "meta": {},
                                "key": "extism pdk",
                                "text": [
                                  { "blanks": "", "node": ["Extism PDK"] },
                                ],
                              },
                            ],
                          },
                        ],
                      ],
                      ["Text", [" that can be used to write "]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["Extism Plug-ins"]],
                            "reference": [
                              "Ref",
                              "Shortcut",
                              {
                                "meta": {},
                                "key": "extism plug-ins",
                                "text": [
                                  { "blanks": "", "node": ["Extism Plug-ins"] },
                                ],
                              },
                              {
                                "meta": {},
                                "key": "extism plug-ins",
                                "text": [
                                  { "blanks": "", "node": ["Extism Plug-ins"] },
                                ],
                              },
                            ],
                          },
                        ],
                      ],
                      ["Text", ["."]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "LinkRefDefinition",
            [
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
          ],
          [
            "LinkRefDefinition",
            [
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
          ],
        ],
      ],
    ],
    "defs": {
      "extism pdk": [
        "LinkDef",
        [
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
      ],
      "extism plug-ins": [
        "LinkDef",
        [
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
      ],
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
    "block": [
      "Blocks",
      [
        [
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": ["Text", ["The indented code block:"]],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "CodeBlock",
            [
              {
                "layout": "Indented",
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
          ],
        ],
      ],
    ],
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
    "block": [
      "Blocks",
      [
        [
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "Blocks",
                  [
                    [
                      [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": ["Text", ["Quoted bullets"]],
                            "trailing_blanks": "",
                          },
                        ],
                      ],
                      [
                        "List",
                        [
                          {
                            "ty": ["Unordered", "*"],
                            "tight": true,
                            "items": [
                              [
                                {
                                  "before_marker": 0,
                                  "marker": ["*"],
                                  "after_marker": 1,
                                  "block": [
                                    "Paragraph",
                                    [
                                      {
                                        "leading_indent": 0,
                                        "inline": [
                                          "Text",
                                          ["Is this important ?"],
                                        ],
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
          [
            "List",
            [
              {
                "ty": ["Unordered", "*"],
                "tight": true,
                "items": [
                  [
                    {
                      "before_marker": 0,
                      "marker": ["*"],
                      "after_marker": 1,
                      "block": [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": ["Text", ["Well it's in the spec"]],
                            "trailing_blanks": "",
                          },
                        ],
                      ],
                    },
                  ],
                  [
                    {
                      "before_marker": 0,
                      "marker": ["*"],
                      "after_marker": 1,
                      "block": ["BlankLine", [""]],
                    },
                  ],
                ],
              },
            ],
          ],
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": ["Text", ["Empty list item above"]],
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
    "block": [
      "List",
      [
        {
          "ty": ["Ordered", 4, "."],
          "tight": false,
          "items": [
            [
              {
                "before_marker": 0,
                "marker": ["4."],
                "after_marker": 2,
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
                                  [
                                    "Text",
                                    [
                                      "What is the exact rule for determining when list items get",
                                    ],
                                  ],
                                  [
                                    "Break",
                                    [
                                      {
                                        "layout_before": [""],
                                        "ty": "Soft",
                                        "layout_after": [""],
                                      },
                                    ],
                                  ],
                                  ["Text", ["wrapped in "]],
                                  [
                                    "CodeSpan",
                                    [
                                      {
                                        "backticks": 1,
                                        "code_layout": [
                                          { "blanks": "", "node": ["<p>"] },
                                        ],
                                      },
                                    ],
                                  ],
                                  [
                                    "Text",
                                    [
                                      " tags?  Can a list be partially \"loose\" and partially",
                                    ],
                                  ],
                                  [
                                    "Break",
                                    [
                                      {
                                        "layout_before": [""],
                                        "ty": "Soft",
                                        "layout_after": [""],
                                      },
                                    ],
                                  ],
                                  [
                                    "Text",
                                    [
                                      "\"tight\"?  What should we do with a list like this?",
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
                        "CodeBlock",
                        [
                          {
                            "layout": [
                              "Fenced",
                              {
                                "indent": 0,
                                "opening_fence": [""],
                                "closing_fence": [""],
                              },
                            ],
                            "info_string": ["markdown"],
                            "code": [["1. one"], [""], ["2. two"], ["3. three"]],
                          },
                        ],
                      ],
                      ["BlankLine", [""]],
                      [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": ["Text", ["Or this?"]],
                            "trailing_blanks": "",
                          },
                        ],
                      ],
                      ["BlankLine", [""]],
                      [
                        "CodeBlock",
                        [
                          {
                            "layout": [
                              "Fenced",
                              {
                                "indent": 0,
                                "opening_fence": [""],
                                "closing_fence": [""],
                              },
                            ],
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
                      ],
                      ["BlankLine", [""]],
                      [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": [
                              "Inlines",
                              [
                                [
                                  [
                                    "Text",
                                    [
                                      "(There are some relevant comments by John Gruber",
                                    ],
                                  ],
                                  [
                                    "Break",
                                    [
                                      {
                                        "layout_before": [""],
                                        "ty": "Soft",
                                        "layout_after": [""],
                                      },
                                    ],
                                  ],
                                  [
                                    "Link",
                                    [
                                      {
                                        "text": ["Text", ["here"]],
                                        "reference": [
                                          "Inline",
                                          [
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
                                        ],
                                      },
                                    ],
                                  ],
                                  ["Text", [".)"]],
                                ],
                              ],
                            ],
                            "trailing_blanks": "",
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

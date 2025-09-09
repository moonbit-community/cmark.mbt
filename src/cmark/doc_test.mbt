///|
test "basic" {
  let rendered = @cmark.Doc::from_string(test_base_md_str)
  @json.inspect(rendered, content={
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
          ["BlankLine", [""]],
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
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing autolinks"]],
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
                      ["Text", ["This is an "]],
                      [
                        "Autolink",
                        [{ "is_email": false, "link": ["http://example.org"] }],
                      ],
                      ["Text", [" and another one "]],
                      [
                        "Autolink",
                        [{ "is_email": true, "link": ["you@example.org"] }],
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
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing breaks"]],
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
                          "A line ending (not in a code span or HTML tag) that is preceded by two",
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
                          "or more spaces and does not occur at the end of a block is parsed as a",
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
                      ["Text", ["hard line break."]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
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
                          "So this means we had softbreaks so far and now we get  ",
                        ],
                      ],
                      [
                        "Break",
                        [
                          {
                            "layout_before": [""],
                            "ty": "Hard",
                            "layout_after": [""],
                          },
                        ],
                      ],
                      ["Text", ["a hard break"]],
                      [
                        "Break",
                        [
                          {
                            "layout_before": [""],
                            "ty": "Hard",
                            "layout_after": [""],
                          },
                        ],
                      ],
                      ["Text", ["and another one."]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 0,
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
                              "Text",
                              [
                                "So this means we had softbreaks so far and now we get  ",
                              ],
                            ],
                            [
                              "Break",
                              [
                                {
                                  "layout_before": [""],
                                  "ty": "Hard",
                                  "layout_after": [""],
                                },
                              ],
                            ],
                            ["Text", ["a hard break"]],
                            [
                              "Break",
                              [
                                {
                                  "layout_before": [""],
                                  "ty": "Hard",
                                  "layout_after": [""],
                                },
                              ],
                            ],
                            ["Text", ["and another one."]],
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
                            ["Text", ["This is very soooft."]],
                          ],
                        ],
                      ],
                      "trailing_blanks": "",
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing code spans"]],
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
                      ["Text", ["This is a multi-line code"]],
                      [
                        "CodeSpan",
                        [
                          {
                            "backticks": 1,
                            "code_layout": [
                              { "blanks": "", "node": [""] },
                              {
                                "blanks": "",
                                "node": ["code span `` it has backticks"],
                              },
                              { "blanks": "", "node": ["in there"] },
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
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": [
                  "Inlines",
                  [
                    [
                      ["Text", ["Sometimes code spans "]],
                      [
                        "CodeSpan",
                        [
                          {
                            "backticks": 2,
                            "code_layout": [
                              { "blanks": "", "node": [" `can have"] },
                              { "blanks": "", "node": ["really ```"] },
                              { "blanks": "", "node": ["strange"] },
                              { "blanks": "", "node": ["layout "] },
                            ],
                          },
                        ],
                      ],
                      ["Text", [". Do you fancy "]],
                      [
                        "CodeSpan",
                        [
                          {
                            "backticks": 2,
                            "code_layout": [
                              {
                                "blanks": "",
                                "node": [" `A_polymorphic_variant "],
                              },
                            ],
                          },
                        ],
                      ],
                      ["Text", [" ?"]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing emphasis"]],
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
                      ["Text", ["There is "]],
                      [
                        "Emphasis",
                        [{ "delim": "_", "inline": ["Text", ["more"]] }],
                      ],
                      ["Text", [" than "]],
                      [
                        "Emphasis",
                        [{ "delim": "*", "inline": ["Text", ["one syntax"]] }],
                      ],
                      ["Text", [" for "]],
                      [
                        "StrongEmphasis",
                        [{ "delim": "_", "inline": ["Text", ["emphasis"]] }],
                      ],
                      ["Text", [" and "]],
                      [
                        "StrongEmphasis",
                        [
                          {
                            "delim": "*",
                            "inline": [
                              "Inlines",
                              [
                                [
                                  ["Text", ["strong"]],
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
                                  ["Text", ["emphasis"]],
                                ],
                              ],
                            ],
                          },
                        ],
                      ],
                      ["Text", [".  We should be careful about "]],
                      [
                        "StrongEmphasis",
                        [
                          {
                            "delim": "*",
                            "inline": ["Text", ["embedded * marker"]],
                          },
                        ],
                      ],
                      ["Text", [". This"]],
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
                      ["Text", ["will be "]],
                      [
                        "StrongEmphasis",
                        [
                          {
                            "delim": "*",
                            "inline": ["Text", ["tricky * to handle"]],
                          },
                        ],
                      ],
                      ["Text", [". This "]],
                      [
                        "Emphasis",
                        [
                          {
                            "delim": "*",
                            "inline": ["Text", ["is not ** what"]],
                          },
                        ],
                      ],
                      ["Text", [" you want ?"]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": [
                  "Text",
                  ["Testing links, images and link reference definitions"],
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
                      ["Text", ["This is an "]],
                      [
                        "Image",
                        [
                          {
                            "text": ["Text", ["inline image"]],
                            "reference": [
                              "Inline",
                              [
                                {
                                  "layout": {
                                    "indent": 0,
                                    "angled_dest": false,
                                    "before_dest": [[""], ["  "]],
                                    "after_dest": [["    "]],
                                    "title_open_delim": "(",
                                    "after_title": [],
                                  },
                                  "dest": ["/heyho"],
                                  "title": [
                                    { "blanks": "", "node": ["The"] },
                                    {
                                      "blanks": "",
                                      "node": ["multiline title"],
                                    },
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
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 2,
                "inline": [
                  "Inlines",
                  [
                    [
                      ["Text", ["That is totally "]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["colla    psed"]],
                            "reference": [
                              "Ref",
                              "Collapsed",
                              {
                                "meta": {},
                                "key": "colla psed",
                                "text": [
                                  { "blanks": "", "node": ["colla    psed"] },
                                ],
                              },
                              {
                                "meta": {},
                                "key": "colla psed",
                                "text": [
                                  { "blanks": "", "node": ["colla psed"] },
                                ],
                              },
                            ],
                          },
                        ],
                      ],
                      ["Text", [" and"]],
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
                      ["Text", ["that is "]],
                      [
                        "Link",
                        [
                          {
                            "text": [
                              "CodeSpan",
                              [
                                {
                                  "backticks": 1,
                                  "code_layout": [
                                    { "blanks": "", "node": ["short cuted"] },
                                  ],
                                },
                              ],
                            ],
                            "reference": [
                              "Ref",
                              "Shortcut",
                              {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
                                ],
                              },
                              {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
                                ],
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
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": [
                  "Inlines",
                  [
                    [
                      ["Text", ["Shortcuts can be better than "]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["full references"]],
                            "reference": [
                              "Ref",
                              "Full",
                              {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short "] },
                                  { "blanks": "", "node": ["cuted`"] },
                                ],
                              },
                              {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
                                ],
                              },
                            ],
                          },
                        ],
                      ],
                      ["Text", [" but not"]],
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
                      ["Text", ["always and we'd like to trip their "]],
                      [
                        "Link",
                        [
                          {
                            "text": ["Text", ["label"]],
                            "reference": [
                              "Ref",
                              "Full",
                              {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short    cuted`"] },
                                ],
                              },
                              {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
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
                        "key": "colla psed",
                        "text": [{ "blanks": "", "node": ["colla psed"] }],
                      },
                      "defined_label": {
                        "meta": {},
                        "key": "colla psed",
                        "text": [{ "blanks": "", "node": ["colla psed"] }],
                      },
                      "dest": ["/hohoho"],
                      "title": [
                        { "blanks": "", "node": ["And again these "] },
                        { "blanks": "", "node": ["multi"] },
                        { "blanks": "", "node": ["line titles"] },
                      ],
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "LinkRefDefinition",
            [
              {
                "layout": {
                  "indent": 1,
                  "angled_dest": false,
                  "before_dest": [["    "]],
                  "after_dest": [["   "]],
                  "title_open_delim": "\"",
                  "after_title": [[""]],
                },
                "label": {
                  "meta": {},
                  "key": "`short cuted`",
                  "text": [{ "blanks": "", "node": ["`short cuted`"] }],
                },
                "defined_label": {
                  "meta": {},
                  "key": "`short cuted`",
                  "text": [{ "blanks": "", "node": ["`short cuted`"] }],
                },
                "dest": ["/veryshort"],
                "title": [
                  { "blanks": "", "node": ["But very"] },
                  { "blanks": "", "node": ["important"] },
                ],
              },
            ],
          ],
          ["BlankLine", ["  "]],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing raw HTML"]],
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
                      ["Text", ["Haha "]],
                      [
                        "RawHtml",
                        [["InlineRawHtml", [{ "blanks": "", "node": ["<a>"] }]]],
                      ],
                      ["Text", ["a"]],
                      [
                        "RawHtml",
                        [
                          [
                            "InlineRawHtml",
                            [{ "blanks": "", "node": ["</a>"] }],
                          ],
                        ],
                      ],
                      [
                        "RawHtml",
                        [
                          [
                            "InlineRawHtml",
                            [
                              { "blanks": "", "node": ["<b2"] },
                              { "blanks": "", "node": ["data=\"foo\" >"] },
                            ],
                          ],
                        ],
                      ],
                      ["Text", [" hihi this is not the end yet."]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
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
                      ["Text", ["foo "]],
                      [
                        "RawHtml",
                        [
                          [
                            "InlineRawHtml",
                            [{ "blanks": "", "node": ["<a href=\"\\*\" />"] }],
                          ],
                        ],
                      ],
                      ["Text", ["u"]],
                      [
                        "RawHtml",
                        [
                          [
                            "InlineRawHtml",
                            [{ "blanks": "", "node": ["</a>"] }],
                          ],
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
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "Paragraph",
                  [
                    {
                      "leading_indent": 1,
                      "inline": [
                        "Inlines",
                        [
                          [
                            ["Text", ["Haha "]],
                            [
                              "RawHtml",
                              [
                                [
                                  "InlineRawHtml",
                                  [{ "blanks": "", "node": ["<a>"] }],
                                ],
                              ],
                            ],
                            ["Text", ["a"]],
                            [
                              "RawHtml",
                              [
                                [
                                  "InlineRawHtml",
                                  [{ "blanks": "", "node": ["</a>"] }],
                                ],
                              ],
                            ],
                            [
                              "RawHtml",
                              [
                                [
                                  "InlineRawHtml",
                                  [
                                    { "blanks": "", "node": ["<b2"] },
                                    { "blanks": "", "node": ["data=\"foo\" >"] },
                                  ],
                                ],
                              ],
                            ],
                            ["Text", [" hihi this is not the end yet."]],
                          ],
                        ],
                      ],
                      "trailing_blanks": "",
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing blank lines"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", ["    "]],
          ["BlankLine", ["     "]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 0,
                "inline": ["Text", ["Impressive isn't it ?"]],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing block quotes"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 2,
                "block": [
                  "BlockQuote",
                  [
                    {
                      "indent": 2,
                      "block": [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": [
                              "Inlines",
                              [
                                [
                                  ["Text", ["How is"]],
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
                                  ["Text", ["Nestyfing going on"]],
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
                                  ["Text", ["These irregularities "]],
                                  [
                                    "StrongEmphasis",
                                    [
                                      {
                                        "delim": "*",
                                        "inline": ["Text", ["will"]],
                                      },
                                    ],
                                  ],
                                  ["Text", [" normalize"]],
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
                                      "We keep only the first block quote indent",
                                    ],
                                  ],
                                ],
                              ],
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
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "Heading",
                  [
                    {
                      "layout": [
                        "Atx",
                        { "indent": 1, "after_opening": "", "closing": "" },
                      ],
                      "level": 2,
                      "inline": ["Text", ["Further tests"]],
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 2,
                "inline": ["Text", ["We need a little quote here"]],
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
                  "Paragraph",
                  [
                    {
                      "leading_indent": 1,
                      "inline": ["Text", ["It's warranted."]],
                      "trailing_blanks": "",
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing code blocks"]],
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
                  { "indent": 0, "opening_fence": [""], "closing_fence": [""] },
                ],
                "info_string": ["layout after info is not kept"],
                "code": [],
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
                  { "indent": 1, "opening_fence": [""], "closing_fence": [""] },
                ],
                "info_string": ["ocaml module M"],
                "code": [
                  [""],
                  ["type t = "],
                  ["| A of int"],
                  ["| B of string"],
                  [""],
                  ["let square x = x *. x"],
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
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
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
                      "info_string": ["ocaml module M"],
                      "code": [
                        [""],
                        ["type t = "],
                        ["| A of int"],
                        ["| B of string"],
                        [""],
                        ["let square x = x *. x"],
                      ],
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing headings"]],
              },
            ],
          ],
          ["BlankLine", [""]],
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
                    "underline_count": [8],
                    "underline_blanks": "",
                  },
                ],
                "level": 1,
                "inline": [
                  "Inlines",
                  [
                    [
                      ["Text", ["aaa"]],
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
                      ["Text", ["aaaa"]],
                    ],
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "Heading",
                  [
                    {
                      "layout": [
                        "Setext",
                        {
                          "leading_indent": 0,
                          "trailing_blanks": "",
                          "underline_indent": 0,
                          "underline_count": [8],
                          "underline_blanks": "",
                        },
                      ],
                      "level": 2,
                      "inline": [
                        "Inlines",
                        [
                          [
                            ["Text", ["bbb "]],
                            [
                              "CodeSpan",
                              [
                                {
                                  "backticks": 1,
                                  "code_layout": [
                                    { "blanks": "", "node": ["hey"] },
                                  ],
                                },
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
                            ["Text", ["bbbb"]],
                          ],
                        ],
                      ],
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 2, "after_opening": "", "closing": "" },
                ],
                "level": 1,
                "inline": ["Text", ["That's one way"]],
              },
            ],
          ],
          ["BlankLine", ["  "]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 3, "after_opening": "", "closing": "" },
                ],
                "level": 3,
                "inline": ["Text", ["It's a long way to the heading"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing HTML block"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "HtmlBlock",
            [
              [
                "HtmlBlock",
                [["<aside>"], ["<p>There is no aside</p>"], ["</aside>"]],
              ],
            ],
          ],
          ["BlankLine", [""]],
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
                        "HtmlBlock",
                        [
                          [
                            "HtmlBlock",
                            [
                              ["<aside>"],
                              ["<p>There is no aside</p>"],
                              ["</aside>"],
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
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing lists"]],
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
                      ["Text", ["The "]],
                      [
                        "CodeSpan",
                        [
                          {
                            "backticks": 1,
                            "code_layout": [
                              { "blanks": "", "node": ["square"] },
                            ],
                          },
                        ],
                      ],
                      [
                        "Text",
                        [" function is the root. There are reasons for this:"],
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
            "List",
            [
              {
                "ty": ["Ordered", 1, "."],
                "tight": true,
                "items": [
                  [
                    {
                      "before_marker": 1,
                      "marker": ["1."],
                      "after_marker": 1,
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
                                    "Text",
                                    [
                                      "There is no reason. There should be a reason or an ",
                                    ],
                                  ],
                                  [
                                    "Autolink",
                                    [
                                      {
                                        "is_email": false,
                                        "link": ["http://example.org"],
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
                    },
                  ],
                  [
                    {
                      "before_marker": 0,
                      "marker": ["2."],
                      "after_marker": 1,
                      "block": [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": [
                              "Text",
                              [
                                "Maybe that's the reason. But it may not be the reason.",
                              ],
                            ],
                            "trailing_blanks": "",
                          },
                        ],
                      ],
                    },
                  ],
                  [
                    {
                      "before_marker": 1,
                      "marker": ["3."],
                      "after_marker": 1,
                      "block": [
                        "Paragraph",
                        [
                          {
                            "leading_indent": 0,
                            "inline": ["Text", ["Is reason the only tool ?"]],
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
          ["BlankLine", [""]],
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
                                          ["Well it's in the spec"],
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
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing paragraphs"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          [
            "Paragraph",
            [
              {
                "leading_indent": 3,
                "inline": [
                  "Inlines",
                  [
                    [
                      [
                        "Text",
                        ["We really want your paragraph layout preserved."],
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
                      ["Text", ["Really ?"]],
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
                      ["Text", ["Really."]],
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
                      ["Text", ["Really."]],
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
                      ["Text", ["Really."]],
                    ],
                  ],
                ],
                "trailing_blanks": "",
              },
            ],
          ],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "Paragraph",
                  [
                    {
                      "leading_indent": 2,
                      "inline": [
                        "Inlines",
                        [
                          [
                            [
                              "Text",
                              [
                                "We really want your paragraph layout preserved.",
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
                            ["Text", ["Really ?"]],
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
                            ["Text", ["Really."]],
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
                            ["Text", ["Really."]],
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
                            ["Text", ["Really."]],
                          ],
                        ],
                      ],
                      "trailing_blanks": "",
                    },
                  ],
                ],
              },
            ],
          ],
          ["BlankLine", [" "]],
          ["BlankLine", [""]],
          ["BlankLine", [""]],
          [
            "Heading",
            [
              {
                "layout": [
                  "Atx",
                  { "indent": 0, "after_opening": "", "closing": "" },
                ],
                "level": 2,
                "inline": ["Text", ["Testing thematic breaks"]],
              },
            ],
          ],
          ["BlankLine", [""]],
          ["ThematicBreak", [{ "indent": 1, "layout": "***" }]],
          ["ThematicBreak", [{ "indent": 2, "layout": "---" }]],
          ["ThematicBreak", [{ "indent": 3, "layout": "___" }]],
          ["BlankLine", [""]],
          ["ThematicBreak", [{ "indent": 0, "layout": "_ _ _ _ _ " }]],
          ["BlankLine", [""]],
          [
            "BlockQuote",
            [
              {
                "indent": 0,
                "block": [
                  "ThematicBreak",
                  [{ "indent": 1, "layout": "*******" }],
                ],
              },
            ],
          ],
          ["BlankLine", [""]],
        ],
      ],
    ],
    "defs": {
      "colla psed": [
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
              "key": "colla psed",
              "text": [{ "blanks": "", "node": ["colla psed"] }],
            },
            "defined_label": {
              "meta": {},
              "key": "colla psed",
              "text": [{ "blanks": "", "node": ["colla psed"] }],
            },
            "dest": ["/hohoho"],
            "title": [
              { "blanks": "", "node": ["And again these "] },
              { "blanks": "", "node": ["multi"] },
              { "blanks": "", "node": ["line titles"] },
            ],
          },
        ],
      ],
      "`short cuted`": [
        "LinkDef",
        [
          {
            "layout": {
              "indent": 1,
              "angled_dest": false,
              "before_dest": [["    "]],
              "after_dest": [["   "]],
              "title_open_delim": "\"",
              "after_title": [[""]],
            },
            "label": {
              "meta": {},
              "key": "`short cuted`",
              "text": [{ "blanks": "", "node": ["`short cuted`"] }],
            },
            "defined_label": {
              "meta": {},
              "key": "`short cuted`",
              "text": [{ "blanks": "", "node": ["`short cuted`"] }],
            },
            "dest": ["/veryshort"],
            "title": [
              { "blanks": "", "node": ["But very"] },
              { "blanks": "", "node": ["important"] },
            ],
          },
        ],
      ],
    },
  })
}

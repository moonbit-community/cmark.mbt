///|
test "basic" {
  let rendered = Doc::from_string(test_base_md_str)
  @json.inspect!(rendered, content={
    "nl": "\\n",
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
          { "$tag": "BlankLine", "0": [""] },
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
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing autolinks"] },
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
                      { "$tag": "Text", "0": ["This is an "] },
                      {
                        "$tag": "Autolink",
                        "0": [
                          { "is_email": false, "link": ["http://example.org"] },
                        ],
                      },
                      { "$tag": "Text", "0": [" and another one "] },
                      {
                        "$tag": "Autolink",
                        "0": [{ "is_email": true, "link": ["you@example.org"] }],
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
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing breaks"] },
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
                          "A line ending (not in a code span or HTML tag) that is preceded by two",
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
                          "or more spaces and does not occur at the end of a block is parsed as a",
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
                      { "$tag": "Text", "0": ["hard line break."] },
                    ],
                  ],
                },
                "trailing_blanks": "",
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
                          "So this means we had softbreaks so far and now we get  ",
                        ],
                      },
                      {
                        "$tag": "Break",
                        "0": [
                          {
                            "layout_before": [""],
                            "ty": { "$tag": "Hard" },
                            "layout_after": [""],
                          },
                        ],
                      },
                      { "$tag": "Text", "0": ["a hard break"] },
                      {
                        "$tag": "Break",
                        "0": [
                          {
                            "layout_before": [""],
                            "ty": { "$tag": "Hard" },
                            "layout_after": [""],
                          },
                        ],
                      },
                      { "$tag": "Text", "0": ["and another one."] },
                    ],
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
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
                              "$tag": "Text",
                              "0": [
                                "So this means we had softbreaks so far and now we get  ",
                              ],
                            },
                            {
                              "$tag": "Break",
                              "0": [
                                {
                                  "layout_before": [""],
                                  "ty": { "$tag": "Hard" },
                                  "layout_after": [""],
                                },
                              ],
                            },
                            { "$tag": "Text", "0": ["a hard break"] },
                            {
                              "$tag": "Break",
                              "0": [
                                {
                                  "layout_before": [""],
                                  "ty": { "$tag": "Hard" },
                                  "layout_after": [""],
                                },
                              ],
                            },
                            { "$tag": "Text", "0": ["and another one."] },
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
                            { "$tag": "Text", "0": ["This is very soooft."] },
                          ],
                        ],
                      },
                      "trailing_blanks": "",
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing code spans"] },
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
                      { "$tag": "Text", "0": ["This is a multi-line code"] },
                      {
                        "$tag": "CodeSpan",
                        "0": [
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
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["Sometimes code spans "] },
                      {
                        "$tag": "CodeSpan",
                        "0": [
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
                      },
                      { "$tag": "Text", "0": [". Do you fancy "] },
                      {
                        "$tag": "CodeSpan",
                        "0": [
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
                      },
                      { "$tag": "Text", "0": [" ?"] },
                    ],
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing emphasis"] },
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
                      { "$tag": "Text", "0": ["There is "] },
                      {
                        "$tag": "Emphasis",
                        "0": [
                          {
                            "delim": "_",
                            "inline": { "$tag": "Text", "0": ["more"] },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" than "] },
                      {
                        "$tag": "Emphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": { "$tag": "Text", "0": ["one syntax"] },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" for "] },
                      {
                        "$tag": "StrongEmphasis",
                        "0": [
                          {
                            "delim": "_",
                            "inline": { "$tag": "Text", "0": ["emphasis"] },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" and "] },
                      {
                        "$tag": "StrongEmphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": {
                              "$tag": "Inlines",
                              "0": [
                                [
                                  { "$tag": "Text", "0": ["strong"] },
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
                                  { "$tag": "Text", "0": ["emphasis"] },
                                ],
                              ],
                            },
                          },
                        ],
                      },
                      {
                        "$tag": "Text",
                        "0": [".  We should be careful about "],
                      },
                      {
                        "$tag": "StrongEmphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": {
                              "$tag": "Text",
                              "0": ["embedded * marker"],
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [". This"] },
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
                      { "$tag": "Text", "0": ["will be "] },
                      {
                        "$tag": "StrongEmphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": {
                              "$tag": "Text",
                              "0": ["tricky * to handle"],
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [". This "] },
                      {
                        "$tag": "Emphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": {
                              "$tag": "Text",
                              "0": ["is not ** what"],
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" you want ?"] },
                    ],
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": {
                  "$tag": "Text",
                  "0": ["Testing links, images and link reference definitions"],
                },
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
                      { "$tag": "Text", "0": ["This is an "] },
                      {
                        "$tag": "Image",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["inline image"] },
                            "reference": {
                              "$tag": "Inline",
                              "0": [
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
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 2,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["That is totally "] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["colla    psed"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Collapsed" },
                              "1": {
                                "meta": {},
                                "key": "colla psed",
                                "text": [
                                  { "blanks": "", "node": ["colla    psed"] },
                                ],
                              },
                              "2": {
                                "meta": {},
                                "key": "colla psed",
                                "text": [
                                  { "blanks": "", "node": ["colla psed"] },
                                ],
                              },
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" and"] },
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
                      { "$tag": "Text", "0": ["that is "] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": {
                              "$tag": "CodeSpan",
                              "0": [
                                {
                                  "backticks": 1,
                                  "code_layout": [
                                    { "blanks": "", "node": ["short cuted"] },
                                  ],
                                },
                              ],
                            },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Shortcut" },
                              "1": {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
                                ],
                              },
                              "2": {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
                                ],
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
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["Shortcuts can be better than "] },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["full references"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Full" },
                              "1": {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short "] },
                                  { "blanks": "", "node": ["cuted`"] },
                                ],
                              },
                              "2": {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
                                ],
                              },
                            },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" but not"] },
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
                        "0": ["always and we'd like to trip their "],
                      },
                      {
                        "$tag": "Link",
                        "0": [
                          {
                            "text": { "$tag": "Text", "0": ["label"] },
                            "reference": {
                              "$tag": "Ref",
                              "0": { "$tag": "Full" },
                              "1": {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short    cuted`"] },
                                ],
                              },
                              "2": {
                                "meta": {},
                                "key": "`short cuted`",
                                "text": [
                                  { "blanks": "", "node": ["`short cuted`"] },
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
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "LinkRefDefinition",
            "0": [
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
          },
          { "$tag": "BlankLine", "0": ["  "] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing raw HTML"] },
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
                      { "$tag": "Text", "0": ["Haha "] },
                      {
                        "$tag": "RawHtml",
                        "0": [[{ "blanks": "", "node": ["<a>"] }]],
                      },
                      { "$tag": "Text", "0": ["a"] },
                      {
                        "$tag": "RawHtml",
                        "0": [[{ "blanks": "", "node": ["</a>"] }]],
                      },
                      {
                        "$tag": "RawHtml",
                        "0": [
                          [
                            { "blanks": "", "node": ["<b2"] },
                            { "blanks": "", "node": ["data=\"foo\" >"] },
                          ],
                        ],
                      },
                      {
                        "$tag": "Text",
                        "0": [" hihi this is not the end yet."],
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
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["foo "] },
                      {
                        "$tag": "RawHtml",
                        "0": [
                          [{ "blanks": "", "node": ["<a href=\"\\*\" />"] }],
                        ],
                      },
                      { "$tag": "Text", "0": ["u"] },
                      {
                        "$tag": "RawHtml",
                        "0": [[{ "blanks": "", "node": ["</a>"] }]],
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
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
                  "$tag": "Paragraph",
                  "0": [
                    {
                      "leading_indent": 1,
                      "inline": {
                        "$tag": "Inlines",
                        "0": [
                          [
                            { "$tag": "Text", "0": ["Haha "] },
                            {
                              "$tag": "RawHtml",
                              "0": [[{ "blanks": "", "node": ["<a>"] }]],
                            },
                            { "$tag": "Text", "0": ["a"] },
                            {
                              "$tag": "RawHtml",
                              "0": [[{ "blanks": "", "node": ["</a>"] }]],
                            },
                            {
                              "$tag": "RawHtml",
                              "0": [
                                [
                                  { "blanks": "", "node": ["<b2"] },
                                  { "blanks": "", "node": ["data=\"foo\" >"] },
                                ],
                              ],
                            },
                            {
                              "$tag": "Text",
                              "0": [" hihi this is not the end yet."],
                            },
                          ],
                        ],
                      },
                      "trailing_blanks": "",
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing blank lines"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": ["    "] },
          { "$tag": "BlankLine", "0": ["     "] },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 0,
                "inline": { "$tag": "Text", "0": ["Impressive isn't it ?"] },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing block quotes"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 2,
                "block": {
                  "$tag": "BlockQuote",
                  "0": [
                    {
                      "indent": 2,
                      "block": {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": {
                              "$tag": "Inlines",
                              "0": [
                                [
                                  { "$tag": "Text", "0": ["How is"] },
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
                                    "0": ["Nestyfing going on"],
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
                                    "0": ["These irregularities "],
                                  },
                                  {
                                    "$tag": "StrongEmphasis",
                                    "0": [
                                      {
                                        "delim": "*",
                                        "inline": {
                                          "$tag": "Text",
                                          "0": ["will"],
                                        },
                                      },
                                    ],
                                  },
                                  { "$tag": "Text", "0": [" normalize"] },
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
                                      "We keep only the first block quote indent",
                                    ],
                                  },
                                ],
                              ],
                            },
                            "trailing_blanks": "",
                          },
                        ],
                      },
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
                  "$tag": "Heading",
                  "0": [
                    {
                      "layout": {
                        "$tag": "Atx",
                        "0": { "indent": 1, "after_opening": "", "closing": "" },
                      },
                      "level": 2,
                      "inline": { "$tag": "Text", "0": ["Further tests"] },
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 2,
                "inline": {
                  "$tag": "Text",
                  "0": ["We need a little quote here"],
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
                  "$tag": "Paragraph",
                  "0": [
                    {
                      "leading_indent": 1,
                      "inline": { "$tag": "Text", "0": ["It's warranted."] },
                      "trailing_blanks": "",
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing code blocks"] },
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
                "info_string": ["layout after info is not kept"],
                "code": [],
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
                    "indent": 1,
                    "opening_fence": [""],
                    "closing_fence": [""],
                  },
                },
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
          },
          { "$tag": "BlankLine", "0": [""] },
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
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
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
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing headings"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
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
                    "underline_count": [8],
                    "underline_blanks": "",
                  },
                },
                "level": 1,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      { "$tag": "Text", "0": ["aaa"] },
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
                      { "$tag": "Text", "0": ["aaaa"] },
                    ],
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
                  "$tag": "Heading",
                  "0": [
                    {
                      "layout": {
                        "$tag": "Setext",
                        "0": {
                          "leading_indent": 0,
                          "trailing_blanks": "",
                          "underline_indent": 0,
                          "underline_count": [8],
                          "underline_blanks": "",
                        },
                      },
                      "level": 2,
                      "inline": {
                        "$tag": "Inlines",
                        "0": [
                          [
                            { "$tag": "Text", "0": ["bbb "] },
                            {
                              "$tag": "CodeSpan",
                              "0": [
                                {
                                  "backticks": 1,
                                  "code_layout": [
                                    { "blanks": "", "node": ["hey"] },
                                  ],
                                },
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
                            { "$tag": "Text", "0": ["bbbb"] },
                          ],
                        ],
                      },
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 2, "after_opening": "", "closing": "" },
                },
                "level": 1,
                "inline": { "$tag": "Text", "0": ["That's one way"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": ["  "] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 3, "after_opening": "", "closing": "" },
                },
                "level": 3,
                "inline": {
                  "$tag": "Text",
                  "0": ["It's a long way to the heading"],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing HTML block"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "HtmlBlock",
            "0": [[["<aside>"], ["<p>There is no aside</p>"], ["</aside>"]]],
          },
          { "$tag": "BlankLine", "0": [""] },
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
                        "$tag": "HtmlBlock",
                        "0": [
                          [
                            ["<aside>"],
                            ["<p>There is no aside</p>"],
                            ["</aside>"],
                          ],
                        ],
                      },
                    },
                  ],
                ],
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing lists"] },
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
                      { "$tag": "Text", "0": ["The "] },
                      {
                        "$tag": "CodeSpan",
                        "0": [
                          {
                            "backticks": 1,
                            "code_layout": [
                              { "blanks": "", "node": ["square"] },
                            ],
                          },
                        ],
                      },
                      {
                        "$tag": "Text",
                        "0": [
                          " function is the root. There are reasons for this:",
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
            "$tag": "List",
            "0": [
              {
                "ty": { "$tag": "Ordered", "0": 1, "1": "." },
                "tight": true,
                "items": [
                  [
                    {
                      "before_marker": 1,
                      "marker": ["1."],
                      "after_marker": 1,
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
                                    "$tag": "Text",
                                    "0": [
                                      "There is no reason. There should be a reason or an ",
                                    ],
                                  },
                                  {
                                    "$tag": "Autolink",
                                    "0": [
                                      {
                                        "is_email": false,
                                        "link": ["http://example.org"],
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
                    },
                  ],
                  [
                    {
                      "before_marker": 0,
                      "marker": ["2."],
                      "after_marker": 1,
                      "block": {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": {
                              "$tag": "Text",
                              "0": [
                                "Maybe that's the reason. But it may not be the reason.",
                              ],
                            },
                            "trailing_blanks": "",
                          },
                        ],
                      },
                    },
                  ],
                  [
                    {
                      "before_marker": 1,
                      "marker": ["3."],
                      "after_marker": 1,
                      "block": {
                        "$tag": "Paragraph",
                        "0": [
                          {
                            "leading_indent": 0,
                            "inline": {
                              "$tag": "Text",
                              "0": ["Is reason the only tool ?"],
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
          { "$tag": "BlankLine", "0": [""] },
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
                            ],
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
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing paragraphs"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Paragraph",
            "0": [
              {
                "leading_indent": 3,
                "inline": {
                  "$tag": "Inlines",
                  "0": [
                    [
                      {
                        "$tag": "Text",
                        "0": ["We really want your paragraph layout preserved."],
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
                      { "$tag": "Text", "0": ["Really ?"] },
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
                      { "$tag": "Text", "0": ["Really."] },
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
                      { "$tag": "Text", "0": ["Really."] },
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
                      { "$tag": "Text", "0": ["Really."] },
                    ],
                  ],
                },
                "trailing_blanks": "",
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
                  "$tag": "Paragraph",
                  "0": [
                    {
                      "leading_indent": 2,
                      "inline": {
                        "$tag": "Inlines",
                        "0": [
                          [
                            {
                              "$tag": "Text",
                              "0": [
                                "We really want your paragraph layout preserved.",
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
                            { "$tag": "Text", "0": ["Really ?"] },
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
                            { "$tag": "Text", "0": ["Really."] },
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
                            { "$tag": "Text", "0": ["Really."] },
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
                            { "$tag": "Text", "0": ["Really."] },
                          ],
                        ],
                      },
                      "trailing_blanks": "",
                    },
                  ],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [" "] },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "Heading",
            "0": [
              {
                "layout": {
                  "$tag": "Atx",
                  "0": { "indent": 0, "after_opening": "", "closing": "" },
                },
                "level": 2,
                "inline": { "$tag": "Text", "0": ["Testing thematic breaks"] },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
          { "$tag": "ThematicBreak", "0": [{ "indent": 1, "layout": "***" }] },
          { "$tag": "ThematicBreak", "0": [{ "indent": 2, "layout": "---" }] },
          { "$tag": "ThematicBreak", "0": [{ "indent": 3, "layout": "___" }] },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "ThematicBreak",
            "0": [{ "indent": 0, "layout": "_ _ _ _ _ " }],
          },
          { "$tag": "BlankLine", "0": [""] },
          {
            "$tag": "BlockQuote",
            "0": [
              {
                "indent": 0,
                "block": {
                  "$tag": "ThematicBreak",
                  "0": [{ "indent": 1, "layout": "*******" }],
                },
              },
            ],
          },
          { "$tag": "BlankLine", "0": [""] },
        ],
      ],
    },
    "defs": {
      "colla psed": {
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
      },
      "`short cuted`": {
        "$tag": "LinkDef",
        "0": [
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
      },
    },
  })
}

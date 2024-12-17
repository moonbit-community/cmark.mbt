test "plain" {
  let doc =
    #|Basic tests
    #|===========
    #|Basic tests for all CommonMark constructs.
  @json.inspect!(Doc::from_string(doc), content={
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

test "complex ref definitions" {
  let doc =
    #|  to [c    d][]
    #|> [c d]: /ha "Multi
    #|>   line titles"
  @json.inspect!(Doc::from_string(doc), content={
    "nl": "\\n",
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

test "HTML block" {
  let doc =
    #|<div>
    #|  hello
    #|</div>
    #|
    #| world
  @json.inspect!(Doc::from_string(doc), content={
    "nl": "\\n",
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

test "should tokenize inline image across multiple lines" {
  let doc =
    #|This is an ![inline image](
    #|  /heyho    (The
    #|    multiline title))
  @json.inspect!(tokenize_only(doc), content=[
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
  @json.inspect!(Doc::from_string(doc), content={
    "nl": "\\n",
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

test "should parse quoted bullets" {
  let doc =
    #|> Quoted bullets
    #|> * Is this important ? 
    #|* Well it's in the spec
    #|*
    #|Empty list item above
  @json.inspect!(Doc::from_string(doc), content={
    "nl": "\\n",
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

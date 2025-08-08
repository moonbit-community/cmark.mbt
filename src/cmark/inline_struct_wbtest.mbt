///|
fn parse_only(
  txt : String,
  strict~ : Bool = true,
  polish~ : (Parser) -> Parser = fn(p) { p },
) -> ((Col, String), Inline) {
  let p = Parser::new(txt, strict~) |> polish()
  let lines = txt.split("\n")
  let mut char_code_pos = 0
  let mut ln_num = 1
  let lines1 : Array[LineSpan] = []
  for ln in lines {
    lines1.push({
      pos: LinePos(ln_num, 0),
      first: char_code_pos,
      last: char_code_pos + ln.length() - 1,
    })
    ln_num += 1
    char_code_pos += ln.length() + 1 // considering the trailing '\n'
  }
  p.parse_inline(lines1)
}

///|
fn tokenize_only(
  txt : String,
  strict~ : Bool = true,
) -> (CloserIndex, Tokens, LineSpan) {
  let p = Parser::new(txt, strict~)
  let lines = txt.split("\n")
  let mut char_code_pos = 0
  let mut ln_num = 1
  let lines1 : Array[LineSpan] = []
  for ln in lines {
    lines1.push({
      pos: LinePos(ln_num, 0),
      first: char_code_pos,
      last: char_code_pos + ln.length() - 1,
    })
    ln_num += 1
    char_code_pos += ln.length() + 1 // considering the trailing '\n'
  }
  let (_, _, lines) = p.strip_paragraph(lines1)
  tokenize(p.i, lines, exts=p.exts)
}

///|
test "should parse entity and numeric char references" {
  @json.inspect(
    parse_only(
      (
        #|&nbsp; &amp; &copy; &AElig; &Dcaron; &frac34; &HilbertSpace; &DifferentialD; &ClockwiseContourIntegral; &ngE; &#35; &#1234; &#992; &#0; &#X22; &#XD06; &#xcab;
      ),
    ),
    content=[
      [0, ""],
      ["Text", ["  & © Æ Ď ¾ ℋ ⅆ ∲ ≧̸ # Ӓ Ϡ � \" ആ ಫ"]],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|&nbsp &x; &#; &#x; &#87654321; &#abcdef0; &ThisIsNotDefined; &hi?; &copy &MadeUpEntity;
      ),
    ),
    content=[
      [0, ""],
      [
        "Text",
        [
          "&nbsp &x; &#; &#x; &#87654321; &#abcdef0; &ThisIsNotDefined; &hi?; &copy &MadeUpEntity;",
        ],
      ],
    ],
  )
}

///|
test "should parse autolinks" {
  @json.inspect(parse_only("<http://example.org>"), content=[
    [0, ""],
    ["Autolink", [{ "is_email": false, "link": ["http://example.org"] }]],
  ])
  @json.inspect(parse_only("<you@example.org>"), content=[
    [0, ""],
    ["Autolink", [{ "is_email": true, "link": ["you@example.org"] }]],
  ])
}

///|
test "should parse breaks" {
  @json.inspect(
    parse_only(
      (
        #|A line ending (not in a code span or HTML tag) that is preceded by two
        #|   or more spaces and does not occur at the end of a block is parsed as a
        #| hard line break.
      ),
    ),
    content=[
      [0, ""],
      [
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
              [{ "layout_before": [""], "ty": "Soft", "layout_after": [""] }],
            ],
            [
              "Text",
              [
                "or more spaces and does not occur at the end of a block is parsed as a",
              ],
            ],
            [
              "Break",
              [{ "layout_before": [""], "ty": "Soft", "layout_after": [""] }],
            ],
            ["Text", ["hard line break."]],
          ],
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|So this means we had softbreaks so far and now we get  \
        #|  a hard break     
        #| and another one.
      ),
    ),
    content=[
      [0, ""],
      [
        "Inlines",
        [
          [
            [
              "Text",
              ["So this means we had softbreaks so far and now we get  "],
            ],
            [
              "Break",
              [{ "layout_before": [""], "ty": "Hard", "layout_after": [""] }],
            ],
            ["Text", ["a hard break"]],
            [
              "Break",
              [{ "layout_before": [""], "ty": "Hard", "layout_after": [""] }],
            ],
            ["Text", ["and another one."]],
          ],
        ],
      ],
    ],
  )
}

///|
test "should tokenize codespans" {
  @json.inspect(
    tokenize_only(
      (
        #|This is a multi-line code`
        #|    code span `` it has backticks
        #|  in there`
      ),
    ),
    content=[
      ["CloserIndex", { "Backticks(1)": [25, 71], "Backticks(2)": [41] }],
      [
        ["Backticks", { "start": 25, "count": 1, "escaped": false }],
        [
          "Newline",
          {
            "start": 26,
            "break_ty": "Soft",
            "newline": { "pos": ["LinePos", 2, 0], "first": 27, "last": 59 },
          },
        ],
        ["Backticks", { "start": 41, "count": 2, "escaped": false }],
        [
          "Newline",
          {
            "start": 60,
            "break_ty": "Soft",
            "newline": { "pos": ["LinePos", 3, 0], "first": 61, "last": 71 },
          },
        ],
        ["Backticks", { "start": 71, "count": 1, "escaped": false }],
      ],
      { "pos": ["LinePos", 1, 0], "first": 0, "last": 25 },
    ],
  )
}

///|
test "should parse codespans on a single line" {
  @json.inspect(parse_only("Wow, we have `code spans` now!"), content=[
    [0, ""],
    [
      "Inlines",
      [
        [
          ["Text", ["Wow, we have "]],
          [
            "CodeSpan",
            [
              {
                "backticks": 1,
                "code_layout": [{ "blanks": "", "node": ["code spans"] }],
              },
            ],
          ],
          ["Text", [" now!"]],
        ],
      ],
    ],
  ])
}

///|
test "should parse codespans across multiple lines" {
  @json.inspect(
    parse_only(
      (
        #|wow code`
        #|    stuff` !
      ),
    ),
    content=[
      [0, ""],
      [
        "Inlines",
        [
          [
            ["Text", ["wow code"]],
            [
              "CodeSpan",
              [
                {
                  "backticks": 1,
                  "code_layout": [
                    { "blanks": "", "node": [""] },
                    { "blanks": "", "node": ["stuff"] },
                  ],
                },
              ],
            ],
            ["Text", [" !"]],
          ],
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|This is a multi-line code`
        #|    code span `` it has backticks
        #|  in there`
      ),
    ),
    content=[
      [0, ""],
      [
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
                    { "blanks": "", "node": ["code span `` it has backticks"] },
                    { "blanks": "", "node": ["in there"] },
                  ],
                },
              ],
            ],
          ],
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|Sometimes code spans `` `can have
        #|   really ```
        #| strange
        #|      layout ``. Do you fancy `` `A_polymorphic_variant `` ? 
      ),
    ),
    content=[
      [0, ""],
      [
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
                    { "blanks": "", "node": [" `A_polymorphic_variant "] },
                  ],
                },
              ],
            ],
            ["Text", [" ?"]],
          ],
        ],
      ],
    ],
  )
}

///|
test "should parse emphases" {
  @json.inspect(parse_only("*it's just emph*"), content=[
    [0, ""],
    ["Emphasis", [{ "delim": "*", "inline": ["Text", ["it's just emph"]] }]],
  ])
  @json.inspect(parse_only("_and another emph_"), content=[
    [0, ""],
    ["Emphasis", [{ "delim": "_", "inline": ["Text", ["and another emph"]] }]],
  ])
  @json.inspect(parse_only("**and strong emph**"), content=[
    [0, ""],
    [
      "StrongEmphasis",
      [{ "delim": "*", "inline": ["Text", ["and strong emph"]] }],
    ],
  ])
  @json.inspect(parse_only("__and another strong emph__"), content=[
    [0, ""],
    [
      "StrongEmphasis",
      [{ "delim": "_", "inline": ["Text", ["and another strong emph"]] }],
    ],
  ])
  @json.inspect(parse_only("be careful about **embedded * markers**!"), content=[
    [0, ""],
    [
      "Inlines",
      [
        [
          ["Text", ["be careful about "]],
          [
            "StrongEmphasis",
            [{ "delim": "*", "inline": ["Text", ["embedded * markers"]] }],
          ],
          ["Text", ["!"]],
        ],
      ],
    ],
  ])
  @json.inspect(parse_only("This *is not ** what* you want?"), content=[
    [0, ""],
    [
      "Inlines",
      [
        [
          ["Text", ["This "]],
          [
            "Emphasis",
            [{ "delim": "*", "inline": ["Text", ["is not ** what"]] }],
          ],
          ["Text", [" you want?"]],
        ],
      ],
    ],
  ])
  @json.inspect(parse_only("**许可证**：GPL-v3.0"), content=[
    [0, ""],
    [
      "Inlines",
      [
        [
          [
            "StrongEmphasis",
            [{ "delim": "*", "inline": ["Text", ["许可证"]] }],
          ],
          ["Text", ["：GPL-v3.0"]],
        ],
      ],
    ],
  ])
}

///|
test "should parse links/images/refs" {
  @json.inspect(
    parse_only(
      (
        #|[a link](http://example.org)
      ),
    ),
    content=[
      [0, ""],
      [
        "Link",
        [
          {
            "text": ["Text", ["a link"]],
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
                  "dest": ["http://example.org"],
                },
              ],
            ],
          },
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|![an image](http://example.org)
      ),
    ),
    content=[
      [0, ""],
      [
        "Image",
        [
          {
            "text": ["Text", ["an image"]],
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
                  "dest": ["http://example.org"],
                },
              ],
            ],
          },
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|[a link](http://example.org "a title")
      ),
    ),
    content=[
      [0, ""],
      [
        "Link",
        [
          {
            "text": ["Text", ["a link"]],
            "reference": [
              "Inline",
              [
                {
                  "layout": {
                    "indent": 0,
                    "angled_dest": false,
                    "before_dest": [],
                    "after_dest": [[" "]],
                    "title_open_delim": "\"",
                    "after_title": [],
                  },
                  "dest": ["http://example.org"],
                  "title": [{ "blanks": "", "node": ["a title"] }],
                },
              ],
            ],
          },
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|![an image](http://example.org "a title")
      ),
    ),
    content=[
      [0, ""],
      [
        "Image",
        [
          {
            "text": ["Text", ["an image"]],
            "reference": [
              "Inline",
              [
                {
                  "layout": {
                    "indent": 0,
                    "angled_dest": false,
                    "before_dest": [],
                    "after_dest": [[" "]],
                    "title_open_delim": "\"",
                    "after_title": [],
                  },
                  "dest": ["http://example.org"],
                  "title": [{ "blanks": "", "node": ["a title"] }],
                },
              ],
            ],
          },
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|This is an ![inline image](
        #|  /heyho    (The
        #|    multiline title))
      ),
    ),
    content=[
      [0, ""],
      [
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
                          { "blanks": "", "node": ["multiline title"] },
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
    ],
  )
}

///|
test "should tokenize broken links across lines" {
  @json.inspect(
    tokenize_only(
      (
        #|and the [end
        #|condition], wow
      ),
    ),
    content=[
      ["CloserIndex", { "RightBrack": [22] }],
      [
        ["LinkStart", { "start": 8, "image": false }],
        [
          "Newline",
          {
            "start": 12,
            "break_ty": "Soft",
            "newline": { "pos": ["LinePos", 2, 0], "first": 13, "last": 27 },
          },
        ],
        ["RightBrack", { "start": 22 }],
      ],
      { "pos": ["LinePos", 1, 0], "first": 0, "last": 11 },
    ],
  )
}

///|
test "should parse broken links across lines" {
  @json.inspect(
    parse_only(
      (
        #|and the [end
        #|condition], wow
      ),
    ),
    content=[
      [0, ""],
      [
        "Inlines",
        [
          [
            ["Text", ["and the [end"]],
            [
              "Break",
              [{ "layout_before": [""], "ty": "Soft", "layout_after": [""] }],
            ],
            ["Text", ["condition], wow"]],
          ],
        ],
      ],
    ],
  )
}

///|
test "should parse raw HTML" {
  @json.inspect(
    parse_only(
      (
        #|<div><p>Some text</p></div>
      ),
    ),
    content=[
      [0, ""],
      [
        "Inlines",
        [
          [
            [
              "RawHtml",
              [["InlineRawHtml", [{ "blanks": "", "node": ["<div>"] }]]],
            ],
            [
              "RawHtml",
              [["InlineRawHtml", [{ "blanks": "", "node": ["<p>"] }]]],
            ],
            ["Text", ["Some text"]],
            [
              "RawHtml",
              [["InlineRawHtml", [{ "blanks": "", "node": ["</p>"] }]]],
            ],
            [
              "RawHtml",
              [["InlineRawHtml", [{ "blanks": "", "node": ["</div>"] }]]],
            ],
          ],
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|foo <a href="\*" />u</a>
      ),
    ),
    content=[
      [0, ""],
      [
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
              [["InlineRawHtml", [{ "blanks": "", "node": ["</a>"] }]]],
            ],
          ],
        ],
      ],
    ],
  )
  @json.inspect(
    parse_only(
      (
        #|Haha <a>a</a><b2
        #|       data="foo" > hihi this is not the end yet.
      ),
    ),
    content=[
      [0, ""],
      [
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
              [["InlineRawHtml", [{ "blanks": "", "node": ["</a>"] }]]],
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
    ],
  )
}

///|
test "should tokenize nested strikethroughs and emphases" {
  let doc =
    #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
  @json.inspect(tokenize_only(doc, strict=false), content=[
    [
      "CloserIndex",
      { "EmphasisMarks('*')": [19, 25, 69], "StrikethroughMarks": [35, 67, 72] },
    ],
    [
      [
        "StrikethroughMarks",
        { "start": 17, "may_open": true, "may_close": false },
      ],
      [
        "EmphasisMarks",
        {
          "start": 19,
          "char": "*",
          "count": 1,
          "may_open": true,
          "may_close": true,
        },
      ],
      [
        "EmphasisMarks",
        {
          "start": 25,
          "char": "*",
          "count": 1,
          "may_open": false,
          "may_close": true,
        },
      ],
      [
        "StrikethroughMarks",
        { "start": 27, "may_open": true, "may_close": false },
      ],
      [
        "StrikethroughMarks",
        { "start": 35, "may_open": false, "may_close": true },
      ],
      [
        "EmphasisMarks",
        {
          "start": 38,
          "char": "*",
          "count": 1,
          "may_open": true,
          "may_close": false,
        },
      ],
      [
        "EmphasisMarks",
        {
          "start": 45,
          "char": "*",
          "count": 2,
          "may_open": true,
          "may_close": false,
        },
      ],
      [
        "StrikethroughMarks",
        { "start": 54, "may_open": true, "may_close": false },
      ],
      [
        "StrikethroughMarks",
        { "start": 67, "may_open": true, "may_close": true },
      ],
      [
        "EmphasisMarks",
        {
          "start": 69,
          "char": "*",
          "count": 3,
          "may_open": true,
          "may_close": true,
        },
      ],
      [
        "StrikethroughMarks",
        { "start": 72, "may_open": false, "may_close": true },
      ],
    ],
    { "pos": ["LinePos", 1, 0], "first": 0, "last": 73 },
  ])
}

///|
test "should parse strikethroughs" {
  @json.inspect(
    parse_only(
      strict=false,
      (
        #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
      ),
    ),
    content=[
      [0, ""],
      [
        "Inlines",
        [
          [
            ["Text", ["Nesting the nest "]],
            [
              "ExtStrikethrough",
              [
                [
                  "InlineStrikethrough",
                  [
                    "Inlines",
                    [
                      [
                        [
                          "Emphasis",
                          [{ "delim": "*", "inline": ["Text", ["emph2"]] }],
                        ],
                        ["Text", [" "]],
                        [
                          "ExtStrikethrough",
                          [["InlineStrikethrough", ["Text", ["stroke"]]]],
                        ],
                        ["Text", [" "]],
                        [
                          "Emphasis",
                          [
                            {
                              "delim": "*",
                              "inline": [
                                "Inlines",
                                [
                                  [
                                    ["Text", ["emph3 "]],
                                    [
                                      "StrongEmphasis",
                                      [
                                        {
                                          "delim": "*",
                                          "inline": [
                                            "Inlines",
                                            [
                                              [
                                                ["Text", ["emph4  "]],
                                                [
                                                  "ExtStrikethrough",
                                                  [
                                                    [
                                                      "InlineStrikethrough",
                                                      ["Text", ["strikeagain"]],
                                                    ],
                                                  ],
                                                ],
                                              ],
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
                      ],
                    ],
                  ],
                ],
              ],
            ],
          ],
        ],
      ],
    ],
  )
}

///|
test "should tokenize inline math" {
  @json.inspect(
    tokenize_only(
      strict=false,
      (
        #| This is $\LaTeX$ !!
      ),
    ),
    content=[
      ["CloserIndex", { "MathSpanMarks(1)": [16] }],
      [
        [
          "MathSpanMarks",
          { "start": 9, "count": 1, "may_open": true, "may_close": false },
        ],
        [
          "MathSpanMarks",
          { "start": 16, "count": 1, "may_open": false, "may_close": true },
        ],
      ],
      { "pos": ["LinePos", 1, 0], "first": 1, "last": 19 },
    ],
  )
}

///|
test "should parse inline math" {
  @json.inspect(
    parse_only(
      strict=false,
      (
        #| This is $\LaTeX$ !!
      ),
    ),
    content=[
      [1, ""],
      [
        "Inlines",
        [
          [
            ["Text", ["This is "]],
            [
              "ExtMathSpan",
              [
                {
                  "display": false,
                  "tex_layout": [{ "blanks": "", "node": ["\\LaTeX"] }],
                },
              ],
            ],
            ["Text", [" !!"]],
          ],
        ],
      ],
    ],
  )
}

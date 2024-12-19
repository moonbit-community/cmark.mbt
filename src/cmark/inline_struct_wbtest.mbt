///|
fn parse_only(
  txt : String,
  strict~ : Bool = true,
  polish~ : (Parser) -> Parser = fn(p) { p }
) -> ((Col, String), Inline) {
  let p = Parser::new(txt, strict~) |> polish()
  let lines = txt.split("\n")
  let mut byte_pos = 0
  let mut ln_num = 1
  let mut lines1 : List[LineSpan] = Nil
  for ln in lines.iter() {
    lines1 = lines1.add({
      pos: (ln_num, 0),
      first: byte_pos,
      last: byte_pos + ln.length() - 1,
    })
    ln_num += 1
    byte_pos += ln.length() + 1 // considering the trailing '\n'
  }
  p.parse_inline(lines1)
}

///|
fn tokenize_only(
  txt : String,
  strict~ : Bool = true
) -> (CloserIndex, Array[Token], LineSpan) {
  let p = Parser::new(txt, strict~)
  let lines = txt.split("\n")
  let mut byte_pos = 0
  let mut ln_num = 1
  let mut lines1 : List[LineSpan] = Nil
  for ln in lines.iter() {
    lines1 = lines1.add({
      pos: (ln_num, 0),
      first: byte_pos,
      last: byte_pos + ln.length() - 1,
    })
    ln_num += 1
    byte_pos += ln.length() + 1 // considering the trailing '\n'
  }
  let (_, _, lines) = p.strip_paragraph(lines1)
  tokenize(p.i, lines, exts=p.exts)
}

test "should parse entity and numeric char references" {
  @json.inspect!(
    parse_only(
      #|&nbsp; &amp; &copy; &AElig; &Dcaron; &frac34; &HilbertSpace; &DifferentialD; &ClockwiseContourIntegral; &ngE; &#35; &#1234; &#992; &#0; &#X22; &#XD06; &#xcab;
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Text",
        "0": ["  & © Æ Ď ¾ ℋ ⅆ ∲ ≧̸ # Ӓ Ϡ � \" ആ ಫ"],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|&nbsp &x; &#; &#x; &#87654321; &#abcdef0; &ThisIsNotDefined; &hi?; &copy &MadeUpEntity;
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Text",
        "0": [
          "&nbsp &x; &#; &#x; &#87654321; &#abcdef0; &ThisIsNotDefined; &hi?; &copy &MadeUpEntity;",
        ],
      },
    ],
  )
}

test "should parse autolinks" {
  @json.inspect!(parse_only("<http://example.org>"), content=[
    [0, ""],
    {
      "$tag": "Autolink",
      "0": [{ "is_email": false, "link": ["http://example.org"] }],
    },
  ])
  @json.inspect!(parse_only("<you@example.org>"), content=[
    [0, ""],
    {
      "$tag": "Autolink",
      "0": [{ "is_email": true, "link": ["you@example.org"] }],
    },
  ])
}

test "should parse breaks" {
  @json.inspect!(
    parse_only(
      #|A line ending (not in a code span or HTML tag) that is preceded by two
      #|   or more spaces and does not occur at the end of a block is parsed as a
      #| hard line break.
      ,
    ),
    content=[
      [0, ""],
      {
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
    ],
  )
  @json.inspect!(
    parse_only(
      #|So this means we had softbreaks so far and now we get  \
      #|  a hard break     
      #| and another one.
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            {
              "$tag": "Text",
              "0": ["So this means we had softbreaks so far and now we get  "],
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
    ],
  )
}

test "should tokenize codespans" {
  @json.inspect!(
    tokenize_only(
      #|This is a multi-line code`
      #|    code span `` it has backticks
      #|  in there`
      ,
    ),
    content=[
      { "Backticks(1)": [25, 71], "Backticks(2)": [41] },
      [
        {
          "$tag": "Backticks",
          "0": { "start": 25, "count": 1, "escaped": false },
        },
        {
          "$tag": "Newline",
          "0": {
            "start": 26,
            "break_ty": { "$tag": "Soft" },
            "newline": { "pos": [2, 0], "first": 27, "last": 59 },
          },
        },
        {
          "$tag": "Backticks",
          "0": { "start": 41, "count": 2, "escaped": false },
        },
        {
          "$tag": "Newline",
          "0": {
            "start": 60,
            "break_ty": { "$tag": "Soft" },
            "newline": { "pos": [3, 0], "first": 61, "last": 71 },
          },
        },
        {
          "$tag": "Backticks",
          "0": { "start": 71, "count": 1, "escaped": false },
        },
      ],
      { "pos": [1, 0], "first": 0, "last": 25 },
    ],
  )
}

test "should parse codespans on a single line" {
  @json.inspect!(parse_only("Wow, we have `code spans` now!"), content=[
    [0, ""],
    {
      "$tag": "Inlines",
      "0": [
        [
          { "$tag": "Text", "0": ["Wow, we have "] },
          {
            "$tag": "CodeSpan",
            "0": [
              {
                "backticks": 1,
                "code_layout": [{ "blanks": "", "node": ["code spans"] }],
              },
            ],
          },
          { "$tag": "Text", "0": [" now!"] },
        ],
      ],
    },
  ])
}

test "should parse codespans across multiple lines" {
  @json.inspect!(
    parse_only(
      #|wow code`
      #|    stuff` !
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            { "$tag": "Text", "0": ["wow code"] },
            {
              "$tag": "CodeSpan",
              "0": [
                {
                  "backticks": 1,
                  "code_layout": [
                    { "blanks": "", "node": [""] },
                    { "blanks": "", "node": ["stuff"] },
                  ],
                },
              ],
            },
            { "$tag": "Text", "0": [" !"] },
          ],
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|This is a multi-line code`
      #|    code span `` it has backticks
      #|  in there`
      ,
    ),
    content=[
      [0, ""],
      {
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
                    { "blanks": "", "node": ["code span `` it has backticks"] },
                    { "blanks": "", "node": ["in there"] },
                  ],
                },
              ],
            },
          ],
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|Sometimes code spans `` `can have
      #|   really ```
      #| strange
      #|      layout ``. Do you fancy `` `A_polymorphic_variant `` ? 
      ,
    ),
    content=[
      [0, ""],
      {
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
                    { "blanks": "", "node": [" `A_polymorphic_variant "] },
                  ],
                },
              ],
            },
            { "$tag": "Text", "0": [" ?"] },
          ],
        ],
      },
    ],
  )
}

test "should parse emphases" {
  @json.inspect!(parse_only("*it's just emph*"), content=[
    [0, ""],
    {
      "$tag": "Emphasis",
      "0": [
        { "delim": "*", "inline": { "$tag": "Text", "0": ["it's just emph"] } },
      ],
    },
  ])
  @json.inspect!(parse_only("_and another emph_"), content=[
    [0, ""],
    {
      "$tag": "Emphasis",
      "0": [
        {
          "delim": "_",
          "inline": { "$tag": "Text", "0": ["and another emph"] },
        },
      ],
    },
  ])
  @json.inspect!(parse_only("**and strong emph**"), content=[
    [0, ""],
    {
      "$tag": "StrongEmphasis",
      "0": [
        { "delim": "*", "inline": { "$tag": "Text", "0": ["and strong emph"] } },
      ],
    },
  ])
  @json.inspect!(parse_only("__and another strong emph__"), content=[
    [0, ""],
    {
      "$tag": "StrongEmphasis",
      "0": [
        {
          "delim": "_",
          "inline": { "$tag": "Text", "0": ["and another strong emph"] },
        },
      ],
    },
  ])
  @json.inspect!(parse_only("be careful about **embedded * markers**!"), content=[
    [0, ""],
    {
      "$tag": "Inlines",
      "0": [
        [
          { "$tag": "Text", "0": ["be careful about "] },
          {
            "$tag": "StrongEmphasis",
            "0": [
              {
                "delim": "*",
                "inline": { "$tag": "Text", "0": ["embedded * markers"] },
              },
            ],
          },
          { "$tag": "Text", "0": ["!"] },
        ],
      ],
    },
  ])
  @json.inspect!(parse_only("This *is not ** what* you want?"), content=[
    [0, ""],
    {
      "$tag": "Inlines",
      "0": [
        [
          { "$tag": "Text", "0": ["This "] },
          {
            "$tag": "Emphasis",
            "0": [
              {
                "delim": "*",
                "inline": { "$tag": "Text", "0": ["is not ** what"] },
              },
            ],
          },
          { "$tag": "Text", "0": [" you want?"] },
        ],
      ],
    },
  ])
}

test "should parse links/images/refs" {
  @json.inspect!(
    parse_only(
      #|[a link](http://example.org)
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Link",
        "0": [
          {
            "text": { "$tag": "Text", "0": ["a link"] },
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
                  "dest": ["http://example.org"],
                },
              ],
            },
          },
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|![an image](http://example.org)
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Image",
        "0": [
          {
            "text": { "$tag": "Text", "0": ["an image"] },
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
                  "dest": ["http://example.org"],
                },
              ],
            },
          },
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|[a link](http://example.org "a title")
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Link",
        "0": [
          {
            "text": { "$tag": "Text", "0": ["a link"] },
            "reference": {
              "$tag": "Inline",
              "0": [
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
            },
          },
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|![an image](http://example.org "a title")
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Image",
        "0": [
          {
            "text": { "$tag": "Text", "0": ["an image"] },
            "reference": {
              "$tag": "Inline",
              "0": [
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
            },
          },
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|This is an ![inline image](
      #|  /heyho    (The
      #|    multiline title))
      ,
    ),
    content=[
      [0, ""],
      {
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
                          { "blanks": "", "node": ["multiline title"] },
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
    ],
  )
}

test "should parse raw HTML" {
  @json.inspect!(
    parse_only(
      #|<div><p>Some text</p></div>
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["<div>"] }]] },
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["<p>"] }]] },
            { "$tag": "Text", "0": ["Some text"] },
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["</p>"] }]] },
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["</div>"] }]] },
          ],
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|foo <a href="\*" />u</a>
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            { "$tag": "Text", "0": ["foo "] },
            {
              "$tag": "RawHtml",
              "0": [[{ "blanks": "", "node": ["<a href=\"\\*\" />"] }]],
            },
            { "$tag": "Text", "0": ["u"] },
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["</a>"] }]] },
          ],
        ],
      },
    ],
  )
  @json.inspect!(
    parse_only(
      #|Haha <a>a</a><b2
      #|       data="foo" > hihi this is not the end yet.
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            { "$tag": "Text", "0": ["Haha "] },
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["<a>"] }]] },
            { "$tag": "Text", "0": ["a"] },
            { "$tag": "RawHtml", "0": [[{ "blanks": "", "node": ["</a>"] }]] },
            {
              "$tag": "RawHtml",
              "0": [
                [
                  { "blanks": "", "node": ["<b2"] },
                  { "blanks": "", "node": ["data=\"foo\" >"] },
                ],
              ],
            },
            { "$tag": "Text", "0": [" hihi this is not the end yet."] },
          ],
        ],
      },
    ],
  )
}

test "should tokenize nested strikethroughs and emphases" {
  let doc =
    #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
  @json.inspect!(tokenize_only(doc, strict=false), content=[
    { "EmphasisMarks('*')": [25, 69], "StrikethroughMarks": [35, 67, 72] },
    [
      {
        "$tag": "StrikethroughMarks",
        "0": { "start": 17, "may_open": true, "may_close": false },
      },
      {
        "$tag": "EmphasisMarks",
        "0": {
          "start": 19,
          "char": "*",
          "count": 1,
          "may_open": true,
          "may_close": false,
        },
      },
      {
        "$tag": "EmphasisMarks",
        "0": {
          "start": 25,
          "char": "*",
          "count": 1,
          "may_open": false,
          "may_close": true,
        },
      },
      {
        "$tag": "StrikethroughMarks",
        "0": { "start": 27, "may_open": true, "may_close": false },
      },
      {
        "$tag": "StrikethroughMarks",
        "0": { "start": 35, "may_open": false, "may_close": true },
      },
      {
        "$tag": "EmphasisMarks",
        "0": {
          "start": 38,
          "char": "*",
          "count": 1,
          "may_open": true,
          "may_close": false,
        },
      },
      {
        "$tag": "EmphasisMarks",
        "0": {
          "start": 45,
          "char": "*",
          "count": 2,
          "may_open": true,
          "may_close": false,
        },
      },
      {
        "$tag": "StrikethroughMarks",
        "0": { "start": 54, "may_open": true, "may_close": false },
      },
      {
        "$tag": "StrikethroughMarks",
        "0": { "start": 67, "may_open": true, "may_close": true },
      },
      {
        "$tag": "EmphasisMarks",
        "0": {
          "start": 69,
          "char": "*",
          "count": 3,
          "may_open": true,
          "may_close": true,
        },
      },
      {
        "$tag": "StrikethroughMarks",
        "0": { "start": 72, "may_open": false, "may_close": true },
      },
    ],
    { "pos": [1, 0], "first": 0, "last": 73 },
  ])
}

test "should parse strikethroughs" {
  @json.inspect!(
    parse_only(
      strict=false,
      #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
      ,
    ),
    content=[
      [0, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            { "$tag": "Text", "0": ["Nesting the nest "] },
            {
              "$tag": "ExtStrikethrough",
              "0": [
                {
                  "$tag": "Inlines",
                  "0": [
                    [
                      {
                        "$tag": "Emphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": { "$tag": "Text", "0": ["emph2"] },
                          },
                        ],
                      },
                      { "$tag": "Text", "0": [" "] },
                      {
                        "$tag": "ExtStrikethrough",
                        "0": [{ "$tag": "Text", "0": ["stroke"] }],
                      },
                      { "$tag": "Text", "0": [" "] },
                      {
                        "$tag": "Emphasis",
                        "0": [
                          {
                            "delim": "*",
                            "inline": {
                              "$tag": "Inlines",
                              "0": [
                                [
                                  { "$tag": "Text", "0": ["emph3 "] },
                                  {
                                    "$tag": "StrongEmphasis",
                                    "0": [
                                      {
                                        "delim": "*",
                                        "inline": {
                                          "$tag": "Inlines",
                                          "0": [
                                            [
                                              {
                                                "$tag": "Text",
                                                "0": ["emph4  "],
                                              },
                                              {
                                                "$tag": "ExtStrikethrough",
                                                "0": [
                                                  {
                                                    "$tag": "Text",
                                                    "0": ["strikeagain"],
                                                  },
                                                ],
                                              },
                                            ],
                                          ],
                                        },
                                      },
                                    ],
                                  },
                                ],
                              ],
                            },
                          },
                        ],
                      },
                    ],
                  ],
                },
              ],
            },
          ],
        ],
      },
    ],
  )
}

test "should tokenize inline math" {
  @json.inspect!(
    tokenize_only(
      strict=false,
      #| This is $\LaTeX$ !!
      ,
    ),
    content=[
      { "MathSpanMarks(1)": [16] },
      [
        {
          "$tag": "MathSpanMarks",
          "0": { "start": 9, "count": 1, "may_open": true, "may_close": false },
        },
        {
          "$tag": "MathSpanMarks",
          "0": { "start": 16, "count": 1, "may_open": false, "may_close": true },
        },
      ],
      { "pos": [1, 0], "first": 1, "last": 19 },
    ],
  )
}

test "should parse inline math" {
  @json.inspect!(
    parse_only(
      strict=false,
      #| This is $\LaTeX$ !!
      ,
    ),
    content=[
      [1, ""],
      {
        "$tag": "Inlines",
        "0": [
          [
            { "$tag": "Text", "0": ["This is "] },
            {
              "$tag": "ExtMathSpan",
              "0": [
                {
                  "display": false,
                  "tex_layout": [{ "blanks": "", "node": ["\\LaTeX"] }],
                },
              ],
            },
            { "$tag": "Text", "0": [" !!"] },
          ],
        ],
      },
    ],
  )
}

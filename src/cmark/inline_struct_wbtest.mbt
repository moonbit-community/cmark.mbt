///|
fn parse_only(
  txt : String,
  strict? : Bool = true,
  polish? : (Parser) -> Parser = fn(p) { p },
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
  strict? : Bool = true,
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
  debug_inspect(
    parse_only(
      (
        #|&nbsp; &amp; &copy; &AElig; &Dcaron; &frac34; &HilbertSpace; &DifferentialD; &ClockwiseContourIntegral; &ngE; &#35; &#1234; &#992; &#0; &#X22; &#XD06; &#xcab;
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Text(
      #|    {
      #|      v: "  & © Æ Ď ¾ ℋ ⅆ ∲ ≧̸ # Ӓ Ϡ � \" ആ ಫ",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|&nbsp &x; &#; &#x; &#87654321; &#abcdef0; &ThisIsNotDefined; &hi?; &copy &MadeUpEntity;
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Text(
      #|    {
      #|      v: "&nbsp &x; &#; &#x; &#87654321; &#abcdef0; &ThisIsNotDefined; &hi?; &copy &MadeUpEntity;",
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
      #|)
    ),
  )
}

///|
test "should parse autolinks" {
  debug_inspect(
    parse_only("<http://example.org>"),
    content=(
      #|(
      #|  (0, ""),
      #|  Autolink(
      #|    {
      #|      v: {
      #|        is_email: false,
      #|        link: {
      #|          v: "http://example.org",
      #|          meta: {
      #|            id: 0,
      #|            loc: {
      #|              file: "-",
      #|              first_ccode: -1,
      #|              last_ccode: -1,
      #|              first_line: LinePos(-1, -1),
      #|              last_line: LinePos(-1, -1),
      #|            },
      #|            extra: None,
      #|          },
      #|        },
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("<you@example.org>"),
    content=(
      #|(
      #|  (0, ""),
      #|  Autolink(
      #|    {
      #|      v: {
      #|        is_email: true,
      #|        link: {
      #|          v: "you@example.org",
      #|          meta: {
      #|            id: 0,
      #|            loc: {
      #|              file: "-",
      #|              first_ccode: -1,
      #|              last_ccode: -1,
      #|              first_line: LinePos(-1, -1),
      #|              last_line: LinePos(-1, -1),
      #|            },
      #|            extra: None,
      #|          },
      #|        },
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
      #|)
    ),
  )
}

///|
test "should parse breaks" {
  debug_inspect(
    parse_only(
      (
        #|A line ending (not in a code span or HTML tag) that is preceded by two
        #|   or more spaces and does not occur at the end of a block is parsed as a
        #| hard line break.
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "A line ending (not in a code span or HTML tag) that is preceded by two",
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
      #|          Break(
      #|            {
      #|              v: {
      #|                layout_before: {
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
      #|                ty: Soft,
      #|                layout_after: {
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
      #|          Text(
      #|            {
      #|              v: "or more spaces and does not occur at the end of a block is parsed as a",
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
      #|          Break(
      #|            {
      #|              v: {
      #|                layout_before: {
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
      #|                ty: Soft,
      #|                layout_after: {
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
      #|          Text(
      #|            {
      #|              v: "hard line break.",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|So this means we had softbreaks so far and now we get  \
        #|  a hard break     
        #| and another one.
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "So this means we had softbreaks so far and now we get  ",
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
      #|          Break(
      #|            {
      #|              v: {
      #|                layout_before: {
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
      #|                ty: Hard,
      #|                layout_after: {
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
      #|          Text(
      #|            {
      #|              v: "a hard break",
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
      #|          Break(
      #|            {
      #|              v: {
      #|                layout_before: {
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
      #|                ty: Hard,
      #|                layout_after: {
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
      #|          Text(
      #|            {
      #|              v: "and another one.",
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
      #|)
    ),
  )
}

///|
test "should tokenize codespans" {
  debug_inspect(
    tokenize_only(
      (
        #|This is a multi-line code`
        #|    code span `` it has backticks
        #|  in there`
      ),
    ),
    content=(
      #|(
      #|  CloserIndex({ Backticks(1): <Set: [25, 71]>, Backticks(2): <Set: [41]> }),
      #|  Tokens(
      #|    <Deque:
      #|      [
      #|        Backticks({ start: 25, count: 1, escaped: false }),
      #|        Newline(
      #|          {
      #|            start: 26,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(2, 0), first: 27, last: 59 },
      #|          },
      #|        ),
      #|        Backticks({ start: 41, count: 2, escaped: false }),
      #|        Newline(
      #|          {
      #|            start: 60,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(3, 0), first: 61, last: 71 },
      #|          },
      #|        ),
      #|        Backticks({ start: 71, count: 1, escaped: false }),
      #|      ]>,
      #|  ),
      #|  { pos: LinePos(1, 0), first: 0, last: 25 },
      #|)
    ),
  )
}

///|
test "should parse codespans on a single line" {
  debug_inspect(
    parse_only("Wow, we have `code spans` now!"),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "Wow, we have ",
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
      #|          CodeSpan(
      #|            {
      #|              v: {
      #|                backticks: 1,
      #|                code_layout: Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "code spans",
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
      #|          Text(
      #|            {
      #|              v: " now!",
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
      #|)
    ),
  )
}

///|
test "should parse codespans across multiple lines" {
  debug_inspect(
    parse_only(
      (
        #|wow code`
        #|    stuff` !
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "wow code",
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
      #|          CodeSpan(
      #|            {
      #|              v: {
      #|                backticks: 1,
      #|                code_layout: Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "stuff",
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
      #|          Text(
      #|            {
      #|              v: " !",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|This is a multi-line code`
        #|    code span `` it has backticks
        #|  in there`
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "This is a multi-line code",
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
      #|          CodeSpan(
      #|            {
      #|              v: {
      #|                backticks: 1,
      #|                code_layout: Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "code span `` it has backticks",
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "in there",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|Sometimes code spans `` `can have
        #|   really ```
        #| strange
        #|      layout ``. Do you fancy `` `A_polymorphic_variant `` ? 
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "Sometimes code spans ",
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
      #|          CodeSpan(
      #|            {
      #|              v: {
      #|                backticks: 2,
      #|                code_layout: Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: " `can have",
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "really ```",
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "strange",
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "layout ",
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
      #|          Text(
      #|            {
      #|              v: ". Do you fancy ",
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
      #|          CodeSpan(
      #|            {
      #|              v: {
      #|                backticks: 2,
      #|                code_layout: Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: " `A_polymorphic_variant ",
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
      #|          Text(
      #|            {
      #|              v: " ?",
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
      #|)
    ),
  )
}

///|
test "should parse emphases" {
  debug_inspect(
    parse_only("*it's just emph*"),
    content=(
      #|(
      #|  (0, ""),
      #|  Emphasis(
      #|    {
      #|      v: {
      #|        delim: '*',
      #|        inline: Text(
      #|          {
      #|            v: "it's just emph",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("_and another emph_"),
    content=(
      #|(
      #|  (0, ""),
      #|  Emphasis(
      #|    {
      #|      v: {
      #|        delim: '_',
      #|        inline: Text(
      #|          {
      #|            v: "and another emph",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("**and strong emph**"),
    content=(
      #|(
      #|  (0, ""),
      #|  StrongEmphasis(
      #|    {
      #|      v: {
      #|        delim: '*',
      #|        inline: Text(
      #|          {
      #|            v: "and strong emph",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("__and another strong emph__"),
    content=(
      #|(
      #|  (0, ""),
      #|  StrongEmphasis(
      #|    {
      #|      v: {
      #|        delim: '_',
      #|        inline: Text(
      #|          {
      #|            v: "and another strong emph",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("be careful about **embedded * markers**!"),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "be careful about ",
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
      #|          StrongEmphasis(
      #|            {
      #|              v: {
      #|                delim: '*',
      #|                inline: Text(
      #|                  {
      #|                    v: "embedded * markers",
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
      #|          Text(
      #|            {
      #|              v: "!",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("This *is not ** what* you want?"),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "This ",
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
      #|          Emphasis(
      #|            {
      #|              v: {
      #|                delim: '*',
      #|                inline: Text(
      #|                  {
      #|                    v: "is not ** what",
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
      #|          Text(
      #|            {
      #|              v: " you want?",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only("**许可证**：GPL-v3.0"),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          StrongEmphasis(
      #|            {
      #|              v: {
      #|                delim: '*',
      #|                inline: Text(
      #|                  {
      #|                    v: "许可证",
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
      #|          Text(
      #|            {
      #|              v: "：GPL-v3.0",
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
      #|)
    ),
  )
}

///|
test "should parse links/images/refs" {
  debug_inspect(
    parse_only(
      (
        #|[a link](http://example.org)
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Link(
      #|    {
      #|      v: {
      #|        text: Text(
      #|          {
      #|            v: "a link",
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
      #|        reference: Inline(
      #|          {
      #|            v: {
      #|              layout: {
      #|                indent: 0,
      #|                angled_dest: false,
      #|                before_dest: Seq([]),
      #|                after_dest: Seq([]),
      #|                title_open_delim: '"',
      #|                after_title: Seq([]),
      #|              },
      #|              label: None,
      #|              defined_label: None,
      #|              dest: Some(
      #|                {
      #|                  v: "http://example.org",
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
      #|              ),
      #|              title: None,
      #|            },
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|![an image](http://example.org)
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Image(
      #|    {
      #|      v: {
      #|        text: Text(
      #|          {
      #|            v: "an image",
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
      #|        reference: Inline(
      #|          {
      #|            v: {
      #|              layout: {
      #|                indent: 0,
      #|                angled_dest: false,
      #|                before_dest: Seq([]),
      #|                after_dest: Seq([]),
      #|                title_open_delim: '"',
      #|                after_title: Seq([]),
      #|              },
      #|              label: None,
      #|              defined_label: None,
      #|              dest: Some(
      #|                {
      #|                  v: "http://example.org",
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
      #|              ),
      #|              title: None,
      #|            },
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|[a link](http://example.org "a title")
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Link(
      #|    {
      #|      v: {
      #|        text: Text(
      #|          {
      #|            v: "a link",
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
      #|        reference: Inline(
      #|          {
      #|            v: {
      #|              layout: {
      #|                indent: 0,
      #|                angled_dest: false,
      #|                before_dest: Seq([]),
      #|                after_dest: Seq(
      #|                  [
      #|                    {
      #|                      v: " ",
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
      #|                title_open_delim: '"',
      #|                after_title: Seq([]),
      #|              },
      #|              label: None,
      #|              defined_label: None,
      #|              dest: Some(
      #|                {
      #|                  v: "http://example.org",
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
      #|              ),
      #|              title: Some(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "a title",
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
      #|                    },
      #|                  ],
      #|                ),
      #|              ),
      #|            },
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|![an image](http://example.org "a title")
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Image(
      #|    {
      #|      v: {
      #|        text: Text(
      #|          {
      #|            v: "an image",
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
      #|        reference: Inline(
      #|          {
      #|            v: {
      #|              layout: {
      #|                indent: 0,
      #|                angled_dest: false,
      #|                before_dest: Seq([]),
      #|                after_dest: Seq(
      #|                  [
      #|                    {
      #|                      v: " ",
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
      #|                title_open_delim: '"',
      #|                after_title: Seq([]),
      #|              },
      #|              label: None,
      #|              defined_label: None,
      #|              dest: Some(
      #|                {
      #|                  v: "http://example.org",
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
      #|              ),
      #|              title: Some(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "a title",
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
      #|                    },
      #|                  ],
      #|                ),
      #|              ),
      #|            },
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|This is an ![inline image](
        #|  /heyho    (The
        #|    multiline title))
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "This is an ",
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
      #|          Image(
      #|            {
      #|              v: {
      #|                text: Text(
      #|                  {
      #|                    v: "inline image",
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
      #|                reference: Inline(
      #|                  {
      #|                    v: {
      #|                      layout: {
      #|                        indent: 0,
      #|                        angled_dest: false,
      #|                        before_dest: Seq(
      #|                          [
      #|                            { v: "", meta: { id: 0, loc: ..., extra: None } },
      #|                            { v: "  ", meta: { id: 0, loc: ..., extra: None } },
      #|                          ],
      #|                        ),
      #|                        after_dest: Seq([{ v: "    ", meta: { id: 0, loc: ..., extra: None } }]),
      #|                        title_open_delim: '(',
      #|                        after_title: Seq([]),
      #|                      },
      #|                      label: None,
      #|                      defined_label: None,
      #|                      dest: Some(
      #|                        {
      #|                          v: "/heyho",
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
      #|                            { blanks: "", node: { v: "The", meta: ... } },
      #|                            { blanks: "", node: { v: "multiline title", meta: ... } },
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
      #|)
    ),
  )
}

///|
test "should tokenize broken links across lines" {
  debug_inspect(
    tokenize_only(
      (
        #|and the [end
        #|condition], wow
      ),
    ),
    content=(
      #|(
      #|  CloserIndex({ RightBrack: <Set: [22]> }),
      #|  Tokens(
      #|    <Deque:
      #|      [
      #|        LinkStart({ start: 8, image: false }),
      #|        Newline(
      #|          {
      #|            start: 12,
      #|            break_ty: Soft,
      #|            newline: { pos: LinePos(2, 0), first: 13, last: 27 },
      #|          },
      #|        ),
      #|        RightBrack({ start: 22 }),
      #|      ]>,
      #|  ),
      #|  { pos: LinePos(1, 0), first: 0, last: 11 },
      #|)
    ),
  )
}

///|
test "should parse broken links across lines" {
  debug_inspect(
    parse_only(
      (
        #|and the [end
        #|condition], wow
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "and the [end",
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
      #|          Break(
      #|            {
      #|              v: {
      #|                layout_before: {
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
      #|                ty: Soft,
      #|                layout_after: {
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
      #|          Text(
      #|            {
      #|              v: "condition], wow",
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
      #|)
    ),
  )
}

///|
test "should parse raw HTML" {
  debug_inspect(
    parse_only(
      (
        #|<div><p>Some text</p></div>
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "<div>",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "<p>",
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
      #|          Text(
      #|            {
      #|              v: "Some text",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "</p>",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "</div>",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|foo <a href="\*" />u</a>
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "foo ",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "<a href=\"\\*\" />",
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
      #|          Text(
      #|            {
      #|              v: "u",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "</a>",
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
      #|)
    ),
  )
  debug_inspect(
    parse_only(
      (
        #|Haha <a>a</a><b2
        #|       data="foo" > hihi this is not the end yet.
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "Haha ",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "<a>",
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
      #|          Text(
      #|            {
      #|              v: "a",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "</a>",
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
      #|          RawHtml(
      #|            {
      #|              v: InlineRawHtml(
      #|                Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "<b2",
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
      #|                    },
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "data=\"foo\" >",
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
      #|          Text(
      #|            {
      #|              v: " hihi this is not the end yet.",
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
      #|)
    ),
  )
}

///|
test "should tokenize nested strikethroughs and emphases" {
  let doc =
    #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
  debug_inspect(
    tokenize_only(doc, strict=false),
    content=(
      #|(
      #|  CloserIndex(
      #|    {
      #|      EmphasisMarks('*'): <Set: [19, 25, 69]>,
      #|      StrikethroughMarks: <Set: [35, 67, 72]>,
      #|    },
      #|  ),
      #|  Tokens(
      #|    <Deque:
      #|      [
      #|        StrikethroughMarks({ start: 17, may_open: true, may_close: false }),
      #|        EmphasisMarks({ start: 19, char: '*', count: 1, may_open: true, may_close: true }),
      #|        EmphasisMarks({ start: 25, char: '*', count: 1, may_open: false, may_close: true }),
      #|        StrikethroughMarks({ start: 27, may_open: true, may_close: false }),
      #|        StrikethroughMarks({ start: 35, may_open: false, may_close: true }),
      #|        EmphasisMarks({ start: 38, char: '*', count: 1, may_open: true, may_close: false }),
      #|        EmphasisMarks({ start: 45, char: '*', count: 2, may_open: true, may_close: false }),
      #|        StrikethroughMarks({ start: 54, may_open: true, may_close: false }),
      #|        StrikethroughMarks({ start: 67, may_open: true, may_close: true }),
      #|        EmphasisMarks({ start: 69, char: '*', count: 3, may_open: true, may_close: true }),
      #|        StrikethroughMarks({ start: 72, may_open: false, may_close: true }),
      #|      ]>,
      #|  ),
      #|  { pos: LinePos(1, 0), first: 0, last: 73 },
      #|)
    ),
  )
}

///|
test "should parse strikethroughs" {
  debug_inspect(
    parse_only(
      strict=false,
      (
        #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
      ),
    ),
    content=(
      #|(
      #|  (0, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "Nesting the nest ",
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
      #|          ExtStrikethrough(
      #|            {
      #|              v: InlineStrikethrough(
      #|                Inlines(
      #|                  {
      #|                    v: Seq(
      #|                      [
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
      #|                            v: " ",
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
      #|                        ExtStrikethrough(
      #|                          {
      #|                            v: InlineStrikethrough(Text(...)),
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
      #|                            v: " ",
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
      #|)
    ),
  )
}

///|
test "should tokenize inline math" {
  debug_inspect(
    tokenize_only(
      strict=false,
      (
        #| This is $\LaTeX$ !!
      ),
    ),
    content=(
      #|(
      #|  CloserIndex({ MathSpanMarks(1): <Set: [16]> }),
      #|  Tokens(
      #|    <Deque:
      #|      [
      #|        MathSpanMarks({ start: 9, count: 1, may_open: true, may_close: false }),
      #|        MathSpanMarks({ start: 16, count: 1, may_open: false, may_close: true }),
      #|      ]>,
      #|  ),
      #|  { pos: LinePos(1, 0), first: 1, last: 19 },
      #|)
    ),
  )
}

///|
test "should parse inline math" {
  debug_inspect(
    parse_only(
      strict=false,
      (
        #| This is $\LaTeX$ !!
      ),
    ),
    content=(
      #|(
      #|  (1, ""),
      #|  Inlines(
      #|    {
      #|      v: Seq(
      #|        [
      #|          Text(
      #|            {
      #|              v: "This is ",
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
      #|          ExtMathSpan(
      #|            {
      #|              v: {
      #|                display: false,
      #|                tex_layout: Seq(
      #|                  [
      #|                    {
      #|                      blanks: "",
      #|                      node: {
      #|                        v: "\\LaTeX",
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
      #|          Text(
      #|            {
      #|              v: " !!",
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
      #|)
    ),
  )
}

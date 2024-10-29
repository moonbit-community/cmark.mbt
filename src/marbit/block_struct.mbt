// Block structure parsing.

fn Parser::curr_col(self : Parser) -> Col {
  self.curr_char_col + self.tab_consumed_cols
}

fn Parser::curr_indent(self : Parser) -> Col {
  self.next_non_blank_col - self.curr_col()
}

fn Parser::end_of_line(self : Parser) -> Bool {
  self.curr_char > self.curr_line_last_char
}

fn Parser::only_blanks(self : Parser) -> Bool {
  self.next_non_blank > self.curr_line_last_char
}

fn Parser::has_next_non_blank(self : Parser) -> Bool {
  self.next_non_blank <= self.curr_line_last_char
}

fn Parser::update_next_non_blank(self : Parser) -> Unit {
  loop self.i, self.curr_line_last_char, self.curr_char, self.curr_char_col {
    s, last, k, col =>
      if k > last {
        self.next_non_blank = k
        self.next_non_blank_col = col
      } else {
        match s[k] {
          ' ' => continue s, last, k + 1, col + 1
          '\t' => continue s, last, k + 1, next_tab_stop(col)
          _ => {
            self.next_non_blank = k
            self.next_non_blank_col = col
          }
        }
      }
  }
}

fn Parser::accept_cols(self : Parser, ~count : Int) -> Unit {
  loop count, self.curr_char, self.curr_char_col {
    count, k, col =>
      if count == 0 {
        self.curr_char = k
        self.curr_char_col = col
      } else if self.i[k] != '\t' {
        continue count - 1, k + 1, col + 1
      } else {
        let col1 = next_tab_stop(col)
        let tab_cols = col1 - (col + self.tab_consumed_cols)
        if tab_cols > count {
          self.tab_consumed_cols = count
          continue 0, k, col
        } else {
          self.tab_consumed_cols = 0
          continue count - tab_cols, k + 1, col1
        }
      }
  }
  self.update_next_non_blank()
}

/// https://spec.commonmark.org/current/#block-quote-marker
fn Parser::match_and_accept_block_quote(self : Parser) -> Bool {
  if self.end_of_line() || self.i[self.curr_char] != '>' {
    return false
  }
  let next_is_blank = {
    let next = self.curr_char + 1
    next <= self.curr_line_last_char && @char.is_ascii_blank(self.i[next])
  }
  self.accept_cols(
    count=if next_is_blank {
      2 // We eat a space
    } else {
      1
    },
  )
  true
}

/// Returns min indent after marker for list item
fn Parser::accept_list_marker_and_indent(
  self : Parser,
  ~marker_size : Int,
  ~last : Int
) -> Int {
  let _ = last
  self.accept_cols(count=marker_size)
  let indent = self.curr_indent()
  let min_indent = if self.only_blanks() || indent > 4 {
    1
  } else {
    @math.minimum(indent, 4)
  }
  self.accept_cols(count=min_indent)
  min_indent
}

/// Returns padding for partially consumed tab and content first char
fn Parser::accept_code_indent(self : Parser, ~count : Int) -> (Int, BytePos) {
  self.accept_cols(~count)
  if self.tab_consumed_cols == 0 {
    return (0, self.curr_char)
  }
  let col1 = next_tab_stop(self.curr_char_col)
  let pad = col1 - (self.curr_char_col + self.tab_consumed_cols)
  (pad, self.curr_char + 1) // curr_char is '\t
}

// These data types are only used during parsing, to find out the
// block structure. All the lists (blocks, lines) are in reverse
// order. We don't extract data from the input here. We just store
// line spans. See:
// https://spec.commonmark.org/current/#phase-1-block-structure
/// Number of space characters to pad content with
typealias SpacePad = Int

struct IndentedCodeLine {
  pad : SpacePad
  code : LineSpan
  is_blank : Bool
} derive(Show, ToJson)

struct Fence {
  indent : Indent
  opening_fence : LineSpan
  fence : (Char, Int) // Fence length
  info_string : LineSpan? // We drop the trailing blanks
  closing_fence : LineSpan?
} derive(Show, ToJson)

struct FenceCodeBlockStruct {
  fence : Fence
  code : List[(SpacePad, LineSpan)]
} derive(Show, ToJson)

enum CodeBlockStruct {
  Indented(List[IndentedCodeLine])
  Fenced(FenceCodeBlockStruct)
} derive(Show, ToJson)

struct Atx {
  indent : Indent
  level : HeadingLevel
  after_open : BytePos
  heading : LineSpan
  layout_after : LineSpan
} derive(Show, ToJson)

struct Setext {
  level : HeadingLevel
  heading_lines : List[LineSpan]
  /// Indent, underline char count, blanks
  underline : (Indent, LineSpan, LineSpan)
} derive(Show, ToJson)

enum Heading {
  Atx(Atx)
  Setext(Setext)
} derive(Show, ToJson)

struct HtmlBlockStruct {
  end_cond : HtmlBlockEndCond?
  html : List[LineSpan]
} derive(Show, ToJson)

struct Paragraph {
  maybe_ref : Bool
  lines : List[LineSpan]
} derive(Show, ToJson)

enum BlockStruct {
  BlockQuote(Indent, List[BlockStruct])
  BlankLine(SpacePad, LineSpan)
  CodeBlock(CodeBlockStruct)
  Heading(Heading)
  HtmlBlock(HtmlBlockStruct)
  List(ListBlockStruct)
  LinkRefDef(Node[LinkDefinition])
  Paragraph(Paragraph)
  ThematicBreak(Indent, LineSpan) // Including trailing blanks
  ExtTable(Indent, List[(LineSpan, LineSpan)]) // The second `LineSpan` is for trailing blanks
  ExtFootnote(Indent, (Label, Label?), List[BlockStruct])
} derive(Show, ToJson)

struct ListItemStruct {
  before_marker : Indent
  marker : LineSpan
  after_marker : Indent
  ext_task_marker : (Char, LineSpan)?
  blocks : List[BlockStruct]
} derive(Show, ToJson)

struct ListBlockStruct {
  last_blank : Bool // Last added line was blank and not first line of item
  loose : Bool // Inter-item looseness, intra-item is computed later
  item_min_indent : Indent // Last item minimal indent
  list_type : ListType
  items : List[ListItemStruct]
} derive(Show, ToJson)

fn BlockStruct::is_blank_line(self : BlockStruct) -> Bool {
  guard let BlockStruct::BlankLine(_, _) = self else { _ => return false }
  true
}

// Making blocks from the current line status

fn Parser::blank_line(self : Parser) -> BlockStruct {
  let first = self.curr_char
  let last = self.curr_line_last_char
  BlockStruct::BlankLine(0, self.curr_line_span(~first, ~last))
}

fn Parser::thematic_break(
  self : Parser,
  ~indent : Indent,
  ~last : BytePos
) -> BlockStruct {
  let _ = last
  let last = self.curr_line_last_char // Let's keep everything
  BlockStruct::ThematicBreak(
    indent,
    self.curr_line_span(first=self.curr_char, ~last),
  )
}

fn Parser::atx_heading(
  self : Parser,
  ~indent : Indent,
  ~level : HeadingLevel,
  ~after_open : BytePos,
  ~first_content : BytePos,
  ~last_content : BytePos
) -> BlockStruct {
  let heading = self.curr_line_span(first=first_content, last=last_content)
  let layout_after = self.curr_line_span(
    first=last_content + 1,
    last=self.curr_line_last_char,
  )
  Heading(Atx({ indent, level, after_open, heading, layout_after }))
}

fn Parser::setext_heading(
  self : Parser,
  ~level : HeadingLevel,
  heading_lines : List[LineSpan],
  ~indent : Indent,
  ~last_underline : BytePos
) -> BlockStruct {
  let u = self.curr_line_span(first=self.curr_char, last=last_underline)
  let blanks = self.curr_line_span(
    first=last_underline + 1,
    last=self.curr_line_last_char,
  )
  let underline = (indent, u, blanks)
  Heading(Setext({ level, heading_lines, underline }))
}

fn Parser::indented_code_block(self : Parser) -> BlockStruct {
  let (pad, first) = self.accept_code_indent(count=4)
  let code = self.curr_line_span(~first, last=self.curr_line_last_char)
  CodeBlock(Indented(List::of([{ pad, code, is_blank: false }])))
}

fn Parser::fenced_code_block(
  self : Parser,
  ~indent : Indent,
  ~fence_first : BytePos,
  ~fence_last : BytePos,
  ~info : (BytePos, BytePos)?
) -> BlockStruct {
  let (info_string, layout_last) = match info {
    None => (None, self.curr_line_last_char)
    Some((first, last)) => (Some(self.curr_line_span(~first, ~last)), first)
  }
  let opening_fence = self.curr_line_span(first=fence_first, last=layout_last)
  let fence = (self.i[fence_first], fence_last - fence_first + 1)
  let fence = { indent, opening_fence, fence, info_string, closing_fence: None }
  CodeBlock(Fenced({ fence, code: Nil }))
}

fn Parser::html_block(
  self : Parser,
  ~end_cond : HtmlBlockEndCond,
  ~indent_start : Indent
) -> BlockStruct {
  let first = indent_start
  let last = self.curr_line_last_char
  // Check if the same line matches the end condition.
  let end_cond = if LineType::html_block_end(
      self.i,
      ~end_cond,
      ~last,
      start=self.curr_char,
    ) {
    None // We are already closed
  } else {
    Some(end_cond)
  }
  HtmlBlock({ end_cond, html: List::of([self.curr_line_span(~first, ~last)]) })
}

fn Parser::paragraph(self : Parser, ~start : BytePos) -> BlockStruct {
  let last = self.curr_line_last_char
  let maybe_ref = @marbit_base.could_be_link_ref_definition(
    self.i,
    ~last,
    ~start,
  )
  let lines = List::of([self.curr_line_span(first=start, ~last)])
  Paragraph({ maybe_ref, lines })
}

fn Parser::add_paragraph_line(
  self : Parser,
  ~indent_start : Indent,
  ~par : Paragraph,
  ~bs : List[BlockStruct]
) -> List[BlockStruct] {
  let first = indent_start
  let last = self.curr_line_last_char
  let lines = par.lines.add(self.curr_line_span(~first, ~last))
  bs.add(Paragraph({ ..par, lines, }))
}

fn Parser::table_row(
  self : Parser,
  ~first : BytePos,
  ~last : BytePos
) -> (LineSpan, LineSpan) {
  (
    self.curr_line_span(~first, ~last),
    self.curr_line_span(first=last + 1, last=self.curr_line_last_char),
  )
}

fn Parser::table(
  self : Parser,
  ~indent : Indent,
  ~last : BytePos
) -> BlockStruct {
  let row = self.table_row(first=self.curr_char, ~last)
  ExtTable(indent, List::of([row]))
}

// Link reference definition parsing
// This is invoked when we close a paragraph and works on the paragraph lines.

/// Has no side effect on [p], parsing occurs on [lines] spans.
/// https://spec.commonmark.org/current/#link-reference-definitions
fn Parser::parse_link_ref_definition(
  self : Parser,
  lines : List[LineSpan]
) -> (Node[LinkDefinition], List[LineSpan])? {
  fn next_line(l : List[LineSpan]) {
    match l {
      Nil => None
      Cons(line, lines) => Some((lines, line))
    }
  }

  try {
    let (lines, line) = match next_line(lines) {
      Some(v) => v
      None => raise @marbit_base.Exit
    }
    let start = self.first_non_blank_in_span(line)
    let indent = start - line.first
    let meta_first = { ..line, first: start }
    let (lines, line, label, start) = match
      @marbit_base.link_label(
        self.buf,
        ~next_line,
        self.i,
        lines,
        ~line,
        ~start,
      ) {
      None => raise @marbit_base.Exit
      Some((lines, line, rev_spans, last, key)) => {
        let colon = last + 1
        if colon > line.last || self.i[colon] != ':' {
          raise @marbit_base.Exit
        }
        let label = label_of_rev_spans(self, ~key, rev_spans)
        (lines, line, label, colon + 1)
      }
    }
    let (lines, line, before_dest, start) = match
      self.first_non_blank_over_nl(~next_line, lines, line, ~start) {
      None => raise @marbit_base.Exit
      Some(v) => v
    }
    let (angled_dest, dest, start, meta_last) = match
      @marbit_base.link_destination(self.i, last=line.last, ~start) {
      None => raise @marbit_base.Exit
      Some((angled, first, last)) => {
        let dest = clean_unesc_unref_span(self, { ..line, first, last })
        let next = if angled { last + 2 } else { last + 1 }
        (angled, Some(dest), next, { ..line, last, })
      }
    }
    let (lines, after_dest, title_open_delim, title, after_title, meta_last) = match
      self.first_non_blank_over_nl(~next_line, lines, line, ~start) {
      None => (lines, List::Nil, '"', None, List::Nil, meta_last)
      Some((lines1, line1, after_dest, start1)) => {
        if start1 == start {
          raise @marbit_base.Exit
        }
        let no_newline = line1.pos == line.pos
        let title = @marbit_base.link_title(
          ~next_line,
          self.i,
          lines1,
          line=line1,
          start=start1,
        )
        match title {
          None =>
            if no_newline {
              raise @marbit_base.Exit
            } else {
              (lines, Nil, '"', None, Nil, meta_last)
            }
          Some((lines1, line1, rev_spans, last)) => {
            let after_title = {
              let last = line1.last
              let start = last + 1
              let nb = @marbit_base.first_non_blank(self.i, ~last, ~start)
              if nb <= line1.last {
                None
              } else {
                Some(
                  List::of(
                    [self.layout_clean_raw_span({ ..line1, first: start })],
                  ),
                )
              }
            }
            match after_title {
              None =>
                if no_newline {
                  raise @marbit_base.Exit
                } else {
                  (lines, Nil, '"', None, Nil, meta_last)
                }
              Some(after_title) => {
                let t = self.tight_block_lines(~rev_spans)
                (
                  lines1,
                  after_dest,
                  self.i[start1],
                  Some(t),
                  after_title,
                  { ..line1, last, },
                )
              }
            }
          }
        }
      }
    }
    let meta = self.meta_of_spans(first=meta_first, last=meta_last)
    let layout : LinkDefinitionLayout = {
      indent,
      angled_dest,
      before_dest,
      after_dest,
      title_open_delim,
      after_title,
    }
    let defined_label = self.def_label(label)
    let label = Some(label)
    let ld = { v: { layout, label, defined_label, dest, title }, meta }
    for def in defined_label {
      self.set_label_def(def, LinkDef(ld))
    }
    Some((ld, lines))
  } catch {
    @marbit_base.Exit => None
  }
}

fn Parser::maybe_add_link_ref_definitions(
  self : Parser,
  lines : List[LineSpan],
  prevs : List[BlockStruct]
) -> List[BlockStruct] {
  loop prevs, lines.rev() {
    prevs, Nil => prevs
    prevs, ls =>
      match self.parse_link_ref_definition(ls) {
        //  Link defs can't interrupt a paragraph so we are good now.
        None => prevs.add(Paragraph({ maybe_ref: false, lines: ls.rev() }))
        Some((ld, ls)) => continue prevs.add(LinkRefDef(ld)), ls
      }
  }
}

fn Parser::close_indented_code_block(
  self : Parser,
  lines : List[IndentedCodeLine],
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let _ = self
  loop List::Nil, lines, bs {
    blanks, lines, bs =>
      match lines {
        Cons({ pad, code, is_blank: true }, lines) =>
          continue blanks.add(BlockStruct::BlankLine(pad, code)), lines, bs
        Nil => List::rev_concat(blanks, bs) // Likely `abort()`
        Cons(_, _) as ls => blanks.rev_concat(bs.add(CodeBlock(Indented(ls))))
      }
  }
}

// Closing blocks and finishing the document.

fn Parser::close_paragraph(
  self : Parser,
  par : Paragraph,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  guard par.maybe_ref else { return bs.add(Paragraph(par)) }
  self.maybe_add_link_ref_definitions(par.lines, bs)
}

fn Parser::close_last_block(
  self : Parser,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  match bs {
    Cons(CodeBlock(Indented(ls)), bs) => self.close_indented_code_block(ls, bs)
    Cons(Paragraph(par), bs) => self.close_paragraph(par, bs)
    Cons(List(l), bs) => self.close_list(l, bs)
    Cons(ExtFootnote(i, l, blocks), bs) => self.close_footnote(i, l, blocks, bs)
    bs => bs
  }
}

fn Parser::close_list(
  self : Parser,
  l : ListBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let i = l.items.unsafe_head()
  let blocks = self.close_last_block(i.blocks)
  // The final blank line extraction of the list item entails less blank
  // line churn for CommonMark rendering but we don't do it on empty list items.
  match blocks {
    Cons(BlankLine(_, _) as bl, Cons(_, _) as blocks) => {
      let items = l.items.tail().add({ ..i, blocks, })
      bs.add(List({ ..l, items, })).add(bl)
    }
    blocks => {
      let items = l.items.tail().add({ ..i, blocks, })
      bs.add(List({ ..l, items, }))
    }
  }
}

fn Parser::close_footnote(
  self : Parser,
  indent : Indent,
  label : (Label, Label?),
  blocks : List[BlockStruct],
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let blocks = self.close_last_block(blocks)
  // Like for lists above we do blank line extraction (except if blocks is only a blank line)
  let (blanks, blocks) = loop List::Nil, blocks {
    acc, Cons(BlankLine(_, _) as bl, Cons(_, _) as blocks) =>
      continue acc.add(bl), blocks
    acc, blocks => (acc, blocks)
  }
  blanks.rev_concat(bs.add(ExtFootnote(indent, label, blocks)))
}

fn Parser::close_last_list_item(
  self : Parser,
  l : ListBlockStruct
) -> ListBlockStruct {
  let item = l.items.unsafe_head()
  let item = { ..item, blocks: self.close_last_block(item.blocks) }
  { ..l, items: l.items.tail().add(item) }
}

fn Parser::end_doc_close_fenced_code_block(
  self : Parser,
  fenced : FenceCodeBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let _ = self
  match fenced.code {
    Cons((_, l), code) =>
      if l.first > l.last { // Empty line
        let code = code.add((0, l))
        return bs.add(CodeBlock(Fenced({ ..fenced, code, })))
      }
    _ => ()
  }
  bs.add(CodeBlock(Fenced(fenced)))
}

fn Parser::end_doc_close_html(
  self : Parser,
  h : HtmlBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let _ = self
  match h.html {
    Cons(l, html) =>
      if l.first > l.last { // Empty line
        return bs.add(HtmlBlock({ end_cond: None, html })).add(BlankLine(0, l))
      }
    _ => ()
  }
  bs.add(HtmlBlock({ ..h, end_cond: None }))
}

fn Parser::end_doc(self : Parser, bs : List[BlockStruct]) -> List[BlockStruct] {
  match bs {
    Cons(BlockQuote(indent, bq), bs) =>
      bs.add(BlockQuote(indent, self.end_doc(bq)))
    Cons(List(l), bs) => self.close_list(l, bs)
    Cons(Paragraph(par), bs) => self.close_paragraph(par, bs)
    Cons(CodeBlock(Indented(ls)), bs) => self.close_indented_code_block(ls, bs)
    Cons(CodeBlock(Fenced(f)), bs) =>
      self.end_doc_close_fenced_code_block(f, bs)
    Cons(HtmlBlock(html), bs) => self.end_doc_close_html(html, bs)
    Cons(ExtFootnote(indent, label, blocks), bs) =>
      self.close_footnote(indent, label, blocks, bs)
    bs => bs
  }
}

// Adding lines to blocks

/// Effects on [p]'s column advance
fn Parser::match_line_type(
  self : Parser,
  ~no_setext : Bool,
  ~indent : SpacePad
) -> LineType {
  if self.only_blanks() {
    return BlankLine
  }
  if indent >= 4 {
    return IndentedCodeBlockLine
  }
  self.accept_cols(count=indent)
  if self.end_of_line() {
    return BlankLine
  }
  let start = self.curr_char
  let last = self.curr_line_last_char
  match (self.i[start], no_setext, self.exts) {
    // Early dispatch shaves a few ms but may not be worth doing vs 
    // testing all the cases in sequences.
    ('>', _, _) => {
      if self.match_and_accept_block_quote() {
        return BlockQuoteLine
      }
      ParagraphLine
    }
    ('=', false, _) => {
      guard let Nomatch = LineType::setext_heading_underline(
        self.i,
        ~last,
        ~start,
      ) else {
        r => return r
      }
      ParagraphLine
    }
    ('-', no_setext, _) => {
      guard let Nomatch = (if no_setext {
        LineType::Nomatch
      } else {
        LineType::setext_heading_underline(self.i, ~last, ~start)
      }) else {
        r => return r
      }
      guard let Nomatch = LineType::thematic_break(self.i, ~last, ~start) else {
        r => return r
      }
      guard let Nomatch = LineType::list_marker(self.i, ~last, ~start) else {
        r => return r
      }
      ParagraphLine
    }
    ('#', _, _) => {
      guard let Nomatch = LineType::atx_heading(self.i, ~last, ~start) else {
        r => return r
      }
      ParagraphLine
    }
    ('+' | '*' | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9', _, _
    ) => {
      guard let Nomatch = LineType::thematic_break(self.i, ~last, ~start) else {
        r => return r
      }
      let r = LineType::list_marker(self.i, ~last, ~start)
      guard let Nomatch = r else { r => return r }
      ParagraphLine
    }
    ('_', _, _) => {
      guard let Nomatch = LineType::thematic_break(self.i, ~last, ~start) else {
        r => return r
      }
      ParagraphLine
    }
    ('~' | '`', _, _) => {
      guard let Nomatch = LineType::fenced_code_block_start(
        self.i,
        ~last,
        ~start,
      ) else {
        r => return r
      }
      ParagraphLine
    }
    ('<', _, _) => {
      guard let Nomatch = LineType::html_block_start(self.i, ~last, ~start) else {
        r => return r
      }
      ParagraphLine
    }
    // ('|', _, true) => {
    //   guard let Nomatch = LineType::ext_table_row(self.i, ~last, ~start) else {
    //     r => return r
    //   }
    //   ParagraphLine
    // }
    ('[', _, true) => {
      guard let Nomatch = LineType::ext_footnote_label(
        self.buf,
        self.i,
        line_pos=self.curr_line_pos,
        ~last,
        ~start,
      ) else {
        r => return r
      }
      ParagraphLine
    }
    _ => ParagraphLine
  }
}

fn Parser::list_marker_can_interrupt_paragraph(
  self : Parser,
  marker : ListType,
  marker_last : BytePos
) -> Bool {
  guard let Ordered(1, _) | Unordered(_) = marker else { _ => return false }
  let non_blank = @marbit_base.first_non_blank(
    self.i,
    last=self.curr_line_last_char,
    start=marker_last + 1,
  )
  non_blank <= self.curr_line_last_char // Line is not blank
}

fn Parser::add_open_blocks_with_line_class(
  self : Parser,
  ~indent_start : Indent,
  ~indent : Indent,
  bs : List[BlockStruct],
  lt : LineType
) -> List[BlockStruct] {
  match lt {
    BlankLine => bs.add(self.blank_line())
    IndentedCodeBlockLine => bs.add(self.indented_code_block())
    BlockQuoteLine => bs.add(BlockQuote(indent, self.add_open_blocks(Nil)))
    ThematicBreakLine(last) => bs.add(self.thematic_break(~indent, ~last))
    ListMarkerLine(marker, marker_last) =>
      self.list(~indent, marker, marker_last, bs)
    AtxHeadingLine(level, after_open, first_content, last_content) =>
      bs.add(
        self.atx_heading(
          ~indent,
          ~level,
          ~after_open,
          ~first_content,
          ~last_content,
        ),
      )
    FencedCodeBlockLine(fence_first, fence_last, info) =>
      bs.add(self.fenced_code_block(~indent, ~fence_first, ~fence_last, ~info))
    HtmlBlockLine(end_cond) => bs.add(self.html_block(~end_cond, ~indent_start))
    ParagraphLine => bs.add(self.paragraph(start=indent_start))
    // ExtTableRow(last) => bs.add(self.table(~indent, ~last))
    ExtFootnoteLabel(rev_spans, last, key) =>
      bs.add(self.footnote(~indent, ~last, ~rev_spans, ~key))
    _ => abort("unimplemented")
  }
}

fn Parser::add_open_blocks(
  self : Parser,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  self.add_open_blocks_with_line_class(
    ~indent_start,
    ~indent,
    bs,
    self.match_line_type(no_setext=true, ~indent),
  )
}

fn Parser::footnote(
  self : Parser,
  ~indent : Indent,
  ~last : BytePos,
  ~rev_spans : RevSpans,
  ~key : String
) -> BlockStruct {
  let label = label_of_rev_spans(self, ~key, rev_spans)
  let defined_label = self.def_label(label)
  for def in defined_label {
    self.set_label_def(def, Label::stub(label, defined_label))
  }
  self.accept_cols(count=last - self.curr_char + 1)
  ExtFootnote(indent, (label, defined_label), self.add_open_blocks(Nil))
}

fn Parser::list_item(
  self : Parser,
  ~indent : Indent,
  _list_type : ListType,
  last : BytePos
) -> (Indent, ListItemStruct) {
  let before_marker = indent
  let marker_size = last - self.curr_char + 1
  let marker = self.curr_line_span(first=self.curr_char, ~last)
  let after_marker = self.accept_list_marker_and_indent(~marker_size, ~last)
  let (ext_task_marker, ext_task_marker_size) = if self.exts {
    let start = self.curr_char
    let last = self.curr_line_last_char
    match @marbit_base.ext_task_marker(self.i, ~last, ~start) {
      None => (None, 0)
      Some((u, last)) => {
        self.accept_cols(count=last - start + 1)
        let last = if last == self.curr_line_last_char {
          last
        } else {
          last - 1
        }
        (Some((u, self.curr_line_span(first=start, ~last))), 4)
      }
    }
  } else {
    (None, 0)
  }
  let min = indent + marker_size + after_marker + ext_task_marker_size
  let blocks = self.add_open_blocks(Nil)
  (min, { before_marker, marker, after_marker, ext_task_marker, blocks })
}

fn Parser::list(
  self : Parser,
  ~indent : Indent,
  list_type : ListType,
  marker_last : BytePos,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let (item_min_indent, item) = self.list_item(~indent, list_type, marker_last)
  let last_blank = false
  let loose = false
  let items = List::of([item])
  bs.add(List({ last_blank, loose, item_min_indent, list_type, items }))
}

fn Parser::try_add_to_list(
  self : Parser,
  ~indent : Indent,
  list_type : ListType,
  marker_last : BytePos,
  list : ListBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let (item_min_indent, item) = self.list_item(~indent, list_type, marker_last)
  if list.list_type.is_same_type(list_type) {
    let l = self.close_last_list_item(list)
    bs.add(
      List(
        {
          last_blank: false,
          loose: l.last_blank,
          item_min_indent,
          list_type: l.list_type,
          items: l.items.add(item),
        },
      ),
    )
  } else {
    let bs = self.close_list(list, bs)
    bs.add(
      List(
        {
          last_blank: false,
          loose: false,
          item_min_indent,
          list_type,
          items: List::of([item]),
        },
      ),
    )
  }
}

fn Parser::try_add_to_paragraph(
  self : Parser,
  par : Paragraph,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  match self.match_line_type(no_setext=false, ~indent) {
    // These can't interrupt paragraphs
    HtmlBlockLine(HtmlBlockEndCond::EndBlank7)
    | IndentedCodeBlockLine
    | ExtTableRow(_) | ExtFootnoteLabel(_) | ParagraphLine =>
      self.add_paragraph_line(~indent_start, ~par, ~bs)
    ListMarkerLine(marker, marker_last) =>
      if self.list_marker_can_interrupt_paragraph(marker, marker_last) {
        self.list(~indent, marker, marker_last, self.close_paragraph(par, bs))
      } else {
        self.add_paragraph_line(~indent_start, ~par, ~bs)
      }
    BlankLine => self.close_paragraph(par, bs).add(self.blank_line())
    BlockQuoteLine =>
      self
      .close_paragraph(par, bs)
      .add(BlockQuote(indent, self.add_open_blocks(Nil)))
    SetextUnderlineLine(level, last_underline) =>
      match self.close_paragraph(par, bs) {
        Cons(Paragraph(par), bs) =>
          bs.add(
            self.setext_heading(~indent, ~level, ~last_underline, par.lines),
          )
        bs => bs.add(self.paragraph(start=indent_start))
      }
    ThematicBreakLine(last) =>
      self.close_paragraph(par, bs).add(self.thematic_break(~indent, ~last))
    AtxHeadingLine(level, after_open, first_content, last_content) =>
      self
      .close_paragraph(par, bs)
      .add(
        self.atx_heading(
          ~indent,
          ~level,
          ~after_open,
          ~first_content,
          ~last_content,
        ),
      )
    FencedCodeBlockLine(fence_first, fence_last, info) =>
      self
      .close_paragraph(par, bs)
      .add(self.fenced_code_block(~indent, ~fence_first, ~fence_last, ~info))
    HtmlBlockLine(end_cond) =>
      self
      .close_paragraph(par, bs)
      .add(self.html_block(~end_cond, ~indent_start))
    Nomatch => abort("unreachable")
  }
}

fn Parser::try_add_to_indented_code_block(
  self : Parser,
  ls : List[IndentedCodeLine],
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  if self.curr_indent() < 4 {
    if self.has_next_non_blank() {
      self.add_open_blocks(self.close_indented_code_block(ls, bs))
    } else {
      // Blank but white is not data, make an empty span
      let first = self.curr_line_last_char + 1
      let last = self.curr_line_last_char
      let code = self.curr_line_span(~first, ~last)
      let l = { pad: 0, code, is_blank: true }
      bs.add(CodeBlock(Indented(ls.add(l))))
    }
  } else {
    let (pad, first) = self.accept_code_indent(count=4)
    let last = self.curr_line_last_char
    let is_blank = self.only_blanks()
    let l = { pad, code: self.curr_line_span(~first, ~last), is_blank }
    bs.add(CodeBlock(Indented(ls.add(l))))
  }
}

fn Parser::try_add_to_fenced_code_block(
  self : Parser,
  f : FenceCodeBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  match f {
    { fence: { closing_fence: Some(_), .. }, .. } => // Block is closed
      self.add_open_blocks(bs.add(CodeBlock(Fenced(f))))
    { fence: { indent, fence, .. }, code: ls } as b => {
      let start = self.curr_char
      let last = self.curr_line_last_char
      match
        @marbit_base.FencedCodeBlockContinue::new(self.i, ~fence, ~last, ~start) {
        Code => {
          let strip = @math.minimum(indent, self.curr_indent())
          let (pad, first) = self.accept_code_indent(count=strip)
          let code = ls.add((pad, self.curr_line_span(~first, ~last)))
          bs.add(CodeBlock(Fenced({ ..b, code, })))
        }
        Close(first, _fence_last) => {
          let close = self.curr_line_span(~first, ~last) // With layout
          let fence = { ..b.fence, closing_fence: Some(close) }
          bs.add(CodeBlock(Fenced({ ..b, fence, })))
        }
      }
    }
  }
}

fn Parser::try_add_to_html_block(
  self : Parser,
  b : HtmlBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  match b.end_cond {
    None => self.add_open_blocks(bs.add(HtmlBlock({ ..b, end_cond: None })))
    Some(end_cond) => {
      let start = self.curr_char
      let last = self.curr_line_last_char
      let l = self.curr_line_span(first=start, ~last)
      if LineType::html_block_end(self.i, ~end_cond, ~last, ~start) {
        match end_cond {
          EndBlank7 | EndBlank =>
            bs.add(HtmlBlock({ ..b, end_cond: None })).add(self.blank_line())
          _ => bs.add(HtmlBlock({ html: b.html.add(l), end_cond: None }))
        }
      } else {
        bs.add(HtmlBlock({ ..b, html: b.html.add(l) }))
      }
    }
  }
}

fn Parser::try_lazy_continuation(
  self : Parser,
  ~indent_start : Indent,
  bs : List[BlockStruct]
) -> List[BlockStruct]? {
  match bs {
    Cons(Paragraph(par), bs) =>
      Some(self.add_paragraph_line(~indent_start, ~par, ~bs))
    Cons(BlockQuote(indent, bq), bs) =>
      self
      .try_lazy_continuation(~indent_start, bq)
      .map(fn(bq) { bs.add(BlockQuote(indent, bq)) })
    Cons(List(l), bs) => {
      let i = l.items.unsafe_head()
      self
      .try_lazy_continuation(~indent_start, i.blocks)
      .map(
        fn(blocks) {
          let items = l.items.tail().add({ ..i, blocks, })
          bs.add(List({ ..l, items, last_blank: false }))
        },
      )
    }
    _ => None
  }
}

fn Parser::try_add_to_table(
  self : Parser,
  indent : Indent,
  rows : List[(LineSpan, LineSpan)],
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let indent_start = self.curr_char
  let curr_indent = self.curr_indent()
  match self.match_line_type(no_setext=true, indent=curr_indent) {
    ExtTableRow(last) => {
      let row = self.table_row(first=self.curr_char, ~last)
      bs.add(ExtTable(indent, rows.add(row)))
    }
    lt => {
      let bs = bs.add(ExtTable(indent, rows))
      self.add_open_blocks_with_line_class(
        ~indent_start,
        indent=curr_indent,
        bs,
        lt,
      )
    }
  }
}

fn Parser::try_add_to_block_quote(
  self : Parser,
  indent_layout : Indent,
  bq : List[BlockStruct],
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  match self.match_line_type(no_setext=true, ~indent) {
    BlockQuoteLine => bs.add(BlockQuote(indent_layout, self.add_line(bq)))
    IndentedCodeBlockLine | ParagraphLine as ltype =>
      match self.try_lazy_continuation(~indent_start, bq) {
        Some(bq) => bs.add(BlockQuote(indent_layout, bq))
        None => {
          let bs = bs.add(BlockQuote(indent_layout, self.close_last_block(bq)))
          self.add_open_blocks_with_line_class(
            ~indent_start,
            ~indent,
            bs,
            ltype,
          )
        }
      }
    lt => {
      let bs = bs.add(BlockQuote(indent_layout, self.close_last_block(bq)))
      self.add_open_blocks_with_line_class(~indent_start, ~indent, bs, lt)
    }
  }
}

fn Parser::try_add_to_footnote(
  self : Parser,
  fn_indent : Indent,
  label : (Label, Label?),
  blocks : List[BlockStruct],
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  if indent < fn_indent + 1 { // Position of ^
    match self.match_line_type(no_setext=true, ~indent) {
      IndentedCodeBlockLine | ParagraphLine as lt =>
        match self.try_lazy_continuation(~indent_start, blocks) {
          Some(blocks) => bs.add(ExtFootnote(fn_indent, label, blocks))
          None => {
            let blocks = self.close_last_block(blocks)
            let bs = self.close_footnote(fn_indent, label, blocks, bs)
            self.add_open_blocks_with_line_class(~indent_start, ~indent, bs, lt)
          }
        }
      BlankLine => bs.add(ExtFootnote(fn_indent, label, self.add_line(blocks)))
      lt => {
        let bs = self.close_footnote(fn_indent, label, blocks, bs)
        self.add_open_blocks_with_line_class(~indent_start, ~indent, bs, lt)
      }
    }
  } else {
    self.accept_cols(count=fn_indent + 1)
    bs.add(ExtFootnote(fn_indent, label, self.add_line(blocks)))
  }
}

fn Parser::try_add_to_list_item(
  self : Parser,
  list : ListBlockStruct,
  bs : List[BlockStruct]
) -> List[BlockStruct] {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  if indent >= list.item_min_indent {
    let last_blank = self.only_blanks()
    let item = list.items.unsafe_head()
    let items = list.items.tail()
    return if list.last_blank &&
      last_blank.not() &&
      item.blocks.all(is_blank_line) {
      // Item can only start with a single blank line, 
      // if we are here it's not a new item so the list ends
      self.add_open_blocks(bs.add(List(list)))
    } else {
      self.accept_cols(count=list.item_min_indent)
      let item = { ..item, blocks: self.add_line(item.blocks) }
      bs.add(List({ ..list, items: items.add(item), last_blank }))
    }
  }
  match self.match_line_type(no_setext=true, ~indent) {
    BlankLine => {
      let item = list.items.unsafe_head()
      let items = list.items.tail()
      let item = { ..item, blocks: self.add_line(item.blocks) }
      bs.add(List({ ..list, items: items.add(item), last_blank: true }))
    }
    IndentedCodeBlockLine | ParagraphLine as ltype => {
      let item = list.items.unsafe_head()
      let items = list.items.tail()
      match self.try_lazy_continuation(~indent_start, item.blocks) {
        Some(blocks) => {
          let items = items.add({ ..item, blocks, })
          bs.add(List({ ..list, items, last_blank: false }))
        }
        None => {
          let bs = self.close_list(list, bs)
          self.add_open_blocks_with_line_class(
            ~indent_start,
            ~indent,
            bs,
            ltype,
          )
        }
      }
    }
    ListMarkerLine(marker, marker_last) =>
      self.try_add_to_list(~indent, marker, marker_last, list, bs)
    lt => {
      let bs = self.close_list(list, bs)
      self.add_open_blocks_with_line_class(~indent_start, ~indent, bs, lt)
    }
  }
}

fn Parser::add_line(self : Parser, bs : List[BlockStruct]) -> List[BlockStruct] {
  match bs {
    Cons(Paragraph(par), bs) => self.try_add_to_paragraph(par, bs)
    Cons(ThematicBreak(_) | Heading(_) | BlankLine(_) | LinkRefDef(_), _) | Nil =>
      self.add_open_blocks(bs)
    Cons(List(l), bs) => self.try_add_to_list_item(l, bs)
    Cons(CodeBlock(Indented(ls)), bs) =>
      self.try_add_to_indented_code_block(ls, bs)
    Cons(CodeBlock(Fenced(f)), bs) => self.try_add_to_fenced_code_block(f, bs)
    Cons(BlockQuote(indent, bq), bs) =>
      self.try_add_to_block_quote(indent, bq, bs)
    Cons(HtmlBlock(html), bs) => self.try_add_to_html_block(html, bs)
    Cons(ExtTable(indent, rows), bs) => self.try_add_to_table(indent, rows, bs)
    Cons(ExtFootnote(i, l, blocks), bs) =>
      self.try_add_to_footnote(i, l, blocks, bs)
  }
}

fn Parser::get_first_line(self : Parser) -> String {
  let max = self.i.length() - 1
  let mut k = 0
  let last_char = while k <= max && "\r\n".contains_char(self.i[k]).not() {
    k += 1
  } else {
    // If the line is empty, we have -1
    k - 1
  }
  self.curr_line_last_char = last_char
  self.update_next_non_blank()
  // Return first used newline (or "\n" if there is none)
  if k > max || self.i[k] == '\n' {
    return "\n"
  }
  let next = k + 1
  if next <= max && self.i[next] == '\n' {
    return "\r\n"
  }
  "\r"
}

fn Parser::get_next_line(self : Parser) -> Bool {
  let max = self.i.length() - 1
  if self.curr_line_last_char == max {
    return false
  }
  let first_char = {
    let nl = self.curr_line_last_char + 1
    if self.i[nl] == '\n' {
      nl + 1
    } else {
      let mut next = nl + 1
      if next <= max && self.i[next] == '\n' {
        next += 1
      }
      next
    }
  }
  let last_char = for k = first_char
                      k <= max && "\r\n".contains_char(self.i[k]).not()
                      k = k + 1 {

  } else {
    k - 1
  }
  self.curr_line_pos = (self.curr_line_pos.0 + 1, first_char)
  self.curr_line_last_char = last_char
  self.curr_char = first_char
  self.curr_char_col = 0
  self.tab_consumed_cols = 0
  self.update_next_non_blank()
  true
}

fn Parser::parse_block(self : Parser) -> (String, Node[List[BlockStruct]]) {
  fn meta() {
    self.meta(
      {
        file: self.file,
        first_byte: 0,
        last_byte: self.curr_line_last_char,
        first_line: (1, 0),
        last_line: self.curr_line_pos,
      },
    )
  }

  let nl = self.get_first_line()
  let blocks = loop List::Nil {
    bs => {
      let bs = self.add_line(bs)
      if self.get_next_line() {
        continue bs
      }
      { v: self.end_doc(bs), meta: meta() }
    }
  }
  (nl, blocks)
}

// Building the final AST, invokes inline parsing.

fn Parser::block_struct_to_blank_line(
  self : Parser,
  pad : Indent,
  span : LineSpan
) -> Block {
  BlankLine(self.clean_raw_span(~pad, span))
}

fn Parser::block_struct_to_code_block(
  self : Parser,
  b : CodeBlockStruct
) -> Block {
  match b {
    Indented(ls) => {
      let line = fn(i : IndentedCodeLine) {
        self.clean_raw_span(pad=i.pad, i.code)
      }
      let layout = CodeBlockLayout::Indented
      let info_string = None
      let last = ls.unsafe_head().code
      let code = ls.rev_map(line)
      let meta = {
        let last_line = last.pos
        let last_byte = last.last
        let start = code.unsafe_head().meta.loc
        self.meta({ ..start, last_byte, last_line })
      }
      CodeBlock({ v: { layout, info_string, code }, meta })
    }
    Fenced({ fence, code: ls }) => {
      let layout = {
        let opening_fence = self.layout_clean_raw_span(fence.opening_fence)
        let closing_fence = fence.closing_fence.map(
          fn(i) { self.layout_clean_raw_span(i) },
        )
        { indent: fence.indent, opening_fence, closing_fence }
      }
      let info_string = fence.info_string.map(
        fn(i) { self.clean_unesc_unref_span(i) },
      )
      let code = ls.rev_map(fn(i) { self.clean_raw_span(pad=i.0, i.1) })
      let meta = {
        let first = fence.opening_fence
        let last = match fence.closing_fence {
          Some(last) => last
          None =>
            match ls {
              Cons((_, last), _) => last
              Nil => first
            }
        }
        self.meta_of_spans(~first, ~last)
      }
      let cb = { layout: Fenced(layout), info_string, code }
      // if self.exts && CodeBlock::is_math_block(info_string.map(fn(i) { i.v })) {
      //   return ExtMathBlock(cb, meta)
      // }
      CodeBlock({ v: cb, meta })
    }
  }
}

fn Parser::block_struct_to_heading(self : Parser, b : Heading) -> Block {
  match b {
    Atx({ indent, level, after_open, heading, layout_after }) => {
      let after_opening = {
        let first = after_open
        let last = heading.first - 1
        self.layout_clean_raw_span1({ ..heading, first, last })
      }
      let closing = self.layout_clean_raw_span1(layout_after)
      let layout = BlockHeadingLayout::Atx({ indent, after_opening, closing })
      let meta = self.meta(
        self.text_loc_of_span({ ..heading, first: after_open - level }),
      )
      let (_, inline) = self.parse_inline(List::of([heading]))
      let id = if self.heading_auto_ids {
        Some(Auto(inline.id()))
      } else {
        None
      }
      Heading({ v: { layout, level, inline, id }, meta })
    }
    Setext({ level, heading_lines, underline }) => {
      let ((leading_indent, trailing_blanks), inline) = self.parse_inline(
        heading_lines,
      )
      let (underline_indent, u, blanks) = underline
      let underline_blanks = self.layout_clean_raw_span1(blanks)
      let underline_count = {
        v: u.last - u.first + 1,
        meta: self.meta(self.text_loc_of_span(u)),
      }
      let layout = {
        leading_indent,
        trailing_blanks,
        underline_indent,
        underline_count,
        underline_blanks,
      }
      let meta = {
        let last_line = u.pos
        let last_byte = u.last
        let start = inline.meta().loc
        self.meta({ ..start, last_byte, last_line })
      }
      let id = if self.heading_auto_ids {
        Some(Auto(inline.id(buf=self.buf)))
      } else {
        None
      }
      Heading({ v: { layout: Setext(layout), level, inline, id }, meta })
    }
  }
}

fn Parser::block_struct_to_html_block(
  self : Parser,
  b : HtmlBlockStruct
) -> Block {
  let last = b.html.unsafe_head()
  let last_byte = last.last
  let last_line = last.pos
  let lines = b.html.rev_map(fn(i) { self.clean_raw_span(i) })
  let start_loc = lines.unsafe_head().meta.loc
  let meta = self.meta({ ..start_loc, last_byte, last_line })
  HtmlBlock({ v: lines, meta })
}

fn Parser::block_struct_to_paragraph(self : Parser, par : Paragraph) -> Block {
  let (layout, inline) = self.parse_inline(par.lines)
  let (leading_indent, trailing_blanks) = layout
  let meta = inline.meta()
  Paragraph({ v: { leading_indent, inline, trailing_blanks }, meta })
}

fn Parser::block_struct_to_thematic_break(
  self : Parser,
  indent : Indent,
  span : LineSpan
) -> Block {
  let { v: layout, meta } = self.clean_raw_span(span) // No layout because of loc
  ThematicBreak({ v: { indent, layout }, meta })
}

// fn Parser::block_struct_to_table()

fn Parser::block_struct_to_block_quote(
  self : Parser,
  indent : Indent,
  bs : List[BlockStruct]
) -> Block {
  let add_block = fn(acc : List[_], b) {
    acc.add(self.block_struct_to_block(b))
  }
  let last = self.block_struct_to_block(bs.unsafe_head())
  let block = match bs.tail().fold(add_block, init=List::of([last])) {
    Cons(b, Nil) => b
    quote => {
      let first = quote.unsafe_head().meta()
      let last = last.meta()
      let meta = self.meta_of_metas(~first, ~last)
      Blocks({ v: quote, meta })
    }
  }
  BlockQuote({ v: { indent, block }, meta: block.meta() })
}

fn Parser::block_struct_to_footnote_definition(
  self : Parser,
  indent : Indent,
  label : Label,
  defined_label : Label?,
  bs : List[BlockStruct]
) -> Block {
  let add_block = fn(acc : List[_], b) {
    acc.add(self.block_struct_to_block(b))
  }
  let last = self.block_struct_to_block(bs.unsafe_head())
  let block = bs.tail().fold(add_block, init=List::of([last]))
  let last = last.meta()
  let block = match block {
    Cons(b, Nil) => b
    blocks => {
      let first = blocks.unsafe_head().meta()
      let meta = self.meta_of_metas(~first, ~last)
      Blocks({ v: blocks, meta })
    }
  }
  let loc = {
    let labelloc = label.text_loc()
    let lastloc = last.loc
    let loc = labelloc.span(lastloc)
    let first_byte = loc.first_byte - 1
    { ..loc, first_byte, first_line: loc.first_line }
  }
  let footnote = {
    v: { indent, label, defined_label, block },
    meta: self.meta(loc),
  }
  match defined_label {
    None => ()
    Some(def) => self.set_label_def(def, FootnoteDef(footnote))
  }
  ExtFootnoteDefinition(footnote)
}

enum BState {
  Blank
  TrailBlank
  NonBlank
} derive(Eq)

fn Parser::block_struct_to_list_item(
  self : Parser,
  i : ListItemStruct
) -> (Node[ListItem], Bool) {
  fn go(bstate : BState, tight, acc : List[_], bs : List[BlockStruct]) {
    match bs {
      Cons(BlankLine(_) as bl, bs) => {
        let bstate = if bstate == TrailBlank { TrailBlank } else { Blank }
        go(bstate, tight, acc.add(self.block_struct_to_block(bl)), bs)
      }
      Cons(
        List({ items: Cons({ blocks: Cons(BlankLine(_), _), .. }, _), .. }) as l,
        bs
      ) => go(bstate, false, acc.add(self.block_struct_to_block(l)), bs)
      Cons(b, bs) => {
        let tight = tight && bstate != Blank
        go(NonBlank, tight, acc.add(self.block_struct_to_block(b)), bs)
      }
      Nil => (tight, acc)
    }
  }

  let (last_meta, (tight, blocks)) = match i.blocks {
    Cons(BlankLine(_) as blank, Nil) => {
      let bl = self.block_struct_to_block(blank)
      (bl.meta(), (true, List::of([bl])))
    }
    Cons(BlankLine(_) as blank, bs) => {
      let bl = self.block_struct_to_block(blank)
      (bl.meta(), go(TrailBlank, true, List::of([bl]), bs))
    }
    Cons(b, bs) => {
      let b = self.block_struct_to_block(b)
      (b.meta(), go(NonBlank, true, List::of([b]), bs))
    }
    Nil => abort("unreachable")
  }
  let block = match blocks {
    Cons(i, Nil) => i
    blocks => {
      let first = blocks.unsafe_head().meta()
      Blocks({ v: blocks, meta: self.meta_of_metas(~first, last=last_meta) })
    }
  }
  let before_marker = i.before_marker
  let after_marker = i.after_marker
  let marker = self.clean_raw_span(i.marker)
  let ext_task_marker = match i.ext_task_marker {
    None => None
    Some((v, span)) => Some({ v, meta: self.meta(self.text_loc_of_span(span)) })
  }
  let v = { before_marker, marker, after_marker, block, ext_task_marker }
  let meta = self.meta_of_metas(first=marker.meta, last=last_meta)
  ({ v, meta }, tight)
}

fn Parser::block_struct_to_list(self : Parser, list : ListBlockStruct) -> Block {
  let items = list.items
  let (last, tight) = self.block_struct_to_list_item(items.unsafe_head())
  let (tight, items) = loop
    list.loose.not() && tight,
    List::of([last]),
    items.tail() {
    tight, acc, Nil => (tight, acc)
    tight, acc, Cons(item, items) => {
      let (item, item_tight) = self.block_struct_to_list_item(item)
      continue tight && item_tight, acc.add(item), items
    }
  }
  let meta = self.meta_of_metas(first=items.unsafe_head().meta, last=last.meta)
  List({ v: { ty: list.list_type, tight, items }, meta })
}

fn Parser::block_struct_to_block(self : Parser, b : BlockStruct) -> Block {
  match b {
    BlockQuote(indent, bs) => self.block_struct_to_block_quote(indent, bs)
    List(l) => self.block_struct_to_list(l)
    Paragraph(par) => self.block_struct_to_paragraph(par)
    ThematicBreak(indent, span) =>
      self.block_struct_to_thematic_break(indent, span)
    CodeBlock(cb) => self.block_struct_to_code_block(cb)
    Heading(h) => self.block_struct_to_heading(h)
    HtmlBlock(html) => self.block_struct_to_html_block(html)
    BlankLine(pad, span) => self.block_struct_to_blank_line(pad, span)
    LinkRefDef(r) => LinkRefDefinition(r)
    // ExtTable(i, rows) => self.block_struct_to_table(i, rows)
    ExtFootnote(i, (lb, dlb), bs) =>
      self.block_struct_to_footnote_definition(i, lb, dlb, bs)
    _ => abort("unimplemented")
  }
}

fn Parser::block_struct_to_doc(
  self : Parser,
  doc : Node[List[BlockStruct]]
) -> Block {
  let { v: doc, meta } = doc
  match doc.rev_map(fn(b) { self.block_struct_to_block(b) }) {
    Cons(b, Nil) => b
    bs => Blocks({ v: bs, meta })
  }
}

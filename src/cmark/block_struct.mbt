// Block structure parsing.

///|
fn Parser::curr_col(self : Parser) -> Col {
  self.curr_char_col + self.tab_consumed_cols
}

///|
fn Parser::curr_indent(self : Parser) -> Col {
  self.next_non_blank_col - self.curr_col()
}

///|
fn Parser::end_of_line(self : Parser) -> Bool {
  self.curr_char > self.curr_line_last_char
}

///|
fn Parser::only_blanks(self : Parser) -> Bool {
  self.next_non_blank > self.curr_line_last_char
}

///|
fn Parser::has_next_non_blank(self : Parser) -> Bool {
  self.next_non_blank <= self.curr_line_last_char
}

///|
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

///|
fn Parser::accept_cols(self : Parser, count~ : Int) -> Unit {
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

///| https://spec.commonmark.org/current/#block-quote-marker
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

///| Returns min indent after marker for list item
fn Parser::accept_list_marker_and_indent(
  self : Parser,
  marker_size~ : Int,
  last~ : Int
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

///| Returns padding for partially consumed tab and content first char
fn Parser::accept_code_indent(self : Parser, count~ : Int) -> (Int, BytePos) {
  self.accept_cols(count~)
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
///| Number of space characters to pad content with
typealias SpacePad = Int

///|
struct IndentedCodeLine {
  pad : SpacePad
  code : LineSpan
  is_blank : Bool
} derive(Show, ToJson)

///|
struct Fence {
  indent : Indent
  opening_fence : LineSpan
  fence : (Char, Int) // Fence length
  info_string : LineSpan? // We drop the trailing blanks
  closing_fence : LineSpan?
} derive(Show, ToJson)

///|
struct FenceCodeBlockStruct {
  fence : Fence
  code : Array[(SpacePad, LineSpan)]
} derive(Show, ToJson)

///|
enum CodeBlockStruct {
  Indented(Array[IndentedCodeLine])
  Fenced(FenceCodeBlockStruct)
} derive(Show, ToJson)

///|
struct Atx {
  indent : Indent
  level : HeadingLevel
  after_open : BytePos
  heading : LineSpan
  layout_after : LineSpan
} derive(Show, ToJson)

///|
struct Setext {
  level : HeadingLevel
  heading_lines : Array[LineSpan]
  /// Indent, underline char count, blanks
  underline : (Indent, LineSpan, LineSpan)
} derive(Show, ToJson)

///|
enum Heading {
  Atx(Atx)
  Setext(Setext)
} derive(Show, ToJson)

///|
struct HtmlBlockStruct {
  end_cond : HtmlBlockEndCond?
  html : Array[LineSpan]
} derive(Show, ToJson)

///|
struct Paragraph {
  maybe_ref : Bool
  lines : Array[LineSpan]
} derive(Show, ToJson)

///|
enum BlockStruct {
  BlockQuote(Indent, Array[BlockStruct])
  BlankLine(SpacePad, LineSpan)
  CodeBlock(CodeBlockStruct)
  Heading(Heading)
  HtmlBlock(HtmlBlockStruct)
  List(ListBlockStruct)
  LinkRefDef(Node[LinkDefinition])
  Paragraph(Paragraph)
  ThematicBreak(Indent, LineSpan) // Including trailing blanks
  ExtTable(Indent, Array[(LineSpan, LineSpan)]) // The second `LineSpan` is for trailing blanks
  ExtFootnote(Indent, (Label, Label?), Array[BlockStruct])
} derive(Show, ToJson)

///|
struct ListItemStruct {
  before_marker : Indent
  marker : LineSpan
  after_marker : Indent
  ext_task_marker : (Char, LineSpan)?
  blocks : Array[BlockStruct]
} derive(Show, ToJson)

///|
struct ListBlockStruct {
  mut last_blank : Bool // Last added line was blank and not first line of item
  loose : Bool // Inter-item looseness, intra-item is computed later
  item_min_indent : Indent // Last item minimal indent
  list_type : ListType
  items : Array[ListItemStruct]
} derive(Show, ToJson)

///|
fn BlockStruct::is_blank_line(self : BlockStruct) -> Bool {
  guard let BlockStruct::BlankLine(_, _) = self else { _ => return false }
  true
}

// Making blocks from the current line status

///|
fn Parser::blank_line(self : Parser) -> BlockStruct {
  let first = self.curr_char
  let last = self.curr_line_last_char
  BlockStruct::BlankLine(0, self.curr_line_span(first~, last~))
}

///|
fn Parser::thematic_break(
  self : Parser,
  indent~ : Indent,
  last~ : BytePos
) -> BlockStruct {
  let _ = last
  let last = self.curr_line_last_char // Let's keep everything
  BlockStruct::ThematicBreak(
    indent,
    self.curr_line_span(first=self.curr_char, last~),
  )
}

///|
fn Parser::atx_heading(
  self : Parser,
  indent~ : Indent,
  level~ : HeadingLevel,
  after_open~ : BytePos,
  first_content~ : BytePos,
  last_content~ : BytePos
) -> BlockStruct {
  let heading = self.curr_line_span(first=first_content, last=last_content)
  let layout_after = self.curr_line_span(
    first=last_content + 1,
    last=self.curr_line_last_char,
  )
  Heading(Atx({ indent, level, after_open, heading, layout_after }))
}

///|
fn Parser::setext_heading(
  self : Parser,
  level~ : HeadingLevel,
  heading_lines : Array[LineSpan],
  indent~ : Indent,
  last_underline~ : BytePos
) -> BlockStruct {
  let u = self.curr_line_span(first=self.curr_char, last=last_underline)
  let blanks = self.curr_line_span(
    first=last_underline + 1,
    last=self.curr_line_last_char,
  )
  let underline = (indent, u, blanks)
  Heading(Setext({ level, heading_lines, underline }))
}

///|
fn Parser::indented_code_block(self : Parser) -> BlockStruct {
  let (pad, first) = self.accept_code_indent(count=4)
  let code = self.curr_line_span(first~, last=self.curr_line_last_char)
  CodeBlock(Indented([{ pad, code, is_blank: false }]))
}

///|
fn Parser::fenced_code_block(
  self : Parser,
  indent~ : Indent,
  fence_first~ : BytePos,
  fence_last~ : BytePos,
  info~ : (BytePos, BytePos)?
) -> BlockStruct {
  let (info_string, layout_last) = match info {
    None => (None, self.curr_line_last_char)
    Some((first, last)) => (Some(self.curr_line_span(first~, last~)), first)
  }
  let opening_fence = self.curr_line_span(first=fence_first, last=layout_last)
  let fence = (self.i[fence_first], fence_last - fence_first + 1)
  let fence = { indent, opening_fence, fence, info_string, closing_fence: None }
  CodeBlock(Fenced({ fence, code: [] }))
}

///|
fn Parser::html_block(
  self : Parser,
  end_cond~ : HtmlBlockEndCond,
  indent_start~ : Indent
) -> BlockStruct {
  let first = indent_start
  let last = self.curr_line_last_char
  // Check if the same line matches the end condition.
  let end_cond = if LineType::html_block_end(
      self.i,
      end_cond~,
      last~,
      start=self.curr_char,
    ) {
    None // We are already closed
  } else {
    Some(end_cond)
  }
  HtmlBlock({ end_cond, html: [self.curr_line_span(first~, last~)] })
}

///|
fn Parser::paragraph(self : Parser, start~ : BytePos) -> BlockStruct {
  let last = self.curr_line_last_char
  let maybe_ref = @cmark_base.could_be_link_ref_definition(
    self.i,
    last~,
    start~,
  )
  let lines = [self.curr_line_span(first=start, last~)]
  Paragraph({ maybe_ref, lines })
}

///|
fn Parser::add_paragraph_line(
  self : Parser,
  indent_start~ : Indent,
  par~ : Paragraph,
  bs~ : Array[BlockStruct]
) -> Unit {
  let first = indent_start
  let last = self.curr_line_last_char
  let lines = par.lines
  lines.push(self.curr_line_span(first~, last~))
  bs.push(Paragraph({ ..par, lines, }))
}

///|
fn Parser::table_row(
  self : Parser,
  first~ : BytePos,
  last~ : BytePos
) -> (LineSpan, LineSpan) {
  (
    self.curr_line_span(first~, last~),
    self.curr_line_span(first=last + 1, last=self.curr_line_last_char),
  )
}

///|
fn Parser::table(
  self : Parser,
  indent~ : Indent,
  last~ : BytePos
) -> BlockStruct {
  let row = self.table_row(first=self.curr_char, last~)
  ExtTable(indent, [row])
}

// Link reference definition parsing
// This is invoked when we close a paragraph and works on the paragraph lines.

///| Has no side effect on [p], parsing occurs on [lines] spans.
/// https://spec.commonmark.org/current/#link-reference-definitions
fn Parser::parse_link_ref_definition(
  self : Parser,
  lines : Array[LineSpan]
) -> Node[LinkDefinition]? {
  let lines_arr = lines
  fn next_line(i : Ref[Int]) {
    guard i.val < lines_arr.length() else { None }
    let res = Some(lines_arr[i.val])
    i.val += 1
    res
  }

  let lines = Ref::new(0)
  try {
    guard let Some(line) = next_line(lines) else { _ => raise @cmark_base.Exit }
    let start = self.first_non_blank_in_span(line)
    let indent = start - line.first
    let meta_first = { ..line, first: start }
    let (lines, line, label, start) = match
      @cmark_base.link_label(self.buf, next_line~, self.i, lines, line~, start~) {
      None => raise @cmark_base.Exit
      Some((line, spans, last, key)) => {
        let colon = last + 1
        if colon > line.last || self.i[colon] != ':' {
          raise @cmark_base.Exit
        }
        let label = label_of_spans(self, key~, spans[:])
        (lines, line, label, colon + 1)
      }
    }
    let (line, before_dest, start) = match
      self.first_non_blank_over_nl(next_line~, lines, line, start~) {
      None => raise @cmark_base.Exit
      Some(v) => v
    }
    let (angled_dest, dest, start, meta_last) = match
      @cmark_base.link_destination(self.i, last=line.last, start~) {
      None => raise @cmark_base.Exit
      Some((angled, first, last)) => {
        let dest = clean_unesc_unref_span(self, { ..line, first, last })
        let next = if angled { last + 2 } else { last + 1 }
        (angled, Some(dest), next, { ..line, last, })
      }
    }
    let (lines, after_dest, title_open_delim, title, after_title, meta_last) = match
      self.first_non_blank_over_nl(next_line~, lines, line, start~) {
      None => (lines, [], '"', None, [], meta_last)
      Some((line1, after_dest, start1)) => {
        if start1 == start {
          raise @cmark_base.Exit
        }
        let no_newline = line1.pos == line.pos
        let title = @cmark_base.link_title(
          next_line~,
          self.i,
          lines,
          line=line1,
          start=start1,
        )
        match title {
          None =>
            if no_newline {
              raise @cmark_base.Exit
            } else {
              (lines, [], '"', None, [], meta_last)
            }
          Some((line1, spans, last)) => {
            let after_title = {
              let last = line1.last
              let start = last + 1
              let nb = @cmark_base.first_non_blank(self.i, last~, start~)
              if nb <= line1.last {
                None
              } else {
                Some([self.layout_clean_raw_span({ ..line1, first: start })])
              }
            }
            match after_title {
              None =>
                if no_newline {
                  raise @cmark_base.Exit
                } else {
                  (lines, [], '"', None, [], meta_last)
                }
              Some(after_title) => {
                let t : Seq[_] = self.tight_block_lines(spans=spans[:])
                (
                  lines,
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
    let _ = lines_arr.drain(0, lines.val)
    Some(ld)
  } catch {
    @cmark_base.Exit => None
  }
}

///|
fn Parser::maybe_add_link_ref_definitions(
  self : Parser,
  lines : Array[LineSpan],
  prevs : Array[BlockStruct]
) -> Unit {
  while not(lines.is_empty()) {
    guard let Some(ld) = self.parse_link_ref_definition(lines) else {
      //  Link defs can't interrupt a paragraph so we are good now.
      _ => {
        prevs.push(Paragraph({ maybe_ref: false, lines }))
        break
      }
    }
    prevs.push(LinkRefDef(ld))
  }
}

///|
fn Parser::close_indented_code_block(
  self : Parser,
  lines : Array[IndentedCodeLine],
  bs : Array[BlockStruct]
) -> Unit {
  let _ = self
  let blanks = []
  for {
    match lines.last() {
      Some({ is_blank: true, .. }) => {
        guard let Some({ pad, code, .. }) = lines.pop()
        blanks.push(BlockStruct::BlankLine(pad, code))
      }
      None => break // Likely `abort()`
      Some(_) => {
        bs.push(CodeBlock(Indented(lines)))
        break
      }
    }
  }
  bs.push_iter(blanks.iter())
}

// Closing blocks and finishing the document.

///|
fn Parser::close_paragraph(
  self : Parser,
  par : Paragraph,
  bs : Array[BlockStruct]
) -> Unit {
  guard par.maybe_ref else {
    bs.push(Paragraph(par))
    return
  }
  self.maybe_add_link_ref_definitions(par.lines, bs)
}

///|
fn Parser::close_last_block(self : Parser, bs : Array[BlockStruct]) -> Unit {
  match bs.pop() {
    Some(CodeBlock(Indented(ls))) => self.close_indented_code_block(ls, bs)
    Some(Paragraph(par)) => self.close_paragraph(par, bs)
    Some(List(l)) => self.close_list(l, bs)
    Some(ExtFootnote(i, l, blocks)) => self.close_footnote(i, l, blocks, bs)
    Some(t) => bs.push(t)
    None => ()
  }
}

///|
fn Parser::close_list(
  self : Parser,
  l : ListBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  guard let Some(i) = l.items.last()
  let blocks = i.blocks
  self.close_last_block(blocks)
  // The final blank line extraction of the list item entails less blank
  // line churn for CommonMark rendering but we don't do it on empty list items.
  match blocks {
    [.., _, BlankLine(_, _)] => {
      guard let Some(bl) = blocks.pop()
      let items = l.items
      items[items.length() - 1] = { ..i, blocks, }
      bs..push(List({ ..l, items, })).push(bl)
    }
    _ => {
      let items = l.items
      items[items.length() - 1] = { ..i, blocks, }
      bs.push(List({ ..l, items, }))
    }
  }
}

///|
fn Parser::close_footnote(
  self : Parser,
  indent : Indent,
  label : (Label, Label?),
  blocks : Array[BlockStruct],
  bs : Array[BlockStruct]
) -> Unit {
  self.close_last_block(blocks)
  // Like for lists above we do blank line extraction (except if blocks is only a blank line)
  let blanks = []
  for {
    match blocks {
      [.., _, BlankLine(_, _)] => {
        guard let Some(bl) = blocks.pop()
        blanks.push(bl)
      }
      _ => break
    }
  }
  bs.push(ExtFootnote(indent, label, blocks))
  bs.push_iter(blanks.iter())
}

///|
fn Parser::close_last_list_item(self : Parser, l : ListBlockStruct) -> Unit {
  guard let Some(item) = l.items.last()
  self.close_last_block(item.blocks)
}

///|
fn Parser::end_doc_close_fenced_code_block(
  self : Parser,
  fenced : FenceCodeBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  let _ = self
  let { code, .. } = fenced
  guard code.is_empty() else {
    guard let Some((_, { first, last, .. } as l)) = code.pop()
    if first > last { // Empty line
      bs..push(BlankLine(0, l)).push(CodeBlock(Fenced({ ..fenced, code, })))
      return
    }
  }
  bs.push(CodeBlock(Fenced(fenced)))
}

///|
fn Parser::end_doc_close_html(
  self : Parser,
  h : HtmlBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  let _ = self
  let { html, .. } = h
  guard html.is_empty() else {
    guard let Some({ first, last, .. } as l) = html.pop()
    if first > last { // Empty line
      bs..push(HtmlBlock({ end_cond: None, html })).push(BlankLine(0, l))
      return
    }
  }
  bs.push(HtmlBlock({ ..h, end_cond: None }))
}

///|
fn Parser::end_doc(self : Parser, bs : Array[BlockStruct]) -> Unit {
  match bs.pop() {
    Some(BlockQuote(indent, bq)) => {
      self.end_doc(bq)
      bs.push(BlockQuote(indent, bq))
    }
    Some(List(l)) => self.close_list(l, bs)
    Some(Paragraph(par)) => self.close_paragraph(par, bs)
    Some(CodeBlock(Indented(ls))) => self.close_indented_code_block(ls, bs)
    Some(CodeBlock(Fenced(f))) => self.end_doc_close_fenced_code_block(f, bs)
    Some(HtmlBlock(html)) => self.end_doc_close_html(html, bs)
    Some(ExtFootnote(indent, label, blocks)) =>
      self.close_footnote(indent, label, blocks, bs)
    Some(b) => bs.push(b)
    None => ()
  }
}

// Adding lines to blocks

///| Effects on [p]'s column advance
fn Parser::match_line_type(
  self : Parser,
  no_setext~ : Bool,
  indent~ : SpacePad
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
        last~,
        start~,
      ) else {
        r => return r
      }
      ParagraphLine
    }
    ('-', no_setext, _) => {
      guard let Nomatch = (if no_setext {
        LineType::Nomatch
      } else {
        LineType::setext_heading_underline(self.i, last~, start~)
      }) else {
        r => return r
      }
      guard let Nomatch = LineType::thematic_break(self.i, last~, start~) else {
        r => return r
      }
      guard let Nomatch = LineType::list_marker(self.i, last~, start~) else {
        r => return r
      }
      ParagraphLine
    }
    ('#', _, _) => {
      guard let Nomatch = LineType::atx_heading(self.i, last~, start~) else {
        r => return r
      }
      ParagraphLine
    }
    ('+' | '*' | '0'..='9', _, _) => {
      guard let Nomatch = LineType::thematic_break(self.i, last~, start~) else {
        r => return r
      }
      let r = LineType::list_marker(self.i, last~, start~)
      guard let Nomatch = r else { r => return r }
      ParagraphLine
    }
    ('_', _, _) => {
      guard let Nomatch = LineType::thematic_break(self.i, last~, start~) else {
        r => return r
      }
      ParagraphLine
    }
    ('~' | '`', _, _) => {
      guard let Nomatch = LineType::fenced_code_block_start(
        self.i,
        last~,
        start~,
      ) else {
        r => return r
      }
      ParagraphLine
    }
    ('<', _, _) => {
      guard let Nomatch = LineType::html_block_start(self.i, last~, start~) else {
        r => return r
      }
      ParagraphLine
    }
    ('|', _, true) => {
      guard let Nomatch = LineType::ext_table_row(self.i, last~, start~) else {
        r => return r
      }
      ParagraphLine
    }
    ('[', _, true) => {
      guard let Nomatch = LineType::ext_footnote_label(
        self.buf,
        self.i,
        line_pos=self.curr_line_pos,
        last~,
        start~,
      ) else {
        r => return r
      }
      ParagraphLine
    }
    _ => ParagraphLine
  }
}

///|
fn Parser::list_marker_can_interrupt_paragraph(
  self : Parser,
  marker : ListType,
  marker_last : BytePos
) -> Bool {
  guard let Ordered(1, _) | Unordered(_) = marker else { _ => return false }
  let non_blank = @cmark_base.first_non_blank(
    self.i,
    last=self.curr_line_last_char,
    start=marker_last + 1,
  )
  non_blank <= self.curr_line_last_char // Line is not blank
}

///|
fn Parser::add_open_blocks_with_line_class(
  self : Parser,
  indent_start~ : Indent,
  indent~ : Indent,
  bs : Array[BlockStruct],
  lt : LineType
) -> Unit {
  match lt {
    BlankLine => bs.push(self.blank_line())
    IndentedCodeBlockLine => bs.push(self.indented_code_block())
    BlockQuoteLine => {
      let bs1 = []
      self.add_open_blocks(bs1)
      bs.push(BlockQuote(indent, bs1))
    }
    ThematicBreakLine(last) => bs.push(self.thematic_break(indent~, last~))
    ListMarkerLine(marker, marker_last) =>
      self.list(indent~, marker, marker_last, bs)
    AtxHeadingLine(level, after_open, first_content, last_content) =>
      bs.push(
        self.atx_heading(
          indent~,
          level~,
          after_open~,
          first_content~,
          last_content~,
        ),
      )
    FencedCodeBlockLine(fence_first, fence_last, info) =>
      bs.push(self.fenced_code_block(indent~, fence_first~, fence_last~, info~))
    HtmlBlockLine(end_cond) =>
      bs.push(self.html_block(end_cond~, indent_start~))
    ParagraphLine => bs.push(self.paragraph(start=indent_start))
    ExtTableRow(last) => bs.push(self.table(indent~, last~))
    ExtFootnoteLabel(spans, last, key) =>
      bs.push(self.footnote(indent~, last~, spans=spans[:], key~))
    _ => abort("unimplemented")
  }
}

///|
fn Parser::add_open_blocks(self : Parser, bs : Array[BlockStruct]) -> Unit {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  let line_type = self.match_line_type(no_setext=true, indent~)
  self.add_open_blocks_with_line_class(indent_start~, indent~, bs, line_type)
}

///|
fn Parser::footnote(
  self : Parser,
  indent~ : Indent,
  last~ : BytePos,
  spans~ : ArrayView[Span],
  key~ : String
) -> BlockStruct {
  let label = label_of_spans(self, key~, spans)
  let defined_label = self.def_label(label)
  for def in defined_label {
    self.set_label_def(def, Label::stub(label, defined_label))
  }
  self.accept_cols(count=last - self.curr_char + 1)
  let blocks = []
  self.add_open_blocks(blocks)
  ExtFootnote(indent, (label, defined_label), blocks)
}

///|
fn Parser::list_item(
  self : Parser,
  indent~ : Indent,
  _list_type : ListType,
  last : BytePos
) -> (Indent, ListItemStruct) {
  let before_marker = indent
  let marker_size = last - self.curr_char + 1
  let marker = self.curr_line_span(first=self.curr_char, last~)
  let after_marker = self.accept_list_marker_and_indent(marker_size~, last~)
  let (ext_task_marker, ext_task_marker_size) = if self.exts {
    let start = self.curr_char
    let last = self.curr_line_last_char
    match @cmark_base.ext_task_marker(self.i, last~, start~) {
      None => (None, 0)
      Some((u, last)) => {
        self.accept_cols(count=last - start + 1)
        let last = if last == self.curr_line_last_char {
          last
        } else {
          last - 1
        }
        (Some((u, self.curr_line_span(first=start, last~))), 4)
      }
    }
  } else {
    (None, 0)
  }
  let min = indent + marker_size + after_marker + ext_task_marker_size
  let blocks = []
  self.add_open_blocks(blocks)
  (min, { before_marker, marker, after_marker, ext_task_marker, blocks })
}

///|
fn Parser::list(
  self : Parser,
  indent~ : Indent,
  list_type : ListType,
  marker_last : BytePos,
  bs : Array[BlockStruct]
) -> Unit {
  let (item_min_indent, item) = self.list_item(indent~, list_type, marker_last)
  bs.push(
    List({
      last_blank: false,
      loose: false,
      item_min_indent,
      list_type,
      items: [item],
    }),
  )
}

///|
fn Parser::try_add_to_list(
  self : Parser,
  indent~ : Indent,
  list_type : ListType,
  marker_last : BytePos,
  list : ListBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  let (item_min_indent, item) = self.list_item(indent~, list_type, marker_last)
  if list.list_type.is_same_type(list_type) {
    let l = list
    self.close_last_list_item(l)
    bs.push(
      List({
        last_blank: false,
        loose: l.last_blank,
        item_min_indent,
        list_type: l.list_type,
        items: l.items..push(item),
      }),
    )
  } else {
    self.close_list(list, bs)
    bs.push(
      List({
        last_blank: false,
        loose: false,
        item_min_indent,
        list_type,
        items: [item],
      }),
    )
  }
}

///|
fn Parser::try_add_to_paragraph(
  self : Parser,
  par : Paragraph,
  bs : Array[BlockStruct]
) -> Unit {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  match self.match_line_type(no_setext=false, indent~) {
    // These can't interrupt paragraphs
    HtmlBlockLine(HtmlBlockEndCond::EndBlank7)
    | IndentedCodeBlockLine
    | ExtTableRow(_)
    | ExtFootnoteLabel(_)
    | ParagraphLine => self.add_paragraph_line(indent_start~, par~, bs~)
    ListMarkerLine(marker, marker_last) =>
      if self.list_marker_can_interrupt_paragraph(marker, marker_last) {
        self.close_paragraph(par, bs)
        self.list(indent~, marker, marker_last, bs)
      } else {
        self.add_paragraph_line(indent_start~, par~, bs~)
      }
    BlankLine => {
      self.close_paragraph(par, bs)
      bs.push(self.blank_line())
    }
    BlockQuoteLine => {
      self.close_paragraph(par, bs)
      let blocks = []
      self.add_open_blocks(blocks)
      bs.push(BlockQuote(indent, blocks))
    }
    SetextUnderlineLine(level, last_underline) => {
      self.close_paragraph(par, bs)
      match bs {
        [.., Paragraph(par)] =>
          bs[bs.length() - 1] = self.setext_heading(
            indent~,
            level~,
            last_underline~,
            par.lines,
          )
        bs => bs.push(self.paragraph(start=indent_start))
      }
    }
    ThematicBreakLine(last) => {
      self.close_paragraph(par, bs)
      bs.push(self.thematic_break(indent~, last~))
    }
    AtxHeadingLine(level, after_open, first_content, last_content) => {
      self.close_paragraph(par, bs)
      bs.push(
        self.atx_heading(
          indent~,
          level~,
          after_open~,
          first_content~,
          last_content~,
        ),
      )
    }
    FencedCodeBlockLine(fence_first, fence_last, info) => {
      self.close_paragraph(par, bs)
      bs.push(self.fenced_code_block(indent~, fence_first~, fence_last~, info~))
    }
    HtmlBlockLine(end_cond) => {
      self.close_paragraph(par, bs)
      bs.push(self.html_block(end_cond~, indent_start~))
    }
    Nomatch => abort("unreachable")
  }
}

///|
fn Parser::try_add_to_indented_code_block(
  self : Parser,
  ls : Array[IndentedCodeLine],
  bs : Array[BlockStruct]
) -> Unit {
  if self.curr_indent() < 4 {
    if self.has_next_non_blank() {
      self.close_indented_code_block(ls, bs)
      self.add_open_blocks(bs)
    } else {
      // Blank but white is not data, make an empty span
      let first = self.curr_line_last_char + 1
      let last = self.curr_line_last_char
      let code = self.curr_line_span(first~, last~)
      let l = { pad: 0, code, is_blank: true }
      bs.push(CodeBlock(Indented(ls..push(l))))
    }
  } else {
    let (pad, first) = self.accept_code_indent(count=4)
    let last = self.curr_line_last_char
    let is_blank = self.only_blanks()
    let l = { pad, code: self.curr_line_span(first~, last~), is_blank }
    bs.push(CodeBlock(Indented(ls..push(l))))
  }
}

///|
fn Parser::try_add_to_fenced_code_block(
  self : Parser,
  f : FenceCodeBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  match f {
    { fence: { closing_fence: Some(_), .. }, .. } => // Block is closed
      self.add_open_blocks(bs..push(CodeBlock(Fenced(f))))
    { fence: { indent, fence, .. }, code: ls } as b => {
      let start = self.curr_char
      let last = self.curr_line_last_char
      match
        @cmark_base.FencedCodeBlockContinue::new(self.i, fence~, last~, start~) {
        Code => {
          let strip = @math.minimum(indent, self.curr_indent())
          let (pad, first) = self.accept_code_indent(count=strip)
          let code = ls..push((pad, self.curr_line_span(first~, last~)))
          bs.push(CodeBlock(Fenced({ ..b, code, })))
        }
        Close(first, _fence_last) => {
          let close = self.curr_line_span(first~, last~) // With layout
          let fence = { ..b.fence, closing_fence: Some(close) }
          bs.push(CodeBlock(Fenced({ ..b, fence, })))
        }
      }
    }
  }
}

///|
fn Parser::try_add_to_html_block(
  self : Parser,
  b : HtmlBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  match b.end_cond {
    None => self.add_open_blocks(bs..push(HtmlBlock({ ..b, end_cond: None })))
    Some(end_cond) => {
      let start = self.curr_char
      let last = self.curr_line_last_char
      let l = self.curr_line_span(first=start, last~)
      if LineType::html_block_end(self.i, end_cond~, last~, start~) {
        match end_cond {
          EndBlank7 | EndBlank =>
            bs..push(HtmlBlock({ ..b, end_cond: None })).push(self.blank_line())
          _ => bs.push(HtmlBlock({ html: b.html..push(l), end_cond: None }))
        }
      } else {
        bs.push(HtmlBlock({ ..b, html: b.html..push(l) }))
      }
    }
  }
}

///|
fn Parser::try_lazy_continuation(
  self : Parser,
  indent_start~ : Indent,
  bs : Array[BlockStruct]
) -> Bool {
  match bs.last() {
    Some(Paragraph(par)) => {
      let _ = bs.pop()
      self.add_paragraph_line(indent_start~, par~, bs~)
      true
    }
    Some(BlockQuote(_, bq)) => self.try_lazy_continuation(indent_start~, bq)
    Some(List(l)) => {
      guard let Some(i) = l.items.last()
      let res = self.try_lazy_continuation(indent_start~, i.blocks)
      if res {
        l.last_blank = false
      }
      res
    }
    _ => false
  }
}

///|
fn Parser::try_add_to_table(
  self : Parser,
  indent : Indent,
  rows : Array[(LineSpan, LineSpan)],
  bs : Array[BlockStruct]
) -> Unit {
  let indent_start = self.curr_char
  let curr_indent = self.curr_indent()
  match self.match_line_type(no_setext=true, indent=curr_indent) {
    ExtTableRow(last) => {
      let row = self.table_row(first=self.curr_char, last~)
      bs.push(ExtTable(indent, rows..push(row)))
    }
    lt => {
      bs.push(ExtTable(indent, rows))
      self.add_open_blocks_with_line_class(
        indent_start~,
        indent=curr_indent,
        bs,
        lt,
      )
    }
  }
}

///|
fn Parser::try_add_to_block_quote(
  self : Parser,
  indent_layout : Indent,
  bq : Array[BlockStruct],
  bs : Array[BlockStruct]
) -> Unit {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  match self.match_line_type(no_setext=true, indent~) {
    BlockQuoteLine => {
      self.add_line(bq)
      bs.push(BlockQuote(indent_layout, bq))
    }
    IndentedCodeBlockLine | ParagraphLine as ltype =>
      if self.try_lazy_continuation(indent_start~, bq) {
        bs.push(BlockQuote(indent_layout, bq))
      } else {
        self.close_last_block(bq)
        bs.push(BlockQuote(indent_layout, bq))
        self.add_open_blocks_with_line_class(indent_start~, indent~, bs, ltype)
      }
    lt => {
      self.close_last_block(bq)
      bs.push(BlockQuote(indent_layout, bq))
      self.add_open_blocks_with_line_class(indent_start~, indent~, bs, lt)
    }
  }
}

///|
fn Parser::try_add_to_footnote(
  self : Parser,
  fn_indent : Indent,
  label : (Label, Label?),
  blocks : Array[BlockStruct],
  bs : Array[BlockStruct]
) -> Unit {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  if indent < fn_indent + 1 { // Position of ^
    match self.match_line_type(no_setext=true, indent~) {
      IndentedCodeBlockLine | ParagraphLine as lt =>
        if self.try_lazy_continuation(indent_start~, blocks) {
          bs.push(ExtFootnote(fn_indent, label, blocks))
        } else {
          self.close_last_block(blocks)
          self.close_footnote(fn_indent, label, blocks, bs)
          self.add_open_blocks_with_line_class(indent_start~, indent~, bs, lt)
        }
      BlankLine => {
        self.add_line(blocks)
        bs.push(ExtFootnote(fn_indent, label, blocks))
      }
      lt => {
        self.close_footnote(fn_indent, label, blocks, bs)
        self.add_open_blocks_with_line_class(indent_start~, indent~, bs, lt)
      }
    }
  } else {
    self.accept_cols(count=fn_indent + 1)
    self.add_line(blocks)
    bs.push(ExtFootnote(fn_indent, label, blocks))
  }
}

///|
fn Parser::try_add_to_list_item(
  self : Parser,
  list : ListBlockStruct,
  bs : Array[BlockStruct]
) -> Unit {
  let indent_start = self.curr_char
  let indent = self.curr_indent()
  if indent >= list.item_min_indent {
    let last_blank = self.only_blanks()
    guard let Some(item) = list.items.last()
    return if list.last_blank &&
      not(last_blank) &&
      item.blocks.iter().all(is_blank_line) {
      // Item can only start with a single blank line, 
      // if we are here it's not a new item so the list ends
      self.add_open_blocks(bs..push(List(list)))
    } else {
      self.accept_cols(count=list.item_min_indent)
      self.add_line(item.blocks)
      bs.push(List({ ..list, last_blank, }))
    }
  }
  match self.match_line_type(no_setext=true, indent~) {
    BlankLine => {
      let items = list.items
      guard let Some(item) = items.last()
      self.add_line(item.blocks)
      bs.push(List({ ..list, items, last_blank: true }))
    }
    IndentedCodeBlockLine | ParagraphLine as ltype => {
      let items = list.items
      guard let Some(item) = items.last()
      if self.try_lazy_continuation(indent_start~, item.blocks) {
        bs.push(List({ ..list, items, last_blank: false }))
      } else {
        self.close_list(list, bs)
        self.add_open_blocks_with_line_class(indent_start~, indent~, bs, ltype)
      }
    }
    ListMarkerLine(marker, marker_last) =>
      self.try_add_to_list(indent~, marker, marker_last, list, bs)
    lt => {
      self.close_list(list, bs)
      self.add_open_blocks_with_line_class(indent_start~, indent~, bs, lt)
    }
  }
}

///|
fn Parser::add_line(self : Parser, bs : Array[BlockStruct]) -> Unit {
  match bs.last() {
    Some(Paragraph(par)) => {
      let _ = bs.pop()
      self.try_add_to_paragraph(par, bs)
    }
    Some(ThematicBreak(_) | Heading(_) | BlankLine(_) | LinkRefDef(_)) | None =>
      self.add_open_blocks(bs)
    Some(List(l)) => {
      let _ = bs.pop()
      self.try_add_to_list_item(l, bs)
    }
    Some(CodeBlock(Indented(ls))) => {
      let _ = bs.pop()
      self.try_add_to_indented_code_block(ls, bs)
    }
    Some(CodeBlock(Fenced(f))) => {
      let _ = bs.pop()
      self.try_add_to_fenced_code_block(f, bs)
    }
    Some(BlockQuote(indent, bq)) => {
      let _ = bs.pop()
      self.try_add_to_block_quote(indent, bq, bs)
    }
    Some(HtmlBlock(html)) => {
      let _ = bs.pop()
      self.try_add_to_html_block(html, bs)
    }
    Some(ExtTable(indent, rows)) => {
      let _ = bs.pop()
      self.try_add_to_table(indent, rows, bs)
    }
    Some(ExtFootnote(i, l, blocks)) => {
      let _ = bs.pop()
      self.try_add_to_footnote(i, l, blocks, bs)
    }
  }
}

///|
fn Parser::get_first_line(self : Parser) -> String {
  let max = self.i.length() - 1
  let mut k = 0
  let last_char = while k <= max && self.i[k] != '\r' && self.i[k] != '\n' {
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

///|
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
                      k <= max && self.i[k] != '\r' && self.i[k] != '\n'
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

///|
fn Parser::parse_block(self : Parser) -> (String, Node[Array[BlockStruct]]) {
  fn meta() {
    self.meta({
      file: self.file,
      first_byte: 0,
      last_byte: self.curr_line_last_char,
      first_line: (1, 0),
      last_line: self.curr_line_pos,
    })
  }

  let nl = self.get_first_line()
  let blocks = loop [] {
    bs => {
      self.add_line(bs)
      if self.get_next_line() {
        continue bs
      }
      self.end_doc(bs)
      { v: bs, meta: meta() }
    }
  }
  (nl, blocks)
}

// Building the final AST, invokes inline parsing.

///|
fn Parser::block_struct_to_blank_line(
  self : Parser,
  pad : Indent,
  span : LineSpan
) -> Block {
  BlankLine(self.clean_raw_span(pad~, span))
}

///|
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
      let last = ls.last().unwrap().code
      let code = ls.map(line)
      let meta = {
        let last_line = last.pos
        let last_byte = last.last
        let start = code[0].meta.loc
        self.meta({ ..start, last_byte, last_line })
      }
      CodeBlock({ v: { layout, info_string, code }, meta })
    }
    Fenced({ fence, code: ls }) => {
      let layout = {
        let opening_fence = self.layout_clean_raw_span(fence.opening_fence)
        let closing_fence = fence.closing_fence.map(fn(i) {
          self.layout_clean_raw_span(i)
        })
        { indent: fence.indent, opening_fence, closing_fence }
      }
      let info_string = fence.info_string.map(fn(i) {
        self.clean_unesc_unref_span(i)
      })
      let code = ls.map(fn(i) { self.clean_raw_span(pad=i.0, i.1) })
      let meta = {
        let first = fence.opening_fence
        let last = match fence.closing_fence {
          Some(last) => last
          None =>
            match ls.last() {
              Some((_, last)) => last
              None => first
            }
        }
        self.meta_of_spans(first~, last~)
      }
      let cb = { layout: Fenced(layout), info_string, code }
      if self.exts && CodeBlock::is_math_block(info_string.map(fn(i) { i.v })) {
        return ExtMathBlock({ v: cb, meta })
      }
      CodeBlock({ v: cb, meta })
    }
  }
}

///|
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
      let (_, inline) = self.parse_inline([heading])
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

///|
fn Parser::block_struct_to_html_block(
  self : Parser,
  b : HtmlBlockStruct
) -> Block {
  guard let Some({ last: last_byte, pos: last_line, .. }) = b.html.last()
  let lines = b.html.map(fn(i) { self.clean_raw_span(i) })
  let start_loc = lines.last().unwrap().meta.loc
  let meta = self.meta({ ..start_loc, last_byte, last_line })
  HtmlBlock({ v: Seq::from_array(lines), meta })
}

///|
fn Parser::block_struct_to_paragraph(self : Parser, par : Paragraph) -> Block {
  let (layout, inline) = self.parse_inline(par.lines)
  let (leading_indent, trailing_blanks) = layout
  let meta = inline.meta()
  Paragraph({ v: { leading_indent, inline, trailing_blanks }, meta })
}

///|
fn Parser::block_struct_to_thematic_break(
  self : Parser,
  indent : Indent,
  span : LineSpan
) -> Block {
  let { v: layout, meta } = self.clean_raw_span(span) // No layout because of loc
  ThematicBreak({ v: { indent, layout }, meta })
}

///|
fn Parser::block_struct_to_table(
  self : Parser,
  indent : Indent,
  rows : Array[(LineSpan, LineSpan)]
) -> Block {
  guard let Some((last, _)) = rows.last()
  let (first, col_count, rows) = loop 0, false, [], rows[:] {
    col_count, last_was_sep, acc, [.. rs, (row, blanks)] => {
      let meta = self.meta(self.text_loc_of_span(row))
      let row1 = { ..row, first: row.first + 1, last: row.last }
      let cols = self.parse_table_row(row1)
      let col_count = @math.maximum(col_count, cols.length())
      let (r, last_was_sep) = match Table::parse_sep_row(cols[:]) {
        Some(seps) => ({ v: Sep(seps), meta }, true)
        None => {
          let v = if last_was_sep { Header(cols) } else { Data(cols) }
          ({ v, meta }, false)
        }
      }
      let acc = acc..push((r, self.layout_clean_raw_span1(blanks)))
      guard rs.length() != 0 else { break (row, col_count, acc) }
      continue col_count, last_was_sep, acc, rs
    }
    _, _, _, [] => abort("unreachable")
  }
  rows.rev_inplace()
  let meta = self.meta_of_spans(first~, last~)
  ExtTable({ v: { indent, col_count, rows }, meta })
}

///|
fn Parser::block_struct_to_block_quote(
  self : Parser,
  indent : Indent,
  bs : Array[BlockStruct]
) -> Block {
  let acc = bs.map(fn(b) { self.block_struct_to_block(b) })
  let block = match acc {
    [b] => b
    quote => {
      let first = quote[0].meta()
      let last = quote.last().unwrap().meta()
      let meta = self.meta_of_metas(first~, last~)
      Blocks({ v: quote, meta })
    }
  }
  BlockQuote({ v: { indent, block }, meta: block.meta() })
}

///|
fn Parser::block_struct_to_footnote_definition(
  self : Parser,
  indent : Indent,
  label : Label,
  defined_label : Label?,
  bs : Array[BlockStruct]
) -> Block {
  let block = bs.map(fn(b) { self.block_struct_to_block(b) })
  let last = block.last().unwrap().meta()
  let block = match block {
    [b] => b
    blocks => {
      let first = blocks[0].meta()
      let meta = self.meta_of_metas(first~, last~)
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
  for def in defined_label {
    self.set_label_def(def, FootnoteDef(footnote))
  }
  ExtFootnoteDefinition(footnote)
}

///|
enum BState {
  Blank
  TrailBlank
  NonBlank
} derive(Eq)

///|
fn Parser::block_struct_to_list_item(
  self : Parser,
  i : ListItemStruct
) -> (Node[ListItem], Bool) {
  fn go(bstate : BState, tight, acc : Array[_], bs : ArrayView[BlockStruct]) {
    loop bstate, tight, acc, bs {
      bstate, tight, acc, [BlankLine(_) as bl, .. bs] => {
        let bstate = if bstate == TrailBlank { TrailBlank } else { Blank }
        continue bstate, tight, acc..push(self.block_struct_to_block(bl)), bs
      }
      bstate,
      _,
      acc,
      [
        List({ items: [.., { blocks: [.., BlankLine(_)], .. }], .. }) as l,
        .. bs,
      ] => continue bstate, false, acc..push(self.block_struct_to_block(l)), bs
      bstate, tight, acc, [b, .. bs] => {
        let tight = tight && bstate != Blank
        continue NonBlank, tight, acc..push(self.block_struct_to_block(b)), bs
      }
      _, tight, acc, [] => (tight, acc)
    }
  }

  let (last_meta, (tight, blocks)) = match i.blocks[:] {
    [BlankLine(_) as blank] => {
      let bl = self.block_struct_to_block(blank)
      (bl.meta(), (true, [bl]))
    }
    [BlankLine(_) as blank, .. bs] => {
      let bl = self.block_struct_to_block(blank)
      (bl.meta(), go(TrailBlank, true, [bl], bs))
    }
    [b, .. bs] => {
      let b = self.block_struct_to_block(b)
      (b.meta(), go(NonBlank, true, [b], bs))
    }
    [] => abort("unreachable")
  }
  let block = match blocks {
    [i] => i
    blocks => {
      let first = blocks[0].meta()
      Blocks({ v: blocks, meta: self.meta_of_metas(first~, last=last_meta) })
    }
  }
  let before_marker = i.before_marker
  let after_marker = i.after_marker
  let marker = self.clean_raw_span(i.marker)
  let ext_task_marker = i.ext_task_marker.map(fn {
    (v, span) => { v, meta: self.meta(self.text_loc_of_span(span)) }
  })
  let v = { before_marker, marker, after_marker, block, ext_task_marker }
  let meta = self.meta_of_metas(first=marker.meta, last=last_meta)
  ({ v, meta }, tight)
}

///|
fn Parser::block_struct_to_list(self : Parser, list : ListBlockStruct) -> Block {
  let items = list.items
  let (first, tight) = self.block_struct_to_list_item(items[0])
  let (tight, items) = loop not(list.loose) && tight, [first], items[1:] {
    tight, acc, [] => (tight, acc)
    tight, acc, [item, .. items] => {
      let (item, item_tight) = self.block_struct_to_list_item(item)
      continue tight && item_tight, acc..push(item), items
    }
  }
  let meta = self.meta_of_metas(
    first=first.meta,
    last=items.last().unwrap().meta,
  )
  List({ v: { ty: list.list_type, tight, items }, meta })
}

///|
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
    ExtTable(i, rows) => self.block_struct_to_table(i, rows)
    ExtFootnote(i, (lb, dlb), bs) =>
      self.block_struct_to_footnote_definition(i, lb, dlb, bs)
  }
}

///|
fn Parser::block_struct_to_doc(
  self : Parser,
  doc : Node[Array[BlockStruct]]
) -> Block {
  let { v: doc, meta } = doc
  match doc.map(fn(b) { self.block_struct_to_block(b) }) {
    [b] => b
    bs => Blocks({ v: bs, meta })
  }
}

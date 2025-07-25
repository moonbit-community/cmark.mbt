///|
priv struct Parser {
  /// Input file.
  file : FilePath
  /// Input string.
  i : String
  /// Scratch buffer.
  buf : Buffer
  /// Whether extensions are enabled.
  exts : Bool
  /// Don't compute locations.
  no_locs : Bool
  /// Don't compute layouts.
  no_layouts : Bool
  /// Compute heading IDs.
  heading_auto_ids : Bool
  nested_links : Bool
  defs : LabelDefs
  resolver : LabelResolverFn
  /// Current `CloserIndex`, for inline parsing.
  mut cidx : CloserIndex
  /// Current line, only used during block parsing.
  mut curr_line_pos : LinePos
  /// First char of line - 1 on empty lines.
  mut curr_line_last_char : CharCodePos
  mut curr_char : CharCodePos
  mut curr_char_col : Col
  /// `curr_line_last_char + 1` if none.
  mut next_non_blank : CharCodePos
  mut next_non_blank_col : Col

  // Number of cols consumed from tab if i[curr_char] = '\t'.
  mut tab_consumed_cols : Col
}

///|
fn Parser::new(
  defs~ : LabelDefs = LabelDefs::new(),
  resolver~ : LabelResolverFn = LabelContext::default_resolver,
  nested_links~ : Bool = false,
  heading_auto_ids~ : Bool = false,
  layout~ : Bool = false,
  locs~ : Bool = false,
  file~ : FilePath = file_path_none,
  strict~ : Bool = true,
  i : String,
) -> Parser {
  {
    file,
    i,
    buf: Buffer::new(size_hint=512),
    no_locs: not(locs),
    no_layouts: not(layout),
    exts: not(strict),
    heading_auto_ids,
    nested_links,
    defs,
    resolver,
    cidx: CloserIndex::new(),
    curr_line_pos: (1, 0),
    curr_line_last_char: -1,
    curr_char: 0,
    curr_char_col: 0,
    next_non_blank: 0,
    next_non_blank_col: 0,
    tab_consumed_cols: 0,
  }
}

///|
fn Parser::find_label_defining_key(self : Parser, key : String) -> Label? {
  match self.defs.get(key) {
    Some(LinkDef(ld)) => ld.v.defined_label
    Some(FootnoteDef(ld)) => ld.v.defined_label
    None => None
  }
}

///|
fn Parser::set_label_def(self : Parser, l : Label, def : LabelDef) -> Unit {
  self.defs[l.key] = def
}

///|
fn Parser::def_label(self : Parser, l : Label) -> Label? {
  (self.resolver)(Def(self.find_label_defining_key(l.key), l))
}

///|
fn Parser::find_def_for_ref(
  self : Parser,
  image~ : Bool,
  ref_ : Label,
) -> Label? {
  let kind : LinkKind = if image { Image } else { Link }
  let def = self.find_label_defining_key(ref_.key)
  (self.resolver)(Ref(kind, ref_, def))
}

// fn Parser::debug_span(self : Parser, s : LineSpan) -> String {
//   self.i.substring(start=s.first, end=s.last + 1)
// }

// fn Parser::debug_line(self : Parser) -> String {
//   self.i.substring(start=self.curr_line_pos.1, end=self.curr_line_last_char)
// }

///|
fn Parser::curr_line_span(
  self : Parser,
  first~ : CharCodePos,
  last~ : CharCodePos,
) -> LineSpan {
  { first, last, pos: self.curr_line_pos }
}

// Making metas and text locations. This is centralized here to be able
// to disable their creation which has a non-negligible impact on
// performance.

///|
fn Parser::meta(self : Parser, loc : TextLoc) -> Meta {
  if self.no_locs {
    return Meta::none()
  }
  Meta::new(loc~)
}

///|
fn Parser::text_loc_of_span(self : Parser, span : LineSpan) -> TextLoc {
  if self.no_locs {
    return TextLoc::none()
  }
  {
    file: self.file,
    first_ccode: span.first,
    last_ccode: span.last,
    first_line: span.pos,
    last_line: span.pos,
  }
}

///|
fn Parser::text_loc_of_lines(
  self : Parser,
  first~ : CharCodePos,
  last~ : CharCodePos,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
) -> TextLoc {
  if self.no_locs {
    return TextLoc::none()
  }
  {
    file: self.file,
    first_ccode: first,
    last_ccode: last,
    first_line: first_line.pos,
    last_line: last_line.pos,
  }
}

///|
fn Parser::meta_of_spans(
  self : Parser,
  first~ : LineSpan,
  last~ : LineSpan,
) -> Meta {
  if self.no_locs {
    return Meta::none()
  }
  self.meta(
    self.text_loc_of_lines(
      first_line=first,
      last_line=last,
      first=first.first,
      last=last.last,
    ),
  )
}

///|
fn Parser::meta_of_metas(self : Parser, first~ : Meta, last~ : Meta) -> Meta {
  if self.no_locs {
    return Meta::none()
  }
  self.meta(first.loc.span(last.loc))
}

///|
fn Parser::clean_raw_span(
  self : Parser,
  pad~ : Int = 0,
  span : LineSpan,
) -> StringNode {
  {
    v: @char.utf_16_clean_raw(
      pad~,
      self.buf,
      self.i,
      first=span.first,
      last=span.last,
    ),
    meta: self.meta(self.text_loc_of_span(span)),
  }
}

///|
fn Parser::clean_unref_span(self : Parser, span : LineSpan) -> StringNode {
  {
    v: @char.utf_16_clean_unref(
      self.buf,
      self.i,
      first=span.first,
      last=span.last,
    ),
    meta: self.meta(self.text_loc_of_span(span)),
  }
}

///|
fn Parser::clean_unesc_unref_span(self : Parser, span : LineSpan) -> StringNode {
  {
    v: @char.utf_16_clean_unesc_unref(
      self.buf,
      self.i,
      first=span.first,
      last=span.last,
    ),
    meta: self.meta(self.text_loc_of_span(span)),
  }
}

///|
fn Parser::layout_clean_raw_span(
  self : Parser,
  pad~ : Int = 0,
  span : LineSpan,
) -> StringNode {
  if self.no_layouts {
    return layout_empty
  }
  {
    meta: self.meta(self.text_loc_of_span(span)),
    v: self.layout_clean_raw_span1(pad~, span),
  }
}

///|
fn Parser::layout_clean_raw_span1(
  self : Parser,
  pad~ : Int = 0,
  span : LineSpan,
) -> String {
  if self.no_layouts {
    return ""
  }
  @char.utf_16_clean_raw(
    pad~,
    self.buf,
    self.i,
    first=span.first,
    last=span.last,
  )
}

///|
fn Parser::tight_block_lines(
  self : Parser,
  spans~ : ArrayView[Span],
) -> Array[Tight] {
  self._tight_block_lines(Parser::clean_unesc_unref_span, spans~)
}

///|
fn Parser::raw_tight_block_lines(
  self : Parser,
  spans~ : ArrayView[Span],
) -> Array[Tight] {
  self._tight_block_lines(fn(p, s) { p.clean_raw_span(s) }, spans~)
}

///|
priv type ParserCleanSpanFn (Parser, LineSpan) -> StringNode

///|
fn Parser::_tight_block_lines(
  self : Parser,
  f : ParserCleanSpanFn,
  spans~ : ArrayView[Span],
) -> Array[Tight] {
  let acc = []
  for i, span in spans {
    match (span, i) {
      ({ span: fst_ln, .. }, 0) =>
        acc.push({ blanks: "", node: f(self, fst_ln) })
      ({ start: line_start, span }, _) => {
        let layout = if self.no_layouts || span.first <= line_start {
          ""
        } else {
          @char.utf_16_clean_raw(
            self.buf,
            self.i,
            first=line_start,
            last=span.first - 1,
          )
        }
        acc.push({ blanks: layout, node: f(self, span) })
      }
    }
  }
  acc
}

///|
fn Parser::first_non_blank_in_span(
  self : Parser,
  span : LineSpan,
) -> CharCodePos {
  @cmark_base.first_non_blank_in_span(self.i, span)
}

///|
fn[A] Parser::first_non_blank_over_nl(
  self : Parser,
  next_line~ : NextLineFn[A],
  lines : A,
  line : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[StringNode], Int)? {
  match
    @cmark_base.first_non_blank_over_nl(
      next_line~,
      self.i,
      lines,
      line~,
      start~,
    ) {
    None => None
    Some(ThisLine(nb)) => {
      let layout = if nb == start {
        []
      } else {
        [self.clean_raw_span({ ..line, first: start, last: nb - 1 })]
      }
      Some((line, layout, nb))
    }
    Some(NextLine(newline, nb)) => {
      let first_layout = self.clean_raw_span({ ..line, first: start })
      let next_layout = self.clean_raw_span({ ..newline, last: nb - 1 })
      let layout = [first_layout, next_layout]
      Some((newline, layout, nb))
    }
  }
}

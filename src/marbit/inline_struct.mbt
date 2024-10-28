// Inline structure parsing

/// Tokens for parsing inlines.
///
/// The list of tokens of a paragraph are the points to consider to
/// parse it into inlines. Tokens gradually become `Inline` tokens
/// containing parsed inlines. Between two tokens there is implicit
/// textual data. This data gradually becomes part of `Inline` tokens
/// or, at the end of of the parsing process, becomes `Text` inlines.
///
/// The token list also represents newlines explicitly, either via
/// the `Newline` token or via the `Inline` token since inlines may
/// start on a line and up on another one.
enum Token {
  AutolinkOrHtmlStart(TokenStart)
  Backticks(TokenBackticks)
  EmphasisMarks(TokenEmphasisMarks)
  Inline(TokenInline)
  LinkStart(TokenLinkStart)
  Newline(TokenNewline)
  RightBrack(TokenStart)
  RightParen(TokenStart)
  StrikethroughMarks(TokenStrikethroughMarks)
  MathSpanMarks(TokenMathSpanMarks)
} derive(Show, ToJson)

struct TokenStart {
  start : BytePos
} derive(Show, ToJson)

struct TokenBackticks {
  start : BytePos
  count : Int
  escaped : Bool
} derive(Show, ToJson)

struct TokenEmphasisMarks {
  start : BytePos
  char : Char
  count : Int
  may_open : Bool
  may_close : Bool
} derive(Show, ToJson)

struct TokenInline {
  start : BytePos
  inline : Inline
  endline : LineSpan
  next : BytePos
} derive(Show, ToJson)

struct TokenLinkStart {
  start : BytePos
  image : Bool
} derive(Show, ToJson)

struct TokenNewline {
  /// Points at spaces or `\` on the broken line
  start : BytePos
  break_ty : InlineBreakType
  newline : LineSpan
} derive(Show, ToJson)

struct TokenStrikethroughMarks {
  start : BytePos
  may_open : Bool
  may_close : Bool
} derive(Show, ToJson)

struct TokenMathSpanMarks {
  start : BytePos
  count : Int
  may_open : Bool
  may_close : Bool
} derive(Show, ToJson)

fn Token::start(self : Token) -> BytePos {
  match self {
    Token::AutolinkOrHtmlStart(t) => t.start
    Token::Backticks(t) => t.start
    Token::EmphasisMarks(t) => t.start
    Token::Inline(t) => t.start
    Token::LinkStart(t) => t.start
    Token::Newline(t) => t.start
    Token::RightBrack(t) => t.start
    Token::RightParen(t) => t.start
    Token::StrikethroughMarks(t) => t.start
    Token::MathSpanMarks(t) => t.start
  }
}

fn CloserIndex::has_backticks(
  self : CloserIndex,
  ~count : Int,
  ~after : Int
) -> Bool {
  self.exists(Backticks(count), ~after)
}

fn CloserIndex::has_right_brack(self : CloserIndex, ~after : Int) -> Bool {
  self.exists(RightBrack, ~after)
}

fn CloserIndex::has_right_paren(self : CloserIndex, ~after : Int) -> Bool {
  self.exists(RightParen, ~after)
}

fn CloserIndex::emphasis_pos(
  self : CloserIndex,
  ~char : Char,
  ~after : Int
) -> Int? {
  self.pos(EmphasisMarks(char), ~after)
}

fn CloserIndex::has_emphasis(
  self : CloserIndex,
  ~char : Char,
  ~after : Int
) -> Bool {
  self.exists(EmphasisMarks(char), ~after)
}

fn CloserIndex::has_strikethrough(self : CloserIndex, ~after : Int) -> Bool {
  self.exists(StrikethroughMarks, ~after)
}

fn CloserIndex::has_math_span(
  self : CloserIndex,
  ~count : Int,
  ~after : Int
) -> Bool {
  self.exists(MathSpanMarks(count), ~after)
}

fn tokens_rev_and_make_closer_index(
  toks : List[Token]
) -> (CloserIndex, List[Token]) {
  loop CloserIndex::new(), List::Nil, toks {
    cidx, acc, Cons(Backticks(t1) as t, toks) =>
      continue cidx.add(Backticks(t1.count), t1.start), acc.add(t), toks
    cidx, acc, Cons(RightBrack(t1) as t, toks) =>
      continue cidx.add(RightBrack, t1.start), acc.add(t), toks
    cidx, acc, Cons(RightParen(t1), toks) =>
      continue cidx.add(RightParen, t1.start),
        // Discard the token since it's not used for parsing
        acc,
        toks
    cidx,
    acc,
    Cons(EmphasisMarks({ char, start, may_close: true, .. }) as t, toks) =>
      continue cidx.add(EmphasisMarks(char), start), acc.add(t), toks
    cidx,
    acc,
    Cons(StrikethroughMarks({ start, may_close: true, .. }) as t, toks) =>
      continue cidx.add(StrikethroughMarks, start), acc.add(t), toks
    cidx,
    acc,
    Cons(MathSpanMarks({ count, start, may_close: true, .. }) as t, toks) =>
      continue cidx.add(MathSpanMarks(count), start), acc.add(t), toks
    cidx, acc, Cons(t, toks) => continue cidx, acc.add(t), toks
    cidx, acc, Nil => (cidx, acc)
  }
}

/// Used to make the text delimitation precise for nested inlines.
fn tokens_rev_and_shorten_last_line(
  ~to_last : Int,
  acc : List[Token],
  toks : List[Token]
) -> List[Token] {
  loop to_last, acc, toks {
    last, acc, Cons(Newline({ newline, .. } as nl), toks) => {
      let t = Newline({ ..nl, newline: { ..newline, last, } })
      toks.rev_concat(acc.add(t))
    }
    last, acc, Cons(Inline({ endline, .. } as il), toks) => {
      let t = Token::Inline({ ..il, endline: { ..endline, last, } })
      toks.rev_concat(acc.add(t))
    }
    to_last, acc, Cons(t, toks) => continue to_last, acc.add(t), toks
    _, acc, Nil => acc
  }
}

fn tokens_drop_stop_after_right_brack(toks : List[Token]) -> List[Token] {
  toks
  .drop_while(
    fn(t) {
      match t {
        RightBrack(_) => false
        _ => true
      }
    },
  )
  .tail()
}

fn tokens_drop_until(~start : Int, toks : List[Token]) -> List[Token] {
  toks.drop_while(fn(t) { t.start() < start })
}

fn tokens_next_line(toks : List[Token]) -> (List[Token], LineSpan)? {
  loop toks {
    Nil => None
    Cons(Newline({ newline, .. }), toks) => Some((toks, newline))
    Cons(_, toks) => continue toks
  }
}

// Tokenization

fn Token::newline(
  s : String,
  prev_line : LineSpan,
  newline : LineSpan
) -> Token {
  // https://spec.commonmark.org/current/#softbreak
  // https://spec.commonmark.org/current/#hard-line-breaks
  let { first, last, .. } = prev_line
  let non_space = @marbit_base.rev_drop_spaces(s, ~first, start=last)
  let (start, break_ty) = if non_space == last && s[non_space] == '\\' {
    (non_space, Hard)
  } else {
    let start = non_space + 1
    (start, if last - start + 1 >= 2 { Hard } else { Soft })
  }
  Newline({ start, break_ty, newline })
}

fn tokens_add_backtick(
  toks : List[Token],
  s : String,
  line : LineSpan,
  ~prev_bslash : Bool,
  ~start : Int
) -> (List[Token], Int) {
  let last = @marbit_base.run_of(char='`', s, last=line.last, start=start + 1)
  let count = last - start + 1
  (toks.add(Backticks({ start, count, escaped: prev_bslash })), last + 1)
}

fn tokens_try_add_image_link_start(
  toks : List[Token],
  s : String,
  line : LineSpan,
  ~start : Int
) -> (List[Token], Int) {
  let next = start + 1
  if next > line.last || s[next] != '[' {
    return (toks, next)
  }
  (toks.add(LinkStart({ start, image: true })), next + 1)
}

fn tokens_try_add_emphasis(
  toks : List[Token],
  s : String,
  line : LineSpan,
  ~start : Int
) -> (List[Token], Int) {
  let { first, last, .. } = line
  let char = s[start]
  let run_last = @marbit_base.run_of(~char, ~last, s, start=start + 1)
  let count = run_last - start + 1
  let prev_char = @char.prev_char(s, ~first, before=start)
  let next_char = @char.next_char(s, ~last, after=run_last)
  let is_prev_white = @char.is_ascii_whitespace(prev_char)
  let is_prev_punct = @char.is_ascii_punctuation(prev_char)
  let is_next_white = @char.is_ascii_whitespace(next_char)
  let is_next_punct = @char.is_ascii_punctuation(next_char)
  let is_left_flanking = is_next_white.not() &&
    (is_next_punct.not() || is_prev_white || is_prev_punct)
  let is_right_flanking = is_prev_white.not() &&
    (is_prev_punct.not() || is_next_white || is_next_punct)
  let next = run_last + 1
  if is_left_flanking.not() && is_right_flanking.not() {
    return (toks, next)
  }
  let may_open = (char == '*' && is_left_flanking) ||
    (
      char == '_' &&
      is_left_flanking &&
      (is_right_flanking.not() || is_prev_punct)
    )
  let may_close = (char == '*' && is_right_flanking) ||
    (
      char == '_' &&
      is_right_flanking &&
      (is_left_flanking.not() || is_next_punct)
    )
  if may_open.not() && may_close.not() {
    return (toks, next)
  }
  (toks.add(EmphasisMarks({ start, char, count, may_open, may_close })), next)
}

fn tokens_try_add_strikethrough_marks(
  toks : List[Token],
  s : String,
  line : LineSpan,
  ~start : Int
) -> (List[Token], Int) {
  let { first, last, .. } = line
  let char = s[start]
  let run_last = @marbit_base.run_of(~char, s, ~last, start=start + 1)
  let count = run_last - start + 1
  let next = run_last + 1
  if count != 2 {
    return (toks, next)
  }
  let prev_char = @char.prev_char(s, ~first, before=start)
  let next_char = @char.next_char(s, ~last, after=run_last)
  let may_open = @char.is_ascii_whitespace(next_char).not()
  let may_close = @char.is_ascii_whitespace(prev_char).not()
  (toks.add(StrikethroughMarks({ start, may_open, may_close })), next)
}

fn tokens_try_add_math_span_marks(
  toks : List[Token],
  s : String,
  line : LineSpan,
  ~start : Int
) -> (List[Token], Int) {
  let { first, last, .. } = line
  let char = s[start]
  let run_last = @marbit_base.run_of(~char, s, ~last, start=start + 1)
  let count = run_last - start + 1
  let next = run_last + 1
  if count != 2 {
    return (toks, next)
  }
  let mut may_open = true
  let mut may_close = true
  if count == 1 {
    let prev_char = @char.prev_char(s, ~first, before=start)
    let next_char = @char.next_char(s, ~last, after=run_last)
    may_open = @char.is_ascii_whitespace(next_char).not()
    may_close = @char.is_ascii_whitespace(prev_char).not()
  }
  if may_open.not() && may_close.not() {
    return (toks, next)
  }
  (toks.add(MathSpanMarks({ start, count, may_open, may_close })), next)
}

fn tokenize(
  ~exts : Bool,
  s : String,
  lines : List[LineSpan]
) -> (CloserIndex, List[Token], LineSpan) {
  guard let Cons(line, lines) = lines else {
    _ => abort("expected at least one line")
  }
  let (cidx, toks) = loop lines, line, false, List::Nil, line.first {
    lines, line, prev_bslash, acc, k => {
      if k > line.last {
        match lines {
          Nil => break tokens_rev_and_make_closer_index(acc)
          Cons(newline, lines) => {
            let t = Token::newline(s, line, newline)
            continue lines, newline, false, acc.add(t), newline.first
          }
        }
      }
      let (acc, next) = match (s[k], prev_bslash, exts) {
        ('\\', _, _) => continue lines, line, prev_bslash.not(), acc, k + 1
        ('`', _, _) => tokens_add_backtick(acc, s, line, ~prev_bslash, start=k)
        (_, true, _) => (acc, k + 1)
        ('*' | '_', _, _) => tokens_try_add_emphasis(acc, s, line, start=k)
        (']', _, _) => (acc.add(RightBrack({ start: k })), k + 1)
        ('[', _, _) => (acc.add(LinkStart({ start: k, image: false })), k + 1)
        ('!', _, _) => tokens_try_add_image_link_start(acc, s, line, start=k)
        ('<', _, _) => (acc.add(AutolinkOrHtmlStart({ start: k })), k + 1)
        (')', _, _) => (acc.add(RightParen({ start: k })), k + 1)
        ('~', _, true) =>
          tokens_try_add_strikethrough_marks(acc, s, line, start=k)
        ('$', _, true) => tokens_try_add_math_span_marks(acc, s, line, start=k)
        _ => (acc, k + 1)
      }
      continue lines, line, false, acc, next
    }
  }
  (cidx, toks, line)
}

// Making inlines and inline tokens

fn Parser::break_inline(
  self : Parser,
  line : LineSpan,
  ~start : Int,
  ~break_ty : InlineBreakType,
  ~newline : LineSpan
) -> Inline {
  let layout_before = { ..line, first: start }
  let layout_after = {
    let non_blank = self.first_non_blank_in_span(newline)
    { ..newline, last: non_blank - 1 }
  }
  let m = self.meta_of_spans(first=layout_before, last=layout_after)
  let layout_before = self.layout_clean_raw_span(layout_before)
  let layout_after = self.layout_clean_raw_span(layout_after)
  Break({ v: { ty: break_ty, layout_before, layout_after }, meta: m })
}

fn Parser::try_add_text_inline(
  self : Parser,
  line : LineSpan,
  ~first : Int,
  ~last : Int,
  acc : List[Inline]
) -> List[Inline] {
  if first > last {
    return acc
  }
  let first = if first == line.first {
    self.first_non_blank_in_span(line) // Strip leading blanks
  } else {
    first
  }
  acc.add(Text(self.clean_unesc_unref_span({ ..line, first, last })))
}

fn Parser::inlines_inline(
  self : Parser,
  ~first : BytePos,
  ~last : BytePos,
  ~first_line : LineSpan,
  ~last_line : LineSpan,
  acc : List[Inline]
) -> Inline {
  match acc {
    Cons(i, Nil) => i
    is => {
      let text_loc = self.text_loc_of_lines(
        ~first,
        ~last,
        ~first_line,
        ~last_line,
      )
      Inlines({ v: is, meta: self.meta(text_loc) })
    }
  }
}

fn Parser::code_span_token(
  self : Parser,
  ~count : Int,
  ~first : BytePos,
  ~last : BytePos,
  ~first_line : LineSpan,
  ~last_line : LineSpan,
  rev_spans : RevSpans
) -> Token {
  let text_loc = self.text_loc_of_lines(~first, ~last, ~first_line, ~last_line)
  let code_layout = self.raw_tight_block_lines(~rev_spans)
  let meta = self.meta(text_loc)
  let cs = CodeSpan({ v: { backticks: count, code_layout }, meta })
  Inline({ start: first, inline: cs, endline: last_line, next: last + 1 })
}

fn Parser::autolink_token(
  self : Parser,
  line : LineSpan,
  ~first : Int,
  ~last : Int,
  ~is_email : Bool
) -> Token {
  let meta = self.meta(self.text_loc_of_span({ ..line, first, last }))
  let link = { ..line, first: first + 1, last: last - 1 }
  let link = self.clean_unref_span(link)
  let inline = Autolink({ v: { link, is_email }, meta })
  Inline({ start: first, inline, endline: line, next: last + 1 })
}

fn Parser::raw_html_token(
  self : Parser,
  ~first : Int,
  ~last : Int,
  ~first_line : LineSpan,
  ~last_line : LineSpan,
  rev_spans : RevSpans
) -> Token {
  let raw = self.raw_tight_block_lines(~rev_spans)
  let text_loc = {
    let first = raw.head().unwrap().node.meta.loc
    let { last: last_byte, pos: last_line, .. } = rev_spans.head().unwrap().span
    { ..first, last_byte, last_line }
  }
  let inline = RawHtml({ v: raw, meta: self.meta(text_loc) })
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

fn Parser::link_token(
  self : Parser,
  ~first : Int,
  ~last : Int,
  ~first_line : LineSpan,
  ~last_line : LineSpan,
  ~image : Bool,
  link : InlineLink
) -> Token {
  let text_loc = self.text_loc_of_lines(~first, ~last, ~first_line, ~last_line)
  let link = { v: link, meta: self.meta(text_loc) }
  let inline : Inline = if image { Image(link) } else { Link(link) }
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

fn Parser::emphasis_token(
  self : Parser,
  ~first : Int,
  ~last : Int,
  ~first_line : LineSpan,
  ~last_line : LineSpan,
  ~strong : Bool,
  emph : Inline
) -> Token {
  let text_loc = self.text_loc_of_lines(~first, ~last, ~first_line, ~last_line)
  let delim = self.i[first]
  let emph = { v: { delim, inline: emph }, meta: self.meta(text_loc) }
  let inline = if strong { StrongEmphasis(emph) } else { Emphasis(emph) }
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

fn Parser::ext_strikethough_token(
  self : Parser,
  ~first : Int,
  ~last : Int,
  ~first_line : LineSpan,
  ~last_line : LineSpan,
  s : Inline
) -> Token {
  let text_loc = self.text_loc_of_lines(~first, ~last, ~first_line, ~last_line)
  let inline = ExtStrikethrough({ v: s, meta: self.meta(text_loc) })
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

// fn Parser::ext_math_span_token()

// Parsers

/// https://spec.commonmark.org/current/#code-span
fn Parser::try_code(
  self : Parser,
  toks : List[Token],
  start_line : LineSpan,
  ~start : BytePos,
  ~count : Int,
  ~escaped : Bool
) -> (List[Token], LineSpan, Token)? {
  let cstart = start
  if escaped || has_backticks(~count, after=cstart, self.cidx).not() {
    return None
  }
  let first = cstart + count
  loop toks, { ..start_line, first, }, count, List::Nil, first {
    Nil, _, _, _, _ => None
    Cons(Backticks({ start, count: c, .. }), toks), line, count, spans, k => {
      if c != count {
        continue toks, line, count, spans, k
      }
      let span : Span = {
        start: line.first,
        span: { ..line, first: k, last: start - 1 },
      }
      let spans = spans.add(span)
      let first = cstart
      let last = start + count - 1
      let first_line = start_line
      let last_line = line
      let t = self.code_span_token(
        ~count,
        ~first,
        ~last,
        ~first_line,
        ~last_line,
        spans,
      )
      Some((toks, line, t))
    }
    Cons(Newline({ newline, .. }), toks), line, count, spans, k => {
      let span : Span = { start: line.first, span: { ..line, first: k } }
      let spans = spans.add(span)
      let k = self.first_non_blank_in_span(newline)
      continue toks, newline, count, spans, k
    }
    Cons(_, toks), line, count, spans, k => continue toks, line, count, spans, k
  }
}

fn Parser::try_math_span(
  self : Parser,
  toks : List[Token],
  start_line : LineSpan,
  ~start : BytePos,
  ~count : Int
) -> (List[Token], LineSpan, Token)? {
  ...
}

fn Parser::try_autolink_or_html(
  self : Parser,
  toks : List[Token],
  line : LineSpan,
  ~start : BytePos
) -> (List[Token], LineSpan, Token)? {
  // Weirdly, there's seemingly no `if let` in Moonbit.
  guard let None = @marbit_base.autolink_uri(self.i, last=line.last, ~start) else {
    Some(last) => {
      let t = self.autolink_token(line, first=start, ~last, is_email=false)
      let toks = tokens_drop_until(start=last + 1, toks)
      return Some((toks, line, t))
    }
  }
  guard let None = @marbit_base.autolink_email(self.i, last=line.last, ~start) else {
    Some(last) => {
      let t = self.autolink_token(line, first=start, ~last, is_email=true)
      let toks = tokens_drop_until(start=last + 1, toks)
      return Some((toks, line, t))
    }
  }
  guard let Some((toks, last_line, spans, last)) = @marbit_base.raw_html(
    next_line=tokens_next_line,
    self.i,
    toks,
    ~line,
    ~start,
  ) else {
    _ => return None
  }
  let first = start
  let first_line = line
  let t = self.raw_html_token(~first, ~last, ~first_line, ~last_line, spans)
  let toks = tokens_drop_until(start=last + 1, toks)
  Some((toks, last_line, t))
}

fn Parser::label_of_rev_spans(
  self : Parser,
  ~key : String,
  rev_spans : RevSpans
) -> Label {
  let meta = if self.no_locs || rev_spans.is_empty() {
    Meta::none()
  } else {
    self.meta_of_spans(
      first=rev_spans.unsafe_last().span,
      last=rev_spans.unsafe_head().span,
    )
  }
  let text = self.tight_block_lines(~rev_spans)
  { meta, key, text }
}

/// https://spec.commonmark.org/current/#full-reference-link
fn Parser::try_full_reflink_remainder(
  self : Parser,
  toks : List[Token],
  line : LineSpan,
  ~image : Bool,
  ~start : BytePos
) -> (List[Token], LineSpan, ReferenceKind, BytePos)?? {
  @marbit_base.link_label(
    self.buf,
    next_line=tokens_next_line,
    self.i,
    toks,
    ~line,
    ~start,
  ).map(
    fn {
      (toks, line, rev_spans, last, key) => {
        let ref = self.label_of_rev_spans(~key, rev_spans)
        let toks = tokens_drop_stop_after_right_brack(toks)
        self
        .find_def_for_ref(~image, ref)
        .map(fn(def) { (toks, line, ReferenceKind::Ref(Full, ref, def), last) })
      }
    },
  )
}

/// https://spec.commonmark.org/current/#shortcut-reference-link
fn Parser::try_shortcut_reflink(
  self : Parser,
  toks : List[Token],
  line : LineSpan,
  ~image : Bool,
  ~start : BytePos
) -> (List[Token], LineSpan, ReferenceKind, BytePos)? {
  let start = start + image.to_int() // [
  guard let Some((toks, line, rev_spans, last, key)) = @marbit_base.link_label(
    self.buf,
    next_line=tokens_next_line,
    self.i,
    toks,
    ~line,
    ~start,
  ) else {
    _ => return None
  }
  let ref = self.label_of_rev_spans(~key, rev_spans)
  let toks = tokens_drop_stop_after_right_brack(toks)
  self
  .find_def_for_ref(~image, ref)
  .map(fn(def) { (toks, line, ReferenceKind::Ref(Shortcut, ref, def), last) })
}

/// https://spec.commonmark.org/current/#collapsed-reference-link
fn Parser::try_collapsed_reflink(
  self : Parser,
  toks : List[Token],
  line : LineSpan,
  ~image : Bool,
  ~start : BytePos
) -> (List[Token], LineSpan, ReferenceKind, BytePos)? {
  let start = start + image.to_int() // [
  guard let Some((toks, line, rev_spans, last, key)) = @marbit_base.link_label(
    self.buf,
    next_line=tokens_next_line,
    self.i,
    toks,
    ~line,
    ~start,
  ) else {
    _ => return None
  }
  let ref = self.label_of_rev_spans(~key, rev_spans)
  let last = last + 2 // ][]
  let toks = tokens_drop_stop_after_right_brack(toks)
  let toks = tokens_drop_stop_after_right_brack(toks)
  self
  .find_def_for_ref(~image, ref)
  .map(fn(def) { (toks, line, ReferenceKind::Ref(Collapsed, ref, def), last) })
}

/// https://spec.commonmark.org/current/#inline-link
fn Parser::try_inline_link_remainder(
  self : Parser,
  toks : List[Token],
  start_line : LineSpan,
  ~image : Bool,
  ~start : BytePos
) -> (List[Token], LineSpan, ReferenceKind, BytePos)? {
  let st = start
  guard self.cidx.has_right_paren(after=st) else { return None }
  guard let Some((toks, line, before_dest, start)) = self.first_non_blank_over_nl(
    next_line=tokens_next_line,
    toks,
    start_line,
    start=st + 1,
  ) else {
    _ => return None
  }
  let (toks, line, angled_dest, dest, start) = match
    @marbit_base.link_destination(self.i, last=line.last, ~start) {
    None => (toks, line, false, None, start)
    Some((angled, first, last)) => {
      let dest = self.clean_unesc_unref_span({ ..line, first, last })
      let next = last + 1 + angled.to_int()
      (toks, line, angled, Some(dest), next)
    }
  }
  let (toks, line, after_dest, title_open_delim, title, start) = match
    self.first_non_blank_over_nl(next_line=tokens_next_line, toks, line, ~start) {
    None => (toks, line, List::Nil, '"', None, start)
    Some((toks, line, after_dest, start1)) =>
      if start1 == start {
        (toks, line, List::Nil, '"', None, start)
      } else {
        let start = start1
        match
          @marbit_base.link_title(
            next_line=tokens_next_line,
            self.i,
            toks,
            ~line,
            ~start,
          ) {
          None => (toks, line, after_dest, '"', None, start)
          Some((toks, line, rev_spans, last)) => {
            let title = self.tight_block_lines(~rev_spans)
            (toks, line, after_dest, self.i[start], Some(title), last + 1)
          }
        }
      }
  }
  let (toks, line, after_title, last) = self
    .first_non_blank_over_nl(next_line=tokens_next_line, toks, line, ~start)
    .or((toks, line, List::Nil, start))
  if last > line.last || self.i[last] != ')' {
    return None
  }
  let layout : LinkDefinitionLayout = {
    indent: 0,
    angled_dest,
    before_dest,
    after_dest,
    title_open_delim,
    after_title,
  }
  let label = None
  let defined_label = None
  let ld : LinkDefinition = { layout, label, defined_label, dest, title }
  let textloc = self.text_loc_of_lines(
    first=st,
    last=start,
    first_line=start_line,
    last_line=line,
  )
  let ld = { v: ld, meta: self.meta(textloc) }
  let toks = tokens_drop_until(start=last + 1, toks)
  Some((toks, line, Inline(ld), last))
}

// https://spec.commonmark.org/current/#link-text
fn Parser::find_link_text_tokens(
  self : Parser,
  toks : List[Token],
  start_line : LineSpan,
  ~start : BytePos
) -> (List[Token], LineSpan, List[Token], BytePos)? {
  loop toks, start_line, 0, List::Nil {
    Cons(RightBrack({ start: last, .. }), toks), line, 0, acc => {
      let acc = tokens_rev_and_shorten_last_line(to_last=last - 1, Nil, acc)
      Some((toks, line, acc, last))
    }
    Cons(Backticks({ start, count, escaped }), toks), line, nest, acc =>
      match self.try_code(toks, line, ~start, ~count, ~escaped) {
        None => continue toks, line, nest, acc
        Some((toks, line, t)) => continue toks, line, nest, acc.add(t)
      }
    Cons(MathSpanMarks({ start, count, may_open, .. }), toks),
    line,
    nest,
    acc => {
      if may_open.not() {
        continue toks, line, nest, acc
      }
      match self.try_math_span(toks, line, ~start, ~count) {
        None => continue toks, line, nest, acc
        Some((toks, line, t)) => continue toks, line, nest, acc.add(t)
      }
    }
    Cons(AutolinkOrHtmlStart({ start }), toks), line, nest, acc =>
      match self.try_autolink_or_html(toks, line, ~start) {
        None => continue toks, line, nest, acc
        Some((toks, line, t)) => continue toks, line, nest, acc.add(t)
      }
    Cons(RightBrack(_) as t, toks), line, nest, acc =>
      continue toks, line, nest - 1, acc.add(t)
    Cons(LinkStart(_) as t, toks), line, nest, acc =>
      continue toks, line, nest + 1, acc.add(t)
    Cons(Newline({ newline, .. }) as t, toks), _, nest, acc =>
      continue toks, newline, nest, acc.add(t)
    Cons(Inline({ endline, .. }) as t, toks), _, nest, acc =>
      continue toks, endline, nest, acc.add(t)
    Cons(t, toks), line, nest, acc => continue toks, line, nest, acc.add(t)
    Nil, _, _, _ => None
  }
}

fn Parser::try_link_def(
  self : Parser,
  ~start : BytePos,
  ~start_toks : List[Token],
  ~start_line : LineSpan,
  ~toks : List[Token],
  ~line : LineSpan,
  ~text_last : BytePos,
  ~image : Bool,
  text : List[Inline]
) -> (List[Token], LineSpan, Token, Bool)? {
  let next = text_last + 1
  let link = if next > line.last {
    self.try_shortcut_reflink(start_toks, start_line, ~image, ~start)
  } else {
    match self.i[next] {
      '(' =>
        match self.try_inline_link_remainder(toks, line, ~image, start=next) {
          None =>
            self.try_shortcut_reflink(start_toks, start_line, ~image, ~start)
          Some(_) as v => v
        }
      '[' => {
        let next1 = next + 1
        if next1 <= line.last && self.i[next1] == ']' {
          self.try_collapsed_reflink(start_toks, start_line, ~image, ~start)
        } else {
          let r = self.try_full_reflink_remainder(
            toks,
            line,
            ~image,
            start=next,
          )
          match r {
            None =>
              self.try_shortcut_reflink(start_toks, start_line, ~image, ~start)
            Some(None) => None
            Some(Some(_) as v) => v
          }
        }
      }
      _ => self.try_shortcut_reflink(start_toks, start_line, ~image, ~start)
    }
  }
  guard let Some((toks, endline, reference, last)) = link else {
    _ => return None
  }
  let first = start
  let text = self.inlines_inline(
    ~first,
    last=text_last,
    first_line=start_line,
    last_line=line,
    text,
  )
  let link : InlineLink = { text, reference }
  let t = self.link_token(
    ~first,
    ~last,
    first_line=start_line,
    last_line=endline,
    ~image,
    link,
  )
  let had_link = image.not() && self.nested_links.not()
  Some((toks, endline, t, had_link))
}

// The following sequence of mutually recursive functions define
// inline parsing.

// First pass

fn Parser::try_link(
  self : Parser,
  start_toks : List[Token],
  start_line : LineSpan,
  ~image : Bool,
  ~start : BytePos
) -> (List[Token], LineSpan, Token, Bool)? {
  guard self.cidx.has_right_brack(after=start) else { return None }
  guard let Some((toks, line, text_toks, text_last)) = self.find_link_text_tokens( // text_last with ] delim
    start_toks,
    start_line,
    ~start,
  ) else {
    _ => return None
  }
  let (text, had_link) = self.parse_tokens(
    text_toks,
    {
      let first = start + 1 + image.to_int()
      let last = if start_line == line {
        text_last - 1
      } else {
        start_line.last
      }
      { ..start_line, first, last }
    },
  )
  if had_link && image.not() {
    return None
  }
  self.try_link_def(
    ~start,
    ~start_toks,
    ~start_line,
    ~toks,
    ~line,
    ~text_last,
    ~image,
    text,
  )
}

/// Parse inline atoms and links.
/// Links are parsed here otherwise link reference data gets parsed as atoms. 
fn Parser::first_pass(
  self : Parser,
  toks : List[Token],
  line : LineSpan
) -> (List[Token], Bool) {
  loop toks, line, false, List::Nil {
    Nil, _, had_link, acc => (acc.rev(), had_link)
    Cons(Backticks({ start, count, escaped }), toks), line, had_link, acc =>
      match self.try_code(toks, line, ~start, ~count, ~escaped) {
        None => continue toks, line, had_link, acc
        Some((toks, line, t)) => continue toks, line, had_link, acc.add(t)
      }
    Cons(MathSpanMarks({ start, count, may_open, .. }), toks),
    line,
    had_link,
    acc => {
      if may_open.not() {
        continue toks, line, had_link, acc
      }
      match self.try_math_span(toks, line, ~start, ~count) {
        None => continue toks, line, had_link, acc
        Some((toks, line, t)) => continue toks, line, had_link, acc.add(t)
      }
    }
    Cons(AutolinkOrHtmlStart({ start, .. }), toks), line, had_link, acc =>
      match self.try_autolink_or_html(toks, line, ~start) {
        None => continue toks, line, had_link, acc
        Some((toks, line, t)) => continue toks, line, had_link, acc.add(t)
      }
    Cons(LinkStart({ start, image }), toks), line, had_link, acc =>
      match self.try_link(toks, line, ~image, ~start) {
        None => continue toks, line, had_link, acc
        Some((toks, line, t, had_link)) =>
          continue toks, line, had_link, acc.add(t)
      }
    Cons(RightBrack(_), toks), line, had_link, acc =>
      continue toks, line, had_link, acc
    Cons(Newline({ newline, .. }) as nl, toks), _, had_link, acc =>
      continue toks, newline, had_link, acc.add(nl)
    Cons(t, toks), line, had_link, acc =>
      continue toks, line, had_link, acc.add(t)
  }
}

// Second pass

fn Parser::find_emphasis_text(
  self : Parser,
  toks : List[Token],
  line : LineSpan,
  ~opener : TokenEmphasisMarks
) ->
     Result[
       (List[Token], LineSpan, Int, List[Token], TokenEmphasisMarks),
       List[Token],
     ] {
  fn marks_match(marks : TokenEmphasisMarks, opener : TokenEmphasisMarks) {
    opener.char == marks.char &&
    (
      (marks.may_open || opener.may_close).not() ||
      marks.count % 3 == 0 ||
      (opener.count + marks.count) % 3 != 0
    )
  }

  fn marks_has_precedence(
    marks : TokenEmphasisMarks,
    opener : TokenEmphasisMarks
  ) {
    if marks.char == opener.char {
      return true // Rule 16
    }
    // Rule 15
    let after = marks.start
    self.cidx.emphasis_pos(char=marks.char, ~after) <
    self.cidx.emphasis_pos(char=opener.char, ~after)
  }

  loop toks, line, List::Nil, opener {
    Nil, _, acc, _ => Err(acc.rev())
    Cons(EmphasisMarks(marks) as t, toks), line, acc, opener => {
      let after = marks.start
      if marks.may_close && marks_match(marks, opener) {
        let used = if marks.count >= 2 && opener.count >= 2 { 2 } else { 1 }
        let to_last = marks.start - 1
        let acc = tokens_rev_and_shorten_last_line(~to_last, Nil, acc)
        Ok((toks, line, used, acc, marks))
      } else if marks.may_open && marks_has_precedence(marks, opener) {
        match self.try_emphasis(toks, line, opener=marks) {
          Err(toks) => continue toks, line, acc, opener
          Ok((toks, line)) => continue toks, line, acc, opener
        }
      } else if self.cidx.has_emphasis(char=opener.char, ~after) {
        continue toks, line, acc.add(t), opener
      } else {
        Err(acc.add(t).rev_concat(toks))
      }
    }
    Cons(Newline({ newline: l, .. }) as t, toks)
    | Cons(Inline({ endline: l, .. }) as t, toks),
    _,
    acc,
    opener => continue toks, l, acc.add(t), opener
    Cons(t, toks), line, acc, opener => continue toks, line, acc.add(t), opener
  }
}

fn Parser::try_emphasis(
  self : Parser,
  start_toks : List[Token],
  start_line : LineSpan,
  ~opener : TokenEmphasisMarks
) -> Result[(List[Token], LineSpan), List[Token]] {
  let start = opener.start
  guard self.cidx.has_emphasis(char=opener.char, after=start) else {
    Err(start_toks)
  }
  guard let Ok((toks, line, used, emph_toks, closer)) = self.find_emphasis_text(
    start_toks,
    start_line,
    ~opener,
  ) else {
    Err(toks) => Err(toks)
  }
  let text_first = start + opener.count
  let text_last = closer.start - 1
  let first = text_first - used
  let last = closer.start + used - 1
  let first_line = line
  let last_line = line
  let emph = {
    let last = if start_line == line { text_last } else { start_line.last }
    let text_start = { ..start_line, first: text_first, last }
    let emph_toks = self.second_pass(emph_toks, text_start)
    let text = self.last_pass(emph_toks, text_start)
    self.inlines_inline(~first, last=text_last, ~first_line, ~last_line, text)
  }
  let toks = {
    let count = closer.count - used
    if count == 0 {
      toks
    } else {
      toks.add(EmphasisMarks({ ..closer, start: last + 1, count }))
    }
  }
  let toks = {
    let strong = used == 2
    let emph = self.emphasis_token(
      ~first,
      ~last,
      ~first_line,
      ~last_line,
      ~strong,
      emph,
    )
    toks.add(emph)
  }
  let toks = {
    let count = opener.count - used
    if count == 0 {
      toks
    } else {
      toks.add(EmphasisMarks({ ..opener, count, }))
    }
  }
  Ok((toks, line))
}

fn Parser::find_strikethrough_text(
  self : Parser,
  toks : List[Token],
  start_line : LineSpan
) ->
     Result[
       (List[Token], LineSpan, List[Token], TokenStrikethroughMarks),
       List[Token],
     ] {
  loop toks, start_line, List::Nil {
    Nil, _, acc => Err(acc.rev())
    Cons(StrikethroughMarks(marks), toks), line, acc =>
      if marks.may_close {
        let to_last = marks.start - 1
        let acc = tokens_rev_and_shorten_last_line(~to_last, Nil, acc)
        Ok((toks, line, acc, marks))
      } else if marks.may_open {
        match self.try_strikethrough(toks, line, opener=marks) {
          Err(toks) => continue toks, line, acc
          Ok((toks, line)) => continue toks, line, acc
        }
      } else {
        abort("unreachable")
      }
    Cons(Newline({ newline: l, .. }) | Inline({ endline: l, .. }) as t, toks),
    _,
    acc => continue toks, l, acc.add(t)
    Cons(t, toks), line, acc => continue toks, line, acc.add(t)
  }
}

fn Parser::try_strikethrough(
  self : Parser,
  start_toks : List[Token],
  start_line : LineSpan,
  ~opener : TokenStrikethroughMarks
) -> Result[(List[Token], LineSpan), List[Token]] {
  let start = opener.start
  guard self.cidx.has_strikethrough(after=start) else { Err(start_toks) }
  guard let Ok((toks, line, striken_toks, closer)) = self.find_strikethrough_text(
    start_toks, start_line,
  ) else {
    Err(e) => Err(e)
  }
  let first_line = start_line
  let last_line = line
  let text = {
    let first = start + 2
    let last = closer.start - 1
    let text_start = {
      let last = if start_line == line { last } else { start_line.last }
      { ..start_line, first, last }
    }
    let emph_toks = self.second_pass(striken_toks, text_start)
    let text = self.last_pass(emph_toks, text_start)
    self.inlines_inline(~first, ~last, ~first_line, ~last_line, text)
  }
  let toks = toks.add(
    {
      let first = opener.start
      let last = closer.start + 1
      self.ext_strikethough_token(~first, ~last, ~first_line, ~last_line, text)
    },
  )
  Ok((toks, line))
}

fn Parser::second_pass(
  self : Parser,
  toks : List[Token],
  line : LineSpan
) -> List[Token] {
  loop toks, line, List::Nil {
    Nil, _, acc => acc.rev()
    Cons(EmphasisMarks(opener), toks), line, acc =>
      if opener.may_open {
        match self.try_emphasis(toks, line, ~opener) {
          Err(toks) => continue toks, line, acc
          Ok((toks, line)) => continue toks, line, acc
        }
      } else {
        continue toks, line, acc
      }
    Cons(StrikethroughMarks(opener), toks), line, acc =>
      if opener.may_open {
        match self.try_strikethrough(toks, line, ~opener) {
          Err(toks) => continue toks, line, acc
          Ok((toks, line)) => continue toks, line, acc
        }
      } else {
        continue toks, line, acc
      }
    Cons(Newline({ newline: l, .. }) | Inline({ endline: l, .. }) as t, toks),
    _,
    acc => continue toks, l, acc.add(t)
    Cons(t, toks), line, acc => continue toks, line, acc.add(t)
  }
}

// Last pass

/// Only `Inline` and `Newline` tokens remain. We fold over them to
/// convert them to `inline` values and `Break`s. `Text` inlines
/// are created for data between them.
fn Parser::last_pass(
  self : Parser,
  toks : List[Token],
  line : LineSpan
) -> List[Inline] {
  loop toks, line, List::Nil, line.first {
    Nil, line, acc, k =>
      self.try_add_text_inline(line, first=k, last=line.last, acc).rev()
    Cons(Newline({ start, break_ty, newline }), toks), line, acc, k => {
      let acc = self.try_add_text_inline(line, first=k, last=start - 1, acc)
      let break_ = self.break_inline(line, ~start, ~break_ty, ~newline)
      continue toks, newline, acc.add(break_), newline.first
    }
    Cons(Inline({ start, inline, endline, next }), toks), line, acc, k => {
      let acc = self.try_add_text_inline(line, first=k, last=start - 1, acc)
      let acc = match inline {
        Inlines({ v: is, .. }) => is.rev().rev_concat(acc)
        i => acc.add(i)
      }
      continue toks, endline, acc, next
    }
    _, _, _, _ => abort("unreachable")
  }
}

fn Parser::parse_tokens(
  self : Parser,
  toks : List[Token],
  first_line : LineSpan
) -> (List[Inline], Bool) {
  let (toks, had_link) = self.first_pass(toks, first_line)
  let toks = self.second_pass(toks, first_line)
  let inlines = self.last_pass(toks, first_line)
  (inlines, had_link)
}

fn Parser::strip_paragraph(
  self : Parser,
  lines : List[LineSpan]
) -> ((Col, String), Meta, List[LineSpan]) {
  let (last, trailing_blanks) = {
    let line = lines.unsafe_head()
    let { first, last: start, .. } = line
    let non_blank = @marbit_base.last_non_blank(self.i, ~first, ~start)
    let last = { ..line, last: non_blank }
    let trailing_blanks = self.layout_clean_raw_span1(
      { ..line, first: non_blank + 1 },
    )
    (last, trailing_blanks)
  }
  let lines = lines.tail().add(last).rev()
  let (first, leading_indent) = {
    let line = lines.unsafe_head()
    let non_blank = self.first_non_blank_in_span(line)
    let first = { ..line, first: non_blank }
    let leading_indent = non_blank - line.first
    (first, leading_indent)
  }
  let lines = lines.tail().add(first)
  ((leading_indent, trailing_blanks), self.meta_of_spans(~first, ~last), lines)
}

fn Parser::parse_inline(
  self : Parser,
  // NOTE: The `lines` here are in reverse order.
  lines : List[LineSpan]
) -> ((Col, String), Inline) {
  let (layout, meta, lines) = self.strip_paragraph(lines)
  let (cidx, toks, first_line) = tokenize(self.i, lines, exts=self.exts)
  self.cidx = cidx
  let (is, _) = self.parse_tokens(toks, first_line)
  let inline = match is {
    Cons(i, Nil) => i
    _ => Inlines({ v: is, meta })
  }
  (layout, inline)
}

// Parsing table rows

// TODO: Implement this.

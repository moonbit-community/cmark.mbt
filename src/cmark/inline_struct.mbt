// Inline structure parsing

///| Tokens for parsing inlines.
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
priv enum Token {
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

///|
priv struct TokenStart {
  start : CharCodePos
} derive(Show, ToJson)

///|
priv struct TokenBackticks {
  start : CharCodePos
  count : Int
  escaped : Bool
} derive(Show, ToJson)

///|
priv struct TokenEmphasisMarks {
  start : CharCodePos
  char : Char
  count : Int
  may_open : Bool
  may_close : Bool
} derive(Show, ToJson)

///|
priv struct TokenInline {
  start : CharCodePos
  inline : Inline
  endline : LineSpan
  next : CharCodePos
} derive(Show, ToJson)

///|
priv struct TokenLinkStart {
  start : CharCodePos
  image : Bool
} derive(Show, ToJson)

///|
priv struct TokenNewline {
  /// Points at spaces or `\` on the broken line
  start : CharCodePos
  break_ty : InlineBreakType
  newline : LineSpan
} derive(Show, ToJson)

///|
priv struct TokenStrikethroughMarks {
  start : CharCodePos
  may_open : Bool
  may_close : Bool
} derive(Show, ToJson)

///|
priv struct TokenMathSpanMarks {
  start : CharCodePos
  count : Int
  may_open : Bool
  may_close : Bool
} derive(Show, ToJson)

///|
fn Token::start(self : Token) -> CharCodePos {
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

///|
fn CloserIndex::has_backticks(
  self : CloserIndex,
  count~ : Int,
  after~ : Int,
) -> Bool {
  self.exists(Backticks(count), after~)
}

///|
fn CloserIndex::has_right_brack(self : CloserIndex, after~ : Int) -> Bool {
  self.exists(RightBrack, after~)
}

///|
fn CloserIndex::has_right_paren(self : CloserIndex, after~ : Int) -> Bool {
  self.exists(RightParen, after~)
}

///|
fn CloserIndex::emphasis_pos(
  self : CloserIndex,
  char~ : Char,
  after~ : Int,
) -> Int? {
  self.pos(EmphasisMarks(char), after~)
}

///|
fn CloserIndex::has_emphasis(
  self : CloserIndex,
  char~ : Char,
  after~ : Int,
) -> Bool {
  self.exists(EmphasisMarks(char), after~)
}

///|
fn CloserIndex::has_strikethrough(self : CloserIndex, after~ : Int) -> Bool {
  self.exists(StrikethroughMarks, after~)
}

///|
fn CloserIndex::has_math_span(
  self : CloserIndex,
  count~ : Int,
  after~ : Int,
) -> Bool {
  self.exists(MathSpanMarks(count), after~)
}

///|
fn make_closer_index(toks : Tokens) -> CloserIndex {
  let cidx = CloserIndex::new()
  guard not(toks.inner().is_empty()) else { cidx }
  toks
  .inner()
  .retain(fn(curr) {
    match curr {
      Backticks({ count, start, .. }) => cidx.add(Backticks(count), start)
      RightBrack({ start }) => cidx.add(RightBrack, start)
      RightParen({ start }) => {
        cidx.add(RightParen, start)
        return false // Discard the token since it's not used for parsing
      }
      EmphasisMarks({ char, start, may_close: true, .. }) =>
        cidx.add(EmphasisMarks(char), start)
      StrikethroughMarks({ start, may_close: true, .. }) =>
        cidx.add(StrikethroughMarks, start)
      MathSpanMarks({ count, start, may_close: true, .. }) =>
        cidx.add(MathSpanMarks(count), start)
      _ => ()
    }
    true
  })
  cidx
}

///| Used to make the text delimitation precise for nested inlines.
fn tokens_shorten_last_line(to_last~ : Int, toks : Tokens) -> Unit {
  let last = to_last
  for i = toks.inner().length() - 1; i >= 0; i = i - 1 {
    match toks.inner()[i] {
      Newline({ newline, .. } as nl) => {
        toks.inner()[i] = Newline({ ..nl, newline: { ..newline, last, } })
        break
      }
      Inline({ endline, .. } as il) => {
        toks.inner()[i] = Inline({ ..il, endline: { ..endline, last, } })
        break
      }
      _ => ()
    }
  }
}

///|
fn tokens_drop_stop_after_right_brack(rev_toks : RevTokens) -> Unit {
  for {
    match rev_toks.pop() {
      None | Some(RightBrack(_)) => break
      Some(_) => continue
    }
  }
}

///|
fn tokens_pop_until(start~ : Int, rev_toks : RevTokens) -> Unit {
  for {
    guard rev_toks.pop() is Some(t) else { break }
    if t.start() < start {
      continue
    }
    rev_toks.push(t)
    break
  }
}

///|
fn tokens_next_line(rev_toks : RevTokens) -> LineSpan? {
  let acc = []
  while rev_toks.pop() is Some(t) {
    if t is Newline({ newline, .. }) {
      return Some(newline)
    }
    acc.push(t)
  }
  while acc.pop() is Some(t) {
    rev_toks.push(t)
  }
  None
}

// Tokenization

///|
fn Token::newline(
  s : String,
  prev_line : LineSpan,
  newline : LineSpan,
) -> Token {
  // https://spec.commonmark.org/current/#softbreak
  // https://spec.commonmark.org/current/#hard-line-breaks
  let { first, last, .. } = prev_line
  let non_space = @cmark_base.rev_drop_spaces(s, first~, start=last)
  let (start, break_ty) = if non_space == last &&
    s[non_space] == '\\' {
    (non_space, Hard)
  } else {
    let start = non_space + 1
    (start, if last - start + 1 >= 2 { Hard } else { Soft })
  }
  Newline({ start, break_ty, newline })
}

///|
fn tokens_add_backtick(
  toks : Tokens,
  s : String,
  line : LineSpan,
  prev_bslash~ : Bool,
  start~ : Int,
) -> Int {
  let last = @cmark_base.run_of(char='`', s, last=line.last, start=start + 1)
  let count = last - start + 1
  toks.push(Backticks({ start, count, escaped: prev_bslash }))
  last + 1
}

///|
fn tokens_try_add_image_link_start(
  toks : Tokens,
  s : String,
  line : LineSpan,
  start~ : Int,
) -> Int {
  let next = start + 1
  guard next <= line.last && s[next] == '[' else { next }
  toks.push(LinkStart({ start, image: true }))
  next + 1
}

///|
fn tokens_try_add_emphasis(
  toks : Tokens,
  s : String,
  line : LineSpan,
  start~ : Int,
) -> Int {
  let { first, last, .. } = line
  let char = s[start].unsafe_to_char()
  let run_last = @cmark_base.run_of(char~, last~, s, start=start + 1)
  let count = run_last - start + 1
  let prev_char = @char.prev_char(s, first~, before=start)
  let next_char = @char.next_char(s, last~, after=run_last)
  let is_prev_white = @unicode.is_whitespace(prev_char)
  let is_prev_punct = @unicode.is_punctuation(prev_char)
  let is_next_white = @unicode.is_whitespace(next_char)
  let is_next_punct = @unicode.is_punctuation(next_char)
  let is_left_flanking = not(is_next_white) &&
    (not(is_next_punct) || is_prev_white || is_prev_punct)
  let is_right_flanking = not(is_prev_white) &&
    (not(is_prev_punct) || is_next_white || is_next_punct)
  let next = run_last + 1
  guard is_left_flanking || is_right_flanking else { next }
  let may_open = (char == '*' && is_left_flanking) ||
    (
      char == '_' &&
      is_left_flanking &&
      (not(is_right_flanking) || is_prev_punct)
    )
  let may_close = (char == '*' && is_right_flanking) ||
    (
      char == '_' &&
      is_right_flanking &&
      (not(is_left_flanking) || is_next_punct)
    )
  guard may_open || may_close else { next }
  toks.push(EmphasisMarks({ start, char, count, may_open, may_close }))
  next
}

///|
fn tokens_try_add_strikethrough_marks(
  toks : Tokens,
  s : String,
  line : LineSpan,
  start~ : Int,
) -> Int {
  let { first, last, .. } = line
  let char = s[start].unsafe_to_char()
  let run_last = @cmark_base.run_of(char~, s, last~, start=start + 1)
  let count = run_last - start + 1
  let next = run_last + 1
  guard count == 2 else { next }
  let prev_char = @char.prev_char(s, first~, before=start)
  let next_char = @char.next_char(s, last~, after=run_last)
  let may_open = not(@char.is_ascii_whitespace(next_char))
  let may_close = not(@char.is_ascii_whitespace(prev_char))
  toks.push(StrikethroughMarks({ start, may_open, may_close }))
  next
}

///|
fn tokens_try_add_math_span_marks(
  toks : Tokens,
  s : String,
  line : LineSpan,
  start~ : Int,
) -> Int {
  let { first, last, .. } = line
  let char = s[start].unsafe_to_char()
  let run_last = @cmark_base.run_of(char~, s, last~, start=start + 1)
  let count = run_last - start + 1
  let next = run_last + 1
  guard count <= 2 else { next }
  let mut may_open = true
  let mut may_close = true
  if count == 1 {
    let prev_char = @char.prev_char(s, first~, before=start)
    let next_char = @char.next_char(s, last~, after=run_last)
    may_open = not(@char.is_ascii_whitespace(next_char))
    may_close = not(@char.is_ascii_whitespace(prev_char))
  }
  guard may_open || may_close else { next }
  toks.push(MathSpanMarks({ start, count, may_open, may_close }))
  next
}

///|
fn tokenize(
  exts~ : Bool,
  s : String,
  lines : Array[LineSpan],
) -> (CloserIndex, Tokens, LineSpan) {
  guard lines is [line, .. lines] else { abort("expected at least one line") }
  let toks : Tokens = @deque.new()
  let cidx = for lines = lines, line = line, prev_bslash = false, k = line.first {
    if k > line.last {
      break match lines {
        [] => make_closer_index(toks)
        [newline, .. lines] => {
          let t = Token::newline(s, line, newline)
          toks.push(t)
          continue lines, newline, false, newline.first
        }
      }
    }
    let next = match s[k] {
      '\\' => continue lines, line, not(prev_bslash), k + 1
      '`' => tokens_add_backtick(toks, s, line, prev_bslash~, start=k)
      _ if prev_bslash => k + 1
      '*' | '_' => tokens_try_add_emphasis(toks, s, line, start=k)
      ']' => {
        toks.push(RightBrack({ start: k }))
        k + 1
      }
      '[' => {
        toks.push(LinkStart({ start: k, image: false }))
        k + 1
      }
      '!' => tokens_try_add_image_link_start(toks, s, line, start=k)
      '<' => {
        toks.push(AutolinkOrHtmlStart({ start: k }))
        k + 1
      }
      ')' => {
        toks.push(RightParen({ start: k }))
        k + 1
      }
      '~' if exts => tokens_try_add_strikethrough_marks(toks, s, line, start=k)
      '$' if exts => tokens_try_add_math_span_marks(toks, s, line, start=k)
      _ => k + 1
    }
    continue lines, line, false, next
  }
  (cidx, toks, line)
}

// Making inlines and inline tokens

///|
fn Parser::break_inline(
  self : Parser,
  line : LineSpan,
  start~ : Int,
  break_ty~ : InlineBreakType,
  newline~ : LineSpan,
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

///|
fn Parser::try_add_text_inline(
  self : Parser,
  line : LineSpan,
  first~ : Int,
  last~ : Int,
  acc : Array[Inline],
) -> Unit {
  if first > last {
    return
  }
  let mut first = first
  if first == line.first {
    first = self.first_non_blank_in_span(line) // Strip leading blanks
  }
  acc.push(Text(self.clean_unesc_unref_span({ ..line, first, last })))
}

///|
fn Parser::inlines_inline(
  self : Parser,
  first~ : CharCodePos,
  last~ : CharCodePos,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  acc : Array[Inline],
) -> Inline {
  match acc {
    [i] => i
    is_ => {
      let text_loc = self.text_loc_of_lines(
        first~,
        last~,
        first_line~,
        last_line~,
      )
      Inlines({ v: is_, meta: self.meta(text_loc) })
    }
  }
}

///|
fn Parser::code_span_token(
  self : Parser,
  count~ : Int,
  first~ : CharCodePos,
  last~ : CharCodePos,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  spans : ArrayView[Span],
) -> Token {
  let text_loc = self.text_loc_of_lines(first~, last~, first_line~, last_line~)
  let code_layout = self.raw_tight_block_lines(spans~)
  let meta = self.meta(text_loc)
  let cs = CodeSpan({ v: { backticks: count, code_layout }, meta })
  Inline({ start: first, inline: cs, endline: last_line, next: last + 1 })
}

///|
fn Parser::autolink_token(
  self : Parser,
  line : LineSpan,
  first~ : Int,
  last~ : Int,
  is_email~ : Bool,
) -> Token {
  let meta = self.meta(self.text_loc_of_span({ ..line, first, last }))
  let link = { ..line, first: first + 1, last: last - 1 }
  let link = self.clean_unref_span(link)
  let inline = Autolink({ v: { link, is_email }, meta })
  Inline({ start: first, inline, endline: line, next: last + 1 })
}

///|
fn Parser::raw_html_token(
  self : Parser,
  first~ : Int,
  last~ : Int,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  spans : ArrayView[Span],
) -> Token {
  let _ = first_line
  let raw = Seq::from_array(self.raw_tight_block_lines(spans~))
  let text_loc = {
    let first = raw[0].node.meta.loc
    let { last: last_ccode, pos: last_line, .. } = spans[spans.length() - 1].span
    { ..first, last_ccode, last_line }
  }
  let inline = RawHtml({ v: raw, meta: self.meta(text_loc) })
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

///|
fn Parser::link_token(
  self : Parser,
  first~ : Int,
  last~ : Int,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  image~ : Bool,
  link : InlineLink,
) -> Token {
  let text_loc = self.text_loc_of_lines(first~, last~, first_line~, last_line~)
  let link = { v: link, meta: self.meta(text_loc) }
  let inline : Inline = if image { Image(link) } else { Link(link) }
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

///|
fn Parser::emphasis_token(
  self : Parser,
  first~ : Int,
  last~ : Int,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  strong~ : Bool,
  emph : Inline,
) -> Token {
  let text_loc = self.text_loc_of_lines(first~, last~, first_line~, last_line~)
  let delim = self.i[first].unsafe_to_char()
  let emph = { v: { delim, inline: emph }, meta: self.meta(text_loc) }
  let inline = if strong { StrongEmphasis(emph) } else { Emphasis(emph) }
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

///|
fn Parser::ext_strikethough_token(
  self : Parser,
  first~ : Int,
  last~ : Int,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  s : Inline,
) -> Token {
  let text_loc = self.text_loc_of_lines(first~, last~, first_line~, last_line~)
  let inline = ExtStrikethrough({ v: s, meta: self.meta(text_loc) })
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

///|
fn Parser::ext_math_span_token(
  self : Parser,
  count~ : Int,
  first~ : Int,
  last~ : Int,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  spans : ArrayView[Span],
) -> Token {
  let textloc = self.text_loc_of_lines(first~, last~, first_line~, last_line~)
  let tex_layout = self.raw_tight_block_lines(spans~)
  let meta = self.meta(textloc)
  let ms = { display: count == 2, tex_layout }
  let inline = ExtMathSpan({ v: ms, meta })
  Inline({ start: first, inline, endline: last_line, next: last + 1 })
}

// Parsers

///| https://spec.commonmark.org/current/#code-span
/// Tries to push an inline code span to the `rev_toks` stack.
/// If this function returns `Some((line_span, token))`, it means the stack has been modified.
fn Parser::try_code(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  start~ : CharCodePos,
  count~ : Int,
  escaped~ : Bool,
) -> (LineSpan, Token)? {
  let cstart = start
  guard not(escaped) && self.cidx.has_backticks(count~, after=cstart) else {
    None
  }
  let first = cstart + count
  let mut line = { ..start_line, first, }
  let spans = []
  let mut k = first
  let old_rev_toks = rev_toks.val.inner().copy()
  for {
    match rev_toks.val.pop() {
      None => break
      Some(Backticks({ start, count: c, .. })) => {
        guard c == count else { continue }
        let span : Span = {
          start: line.first,
          span: { ..line, first: k, last: start - 1 },
        }
        spans.push(span)
        let t = self.code_span_token(
          count~,
          first=cstart,
          last=start + count - 1,
          first_line=start_line,
          last_line=line,
          spans[:],
        )
        return Some((line, t))
      }
      Some(Newline({ newline, .. })) => {
        let span : Span = { start: line.first, span: { ..line, first: k } }
        spans.push(span)
        k = self.first_non_blank_in_span(newline)
        line = newline
      }
      Some(_) => continue
    }
  }
  rev_toks.val = old_rev_toks
  None
}

///|
/// Tries to push an inline math span to the `rev_toks` stack.
/// If this function returns `Some((line_span, token))`, it means the stack has been modified.
fn Parser::try_math_span(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  start~ : CharCodePos,
  count~ : Int,
) -> (LineSpan, Token)? {
  let cstart = start
  guard self.cidx.has_math_span(count~, after=cstart) else { None }
  let old_rev_toks = rev_toks.val.inner().copy()
  let first = cstart + count
  let mut line = { ..start_line, first, }
  let spans = []
  let mut k = first
  for {
    match rev_toks.val.pop() {
      None => break
      Some(MathSpanMarks({ start, count: c, may_close, .. })) => {
        guard c == count && may_close else { continue }
        let span : Span = {
          start: line.first,
          span: { ..line, first: k, last: start - 1 },
        }
        spans.push(span)
        let t = self.ext_math_span_token(
          count~,
          first=cstart,
          last=start + count - 1,
          first_line=start_line,
          last_line=line,
          spans[:],
        )
        return Some((line, t))
      }
      Some(Newline({ newline, .. })) => {
        let span : Span = { start: line.first, span: { ..line, first: k } }
        spans.push(span)
        k = self.first_non_blank_in_span(newline)
        line = newline
      }
      Some(_) => continue
    }
  }
  rev_toks.val = old_rev_toks
  None
}

///|
/// Tries to push an inline emphasis to the `rev_toks` stack.
/// If this function returns `Some((line_span, token))`, it means the stack has been modified.
fn Parser::try_autolink_or_html(
  self : Parser,
  rev_toks : Ref[RevTokens],
  line : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Token)? {
  // Weirdly, there's seemingly no `if let` in Moonbit.
  if @cmark_base.autolink_uri(self.i, last=line.last, start~) is Some(last) {
    let t = self.autolink_token(line, first=start, last~, is_email=false)
    tokens_pop_until(start=last + 1, rev_toks.val)
    return Some((line, t))
  }
  if @cmark_base.autolink_email(self.i, last=line.last, start~) is Some(last) {
    let t = self.autolink_token(line, first=start, last~, is_email=true)
    tokens_pop_until(start=last + 1, rev_toks.val)
    return Some((line, t))
  }
  guard @cmark_base.raw_html(
      next_line=tokens_next_line,
      self.i,
      rev_toks.val,
      line~,
      start~,
    )
    is Some((last_line, spans, last)) else {
    None
  }
  let first = start
  let first_line = line
  let t = self.raw_html_token(first~, last~, first_line~, last_line~, spans[:])
  tokens_pop_until(start=last + 1, rev_toks.val)
  Some((last_line, t))
}

///|
fn Parser::label_of_spans(
  self : Parser,
  key~ : String,
  spans : ArrayView[Span],
) -> Label {
  let meta = if self.no_locs || spans.length() == 0 {
    Meta::none()
  } else {
    self.meta_of_spans(first=spans[0].span, last=spans[spans.length() - 1].span)
  }
  let text = self.tight_block_lines(spans~)
  { meta, key, text }
}

///| https://spec.commonmark.org/current/#full-reference-link
/// If the function returns `Some(Some(_))`, it means the `rev_toks` stack has been modified.
fn Parser::try_full_reflink_remainder(
  self : Parser,
  rev_toks : Ref[RevTokens],
  line : LineSpan,
  image~ : Bool,
  start~ : CharCodePos,
) -> (LineSpan, ReferenceKind, CharCodePos)?? {
  guard @cmark_base.link_label(
      self.buf,
      next_line=tokens_next_line,
      self.i,
      rev_toks.val,
      line~,
      start~,
    )
    is Some((line, spans, last, key)) else {
    None
  }
  let ref_ = self.label_of_spans(key~, spans[:])
  guard self.find_def_for_ref(image~, ref_) is Some(def) else { Some(None) }
  tokens_drop_stop_after_right_brack(rev_toks.val)
  Some(Some((line, ReferenceKind::Ref(Full, ref_, def), last)))
}

///| https://spec.commonmark.org/current/#shortcut-reference-link
/// If the function returns `Some(Some(_))`, it means the `rev_toks` stack has been modified.
fn Parser::try_shortcut_reflink(
  self : Parser,
  rev_toks : Ref[RevTokens],
  line : LineSpan,
  image~ : Bool,
  start~ : CharCodePos,
) -> (LineSpan, ReferenceKind, CharCodePos)? {
  let start = start + image.to_int() // [
  guard @cmark_base.link_label(
      self.buf,
      next_line=tokens_next_line,
      self.i,
      rev_toks.val,
      line~,
      start~,
    )
    is Some((line, spans, last, key)) else {
    None
  }
  let ref_ = self.label_of_spans(key~, spans[:])
  guard self.find_def_for_ref(image~, ref_) is Some(def) else { None }
  tokens_drop_stop_after_right_brack(rev_toks.val)
  Some((line, ReferenceKind::Ref(Shortcut, ref_, def), last))
}

///| https://spec.commonmark.org/current/#collapsed-reference-link
/// If the function returns `Some()`, it means the `rev_toks` stack has been modified.
fn Parser::try_collapsed_reflink(
  self : Parser,
  rev_toks : Ref[RevTokens],
  line : LineSpan,
  image~ : Bool,
  start~ : CharCodePos,
) -> (LineSpan, ReferenceKind, CharCodePos)? {
  let start = start + image.to_int() // [
  guard @cmark_base.link_label(
      self.buf,
      next_line=tokens_next_line,
      self.i,
      rev_toks.val,
      line~,
      start~,
    )
    is Some((line, spans, last, key)) else {
    None
  }
  let ref_ = self.label_of_spans(key~, spans[:])
  let last = last + 2 // ][]
  guard self.find_def_for_ref(image~, ref_) is Some(def) else { None }
  tokens_drop_stop_after_right_brack(rev_toks.val)
  tokens_drop_stop_after_right_brack(rev_toks.val)
  Some((line, ReferenceKind::Ref(Collapsed, ref_, def), last))
}

///| https://spec.commonmark.org/current/#inline-link
/// If the function returns `Some(_)`, it means the `rev_toks` stack has been modified.
fn Parser::try_inline_link_remainder(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  image~ : Bool,
  start~ : CharCodePos,
) -> (LineSpan, ReferenceKind, CharCodePos)? {
  let _ = image
  let st = start
  guard self.cidx.has_right_paren(after=st) else { None }
  guard self.first_non_blank_over_nl(
      next_line=tokens_next_line,
      rev_toks.val,
      start_line,
      start=st + 1,
    )
    is Some((line, before_dest, start)) else {
    None
  }
  let (line, angled_dest, dest, start) = match
    @cmark_base.link_destination(self.i, last=line.last, start~) {
    None => (line, false, None, start)
    Some((angled, first, last)) => {
      let dest = self.clean_unesc_unref_span({ ..line, first, last })
      let next = last + 1 + angled.to_int()
      (line, angled, Some(dest), next)
    }
  }
  let (line, after_dest, title_open_delim, title, start) = match
    self.first_non_blank_over_nl(
      next_line=tokens_next_line,
      rev_toks.val,
      line,
      start~,
    ) {
    None => (line, [], '"', None, start)
    Some((line, after_dest, start1)) =>
      if start1 == start {
        (line, [], '"', None, start)
      } else {
        let start = start1
        match
          @cmark_base.link_title(
            next_line=tokens_next_line,
            self.i,
            rev_toks.val,
            line~,
            start~,
          ) {
          None => (line, after_dest, '"', None, start)
          Some((line, spans, last)) => {
            let title : Seq[_] = self.tight_block_lines(spans=spans[:])
            (
              line,
              after_dest,
              self.i[start].unsafe_to_char(),
              Some(title),
              last + 1,
            )
          }
        }
      }
  }
  let (line, after_title, last) = self
    .first_non_blank_over_nl(
      next_line=tokens_next_line,
      rev_toks.val,
      line,
      start~,
    )
    .unwrap_or((line, [], start))
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
  tokens_pop_until(start=last + 1, rev_toks.val)
  Some((line, Inline(ld), last))
}

///| If the function returns `Some(_)`, it means the `rev_toks` stack has been modified.
/// https://spec.commonmark.org/current/#link-text

///|
fn Parser::find_link_text_tokens(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Tokens, CharCodePos)? {
  let _ = start
  let mut line = start_line
  let mut nest = 0
  let acc : Tokens = @deque.new()
  let old_rev_toks = rev_toks.val.inner().copy()
  for {
    match (rev_toks.val.pop(), nest) {
      (Some(RightBrack({ start: last })), 0) => {
        tokens_shorten_last_line(to_last=last - 1, acc)
        return Some((line, acc, last))
      }
      (Some(Backticks({ start, count, escaped })), _) =>
        if self.try_code(rev_toks, line, start~, count~, escaped~)
          is Some((line_, t)) {
          line = line_
          acc.push(t)
        }
      (Some(MathSpanMarks({ start, count, may_open, .. })), _) => {
        guard may_open &&
          self.try_math_span(rev_toks, line, start~, count~) is Some((line_, t)) else {
          continue
        }
        line = line_
        acc.push(t)
      }
      (Some(AutolinkOrHtmlStart({ start })), _) => {
        guard self.try_autolink_or_html(rev_toks, line, start~)
          is Some((line_, t)) else {
          continue
        }
        line = line_
        acc.push(t)
      }
      (Some(RightBrack(_) as t), _) => {
        acc.push(t)
        nest -= 1
      }
      (Some(LinkStart(_) as t), _) => {
        acc.push(t)
        nest += 1
      }
      (Some(Newline({ newline: l, .. }) | Inline({ endline: l, .. }) as t), _) => {
        line = l
        acc.push(t)
      }
      (Some(t), _) => acc.push(t)
      (None, _) => break
    }
  }
  rev_toks.val = old_rev_toks
  None
}

///|
/// Tries to push a link definition to the `rev_toks` stack.
/// If this function returns `Some((line_span, token, had_link))`, it means the stack has been modified.
fn Parser::try_link_def(
  self : Parser,
  start~ : CharCodePos,
  start_rev_toks~ : Ref[RevTokens],
  start_line~ : LineSpan,
  rev_toks~ : Ref[RevTokens],
  line~ : LineSpan,
  text_last~ : CharCodePos,
  image~ : Bool,
  text : Array[Inline],
) -> (LineSpan, Token, Bool)? {
  let next = text_last + 1
  let old_rev_toks = start_rev_toks.val.inner().copy()
  let link = if next > line.last {
    self.try_shortcut_reflink(start_rev_toks, start_line, image~, start~)
  } else {
    match self.i[next] {
      '(' =>
        match
          self.try_inline_link_remainder(rev_toks, line, image~, start=next) {
          None =>
            self.try_shortcut_reflink(
              start_rev_toks,
              start_line,
              image~,
              start~,
            )
          Some(_) as v => v
        }
      '[' => {
        let next1 = next + 1
        if next1 <= line.last && self.i[next1] == ']' {
          self.try_collapsed_reflink(start_rev_toks, start_line, image~, start~)
        } else {
          let r = self.try_full_reflink_remainder(
            rev_toks,
            line,
            image~,
            start=next,
          )
          match r {
            None =>
              self.try_shortcut_reflink(
                start_rev_toks,
                start_line,
                image~,
                start~,
              )
            Some(None) => None
            Some(Some(_) as v) => v
          }
        }
      }
      _ => self.try_shortcut_reflink(start_rev_toks, start_line, image~, start~)
    }
  }
  guard link is Some((endline, reference, last)) else {
    start_rev_toks.val = old_rev_toks
    return None
  }
  let first = start
  let text = self.inlines_inline(
    first~,
    last=text_last,
    first_line=start_line,
    last_line=line,
    text,
  )
  let link : InlineLink = { text, reference }
  let t = self.link_token(
    first~,
    last~,
    first_line=start_line,
    last_line=endline,
    image~,
    link,
  )
  let had_link = not(image) && not(self.nested_links)
  Some((endline, t, had_link))
}

// The following sequence of mutually recursive functions define
// inline parsing.

// First pass

///|
/// Tries to push a link to the `start_rev_toks` stack.
/// If this function returns `Some((line_span, token))`, it means the stack has been modified.
fn Parser::try_link(
  self : Parser,
  start_rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  image~ : Bool,
  start~ : CharCodePos,
) -> (LineSpan, Token, Bool)? {
  let rev_toks : Ref[RevTokens] = Ref::new(start_rev_toks.val.inner().copy())
  guard self.cidx.has_right_brack(after=start) else { return None }
  guard self.find_link_text_tokens( // text_last with ] delim 
      rev_toks,
      start_line,
      start~,
    )
    is Some((line, text_toks, text_last)) else {
    None
  }
  let (text, had_link) = self.parse_tokens(
    text_toks.inner(),
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
  if had_link && not(image) {
    return None
  }
  self
  .try_link_def(
    start~,
    start_rev_toks~,
    start_line~,
    rev_toks~,
    line~,
    text_last~,
    image~,
    text,
  )
  .map(fn(it) {
    start_rev_toks.val = rev_toks.val
    it
  })
}

///| Parse inline atoms and links.
/// Links are parsed here otherwise link reference data gets parsed as atoms.
fn Parser::first_pass(
  self : Parser,
  toks : Ref[Tokens],
  line : LineSpan,
) -> Bool {
  let acc : Tokens = @deque.new()
  let mut had_link = false
  let mut line = line
  let rev_toks : Ref[RevTokens] = Ref::new(toks.val.inner())
  while rev_toks.val.pop() is Some(t) {
    match t {
      Backticks({ start, count, escaped }) =>
        if self.try_code(rev_toks, line, start~, count~, escaped~)
          is Some((line_, t)) {
          line = line_
          acc.push(t)
        }
      MathSpanMarks({ start, count, may_open, .. }) => {
        guard may_open &&
          self.try_math_span(rev_toks, line, start~, count~) is Some((line_, t)) else {
          continue
        }
        line = line_
        acc.push(t)
      }
      AutolinkOrHtmlStart({ start }) =>
        if self.try_autolink_or_html(rev_toks, line, start~) is Some((line_, t)) {
          line = line_
          acc.push(t)
        }
      LinkStart({ start, image }) =>
        if self.try_link(rev_toks, line, image~, start~)
          is Some((l, t, had_link_)) {
          acc.push(t)
          line = l
          had_link = had_link_
        }
      RightBrack(_) => ()
      Newline({ newline, .. }) as nl => {
        line = newline
        acc.push(nl)
      }
      t => acc.push(t)
    }
  }
  toks.val = acc
  had_link
}

// Second pass

///|
fn Parser::find_emphasis_text(
  self : Parser,
  rev_toks : Ref[RevTokens],
  line : LineSpan,
  opener~ : TokenEmphasisMarks,
) -> (LineSpan, Int, Tokens, TokenEmphasisMarks)? {
  fn marks_match(marks : TokenEmphasisMarks, opener : TokenEmphasisMarks) {
    opener.char == marks.char &&
    (
      (marks.may_open || not(opener.may_close)) ||
      marks.count % 3 == 0 ||
      (opener.count + marks.count) % 3 != 0
    )
  }

  fn marks_has_precedence(
    marks : TokenEmphasisMarks,
    opener : TokenEmphasisMarks,
  ) {
    if marks.char == opener.char {
      return true // Rule 16
    }
    // Rule 15
    let after = marks.start
    self.cidx.emphasis_pos(char=marks.char, after~) <
    self.cidx.emphasis_pos(char=opener.char, after~)
  }

  let mut line = line
  let acc : Tokens = @deque.new()
  for {
    match rev_toks.val.pop() {
      None => break
      Some(EmphasisMarks(marks) as t) => {
        let after = marks.start
        if marks.may_close && marks_match(marks, opener) {
          let used = if marks.count >= 2 && opener.count >= 2 { 2 } else { 1 }
          let to_last = marks.start - 1
          tokens_shorten_last_line(to_last~, acc)
          return Some((line, used, acc, marks))
        } else if marks.may_open && marks_has_precedence(marks, opener) {
          if self.try_emphasis(rev_toks, line, opener=marks) is Some(l) {
            line = l
          }
        } else {
          acc.push(t)
          guard self.cidx.has_emphasis(char=opener.char, after~) else { break }
        }
      }
      Some(Newline({ newline: l, .. }) | Inline({ endline: l, .. }) as t) => {
        line = l
        acc.push(t)
      }
      Some(t) => acc.push(t)
    }
  }
  for i = acc.inner().length() - 1; i >= 0; i = i - 1 {
    rev_toks.val.push(acc.inner()[i])
  }
  None
}

///|
/// Tries to push an emphasis to the `rev_toks` stack.
/// If this function returns `Some(line_span)`, it means the stack has been modified.
fn Parser::try_emphasis(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  opener~ : TokenEmphasisMarks,
) -> LineSpan? {
  let start = opener.start
  guard self.cidx.has_emphasis(char=opener.char, after=start) else { None }
  guard self.find_emphasis_text(rev_toks, start_line, opener~)
    is Some((line, used, emph_toks, closer)) else {
    None
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
    let emph_toks = Ref::new(emph_toks)
    self.second_pass(emph_toks, text_start)
    let text = self.last_pass(emph_toks.val, text_start)
    self.inlines_inline(first~, last=text_last, first_line~, last_line~, text)
  }
  let count = closer.count - used
  if count != 0 {
    rev_toks.val.push(EmphasisMarks({ ..closer, start: last + 1, count }))
  }
  let emph = self.emphasis_token(
    first~,
    last~,
    first_line~,
    last_line~,
    strong=used == 2,
    emph,
  )
  rev_toks.val.push(emph)
  let count = opener.count - used
  if count != 0 {
    rev_toks.val.push(EmphasisMarks({ ..opener, count, }))
  }
  Some(line)
}

///|
/// Tries to extract stricken-through tokens from the `rev_toks` stack and collect them into `striken_toks`.
/// If this function returns `Some((line_span, stricken_toks, closer))`, it means the stack has been modified.
fn Parser::find_strikethrough_text(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
) -> (LineSpan, Tokens, TokenStrikethroughMarks)? {
  let acc : Tokens = @deque.new()
  let mut line = start_line
  for {
    match rev_toks.val.pop() {
      None => break
      Some(StrikethroughMarks(marks)) =>
        if marks.may_close {
          let to_last = marks.start - 1
          tokens_shorten_last_line(to_last~, acc)
          return Some((line, acc, marks))
        } else if marks.may_open {
          if self.try_strikethrough(rev_toks, line, opener=marks) is Some(l) {
            line = l
          }
        } else {
          abort("unreachable")
        }
      Some(Newline({ newline: l, .. }) | Inline({ endline: l, .. }) as t) => {
        acc.push(t)
        line = l
      }
      Some(t) => acc.push(t)
    }
  }
  for i = acc.inner().length() - 1; i >= 0; i = i - 1 {
    rev_toks.val.push(acc.inner()[i])
  }
  None
}

///|
/// Tries to push a strikethrough to the `rev_toks` stack.
/// If this function returns `Some(line_span)`, it means the stack has been modified.
fn Parser::try_strikethrough(
  self : Parser,
  rev_toks : Ref[RevTokens],
  start_line : LineSpan,
  opener~ : TokenStrikethroughMarks,
) -> LineSpan? {
  let start = opener.start
  guard self.cidx.has_strikethrough(after=start) else { None }
  guard self.find_strikethrough_text(rev_toks, start_line)
    is Some((line, stricken_toks, closer)) else {
    None
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
    let emph_toks = Ref::new(stricken_toks)
    self.second_pass(emph_toks, text_start)
    let text = self.last_pass(emph_toks.val, text_start)
    self.inlines_inline(first~, last~, first_line~, last_line~, text)
  }
  rev_toks.val.push(
    self.ext_strikethough_token(
      first=opener.start,
      last=closer.start + 1,
      first_line~,
      last_line~,
      text,
    ),
  )
  Some(line)
}

///|
fn Parser::second_pass(
  self : Parser,
  toks : Ref[Tokens],
  line : LineSpan,
) -> Unit {
  let rev_toks : Ref[RevTokens] = Ref::new(toks.val.inner())
  let acc : Tokens = @deque.new()
  toks.val = acc
  let mut line = line
  for {
    match rev_toks.val.pop() {
      None => break
      Some(EmphasisMarks(opener)) =>
        if opener.may_open &&
          self.try_emphasis(rev_toks, line, opener~) is Some(l) {
          line = l
        }
      Some(StrikethroughMarks(opener)) =>
        if opener.may_open &&
          self.try_strikethrough(rev_toks, line, opener~) is Some(l) {
          line = l
        }
      Some(Newline({ newline: l, .. }) | Inline({ endline: l, .. }) as t) => {
        acc.push(t)
        line = l
      }
      Some(t) => acc.push(t)
    }
  }
}

// Last pass

///| 
/// Only `Inline` and `Newline` tokens remain. We fold over them to
/// convert them to `inline` values and `Break`s. `Text` inlines
/// are created for data between them.
fn Parser::last_pass(
  self : Parser,
  toks : Tokens,
  line : LineSpan,
) -> Array[Inline] {
  let acc = []
  let mut line = line
  let mut k = line.first
  for tok in toks.inner() {
    match tok {
      Newline({ start, break_ty, newline }) => {
        self.try_add_text_inline(line, first=k, last=start - 1, acc)
        let break_ = self.break_inline(line, start~, break_ty~, newline~)
        line = newline
        acc.push(break_)
        k = newline.first
      }
      Inline({ start, inline, endline, next }) => {
        self.try_add_text_inline(line, first=k, last=start - 1, acc)
        match inline {
          Inlines({ v: is_, .. }) => acc.push_iter(is_.iter())
          i => acc.push(i)
        }
        line = endline
        k = next
      }
      _ => abort("unreachable")
    }
  }
  self.try_add_text_inline(line, first=k, last=line.last, acc)
  acc
}

///|
fn Parser::parse_tokens(
  self : Parser,
  toks : Tokens,
  first_line : LineSpan,
) -> (Array[Inline], Bool) {
  let toks = Ref::new(toks)
  let had_link = self.first_pass(toks, first_line)
  self.second_pass(toks, first_line)
  let inlines = self.last_pass(toks.val, first_line)
  (inlines, had_link)
}

///|
fn Parser::strip_paragraph(
  self : Parser,
  lines : Array[LineSpan],
) -> ((Col, String), Meta, Array[LineSpan]) {
  let (last, trailing_blanks) = {
    guard lines.pop() is Some(line)
    let { first, last: start, .. } = line
    let non_blank = @cmark_base.last_non_blank(self.i, first~, start~)
    let last = { ..line, last: non_blank }
    let trailing_blanks = self.layout_clean_raw_span1({
      ..line,
      first: non_blank + 1,
    })
    (last, trailing_blanks)
  }
  lines.push(last)
  let (first, leading_indent) = {
    let line = lines[0]
    let non_blank = self.first_non_blank_in_span(line)
    let first = { ..line, first: non_blank }
    let leading_indent = non_blank - line.first
    (first, leading_indent)
  }
  lines[0] = first
  ((leading_indent, trailing_blanks), self.meta_of_spans(first~, last~), lines)
}

///|
fn Parser::parse_inline(
  self : Parser,
  lines : Array[LineSpan],
) -> ((Col, String), Inline) {
  let (layout, meta, lines) = self.strip_paragraph(lines)
  let (cidx, toks, first_line) = tokenize(self.i, lines, exts=self.exts)
  self.cidx = cidx
  let (is_, _) = self.parse_tokens(toks, first_line)
  let inline = match is_ {
    [i] => i
    _ => Inlines({ v: is_, meta })
  }
  (layout, inline)
}

// Parsing table rows

///|
fn Parser::get_blanks(
  self : Parser,
  line : LineSpan,
  before~ : CharCodePos,
  k : CharCodePos,
) -> (String, CharCodePos) {
  let nb = @cmark_base.first_non_blank(self.i, last=before - 1, start=k)
  let line = { ..line, first: k, last: nb - 1 }
  (self.layout_clean_raw_span1(line), nb)
}

///|
fn Parser::make_col(self : Parser, is_ : Array[Inline]) -> Inline {
  match is_ {
    [] => abort("unreachable")
    [i] => i
    is_ => {
      let first = is_[0].meta()
      let last = is_[is_.length() - 1].meta()
      let meta = self.meta_of_metas(first~, last~)
      Inlines({ v: is_, meta })
    }
  }
}

///|
fn Parser::find_pipe(
  self : Parser,
  line : LineSpan,
  before~ : CharCodePos,
  k : CharCodePos,
) -> Result[(Inline?, String, Col), Inline] {
  fn text(first, last) {
    let line = { ..line, first, last }
    Text(self.clean_unesc_unref_span(line))
  }

  let n = @cmark_base.first_non_escaped_char(
    '|',
    self.i,
    last=before - 1,
    start=k,
  )
  if n == before {
    return Err(text(k, n - 1))
  }
  let nb = @cmark_base.last_non_blank(self.i, first=k, start=n - 1)
  let after = self.layout_clean_raw_span1({ ..line, first: nb + 1, last: n - 1 })
  let text = if nb < k { None } else { Some(text(k, nb)) }
  Ok((text, after, n + 1))
}

///|
fn Parser::start_col(
  self : Parser,
  line : LineSpan,
  before~ : CharCodePos,
  k : CharCodePos,
) -> StartColResult {
  let (bbefore, k) = self.get_blanks(line, before~, k)
  if k >= before {
    return Start(bbefore, [])
  }
  match self.find_pipe(line, before~, k) {
    Err(text) => Start(bbefore, [text])
    Ok((text, bafter, k)) => {
      let text = text.unwrap_or_else(fn() {
        let l = self.text_loc_of_span({ ..line, first: k, last: k - 1 })
        Inlines({ v: [], meta: self.meta(l) })
      })
      Col((text, (bbefore, bafter)), k)
    }
  }
}

///|
priv enum StartColResult {
  Col((Inline, TableCellLayout), CharCodePos)
  Start(String, Array[Inline])
} derive(Show, ToJson)

///|
test {
  // Prevent warning about unused Show and ToJson
  (fn(s : StartColResult) { s.to_string() }) |> ignore()
  (fn(s : StartColResult) { s.to_json() }) |> ignore()
}

///|
fn Parser::finish_col(
  self : Parser,
  line : LineSpan,
  blanks_before : String,
  is_ : Array[Inline],
  toks : Tokens,
  k : CharCodePos,
) -> ((Inline, TableCellLayout), CharCodePos) {
  for k = k {
    if toks.inner().is_empty() {
      guard self.find_pipe(line, before=line.last + 1, k)
        is Ok((text, after, k))
      is_.push_iter(text.iter())
      break ((self.make_col(is_), (blanks_before, after)), k)
    }
    guard toks.inner().front() is Some(Inline({ start, inline, next, .. }))
    if k >= start {
      toks.inner().unsafe_pop_front()
      is_.push(inline)
      continue k
    }
    break match self.find_pipe(line, before=start, k) {
      Err(text) => {
        is_.push(text)
        is_.push(inline)
        toks.inner().unsafe_pop_front()
        continue next
      }
      Ok((text, after, k)) => {
        is_.push_iter(text.iter())
        ((self.make_col(is_), (blanks_before, after)), k)
      }
    }
  }
}

///|
fn Parser::parse_cols(
  self : Parser,
  line : LineSpan,
  acc : Array[(Inline, TableCellLayout)],
  toks : Tokens,
  k : CharCodePos,
) -> Unit {
  for line = line, k = k {
    if toks.inner().is_empty() {
      guard k <= line.last else { break }
      guard self.start_col(line, before=line.last + 1, k) is Col(col, k)
      acc.push(col)
      continue line, k
    }
    guard toks.inner().front() is Some(Inline({ start, inline, next, .. }))
    match self.start_col(line, before=start, k) {
      Col(col, k) => {
        acc.push(col)
        continue line, k
      }
      Start(before, is_) => {
        toks.inner().unsafe_pop_front()
        is_.push(inline)
        let (col, k) = self.finish_col(line, before, is_, toks, next)
        acc.push(col)
        continue line, k
      }
    }
  }
}

///|
fn Parser::parse_table_row(
  self : Parser,
  line : LineSpan,
) -> Array[(Inline, TableCellLayout)] {
  let (cidx, toks, first_line) = tokenize(self.i, [line], exts=self.exts)
  self.cidx = cidx
  let toks : Ref[Tokens] = Ref::new(toks)
  let _ = self.first_pass(toks, first_line)
  self.second_pass(toks, first_line)
  // We now have modified last pass, inner inlines will have gone through
  // the regular `last_pass` which is fine since we are only interested
  // in creating the toplevel text nodes further splited on (unescaped) `\`.
  let rows = []
  self.parse_cols(line, rows, toks.val, line.first)
  rows
}

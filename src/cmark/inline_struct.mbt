// Inline structure parsing

///|
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
priv enum Token {
  AutolinkOrHtmlStart(TokenStart)
  Backticks(TokenBackticks)
  EmphasisMarks(TokenEmphasisMarks)
  Inline(TokenInline)
  LinkStart(TokenLinkStart)
  Newline(TokenNewline)
  RightBrack(TokenStart)
  StrikethroughMarks(TokenStrikethroughMarks)
  MathSpanMarks(TokenMathSpanMarks)
} derive(Debug)

///|
priv struct TokenStart {
  start : CharCodePos
} derive(Debug)

///|
priv struct TokenBackticks {
  start : CharCodePos
  count : Int
  escaped : Bool
} derive(Debug)

///|
priv struct TokenEmphasisMarks {
  start : CharCodePos
  char : Char
  /// The number of marks left in the run.
  count : Int
  /// The length of the delimiter run in the source (for the rule of 3).
  run_length : Int
  may_open : Bool
  may_close : Bool
} derive(Debug)

///|
priv struct TokenInline {
  start : CharCodePos
  inline : Inline
  endline : LineSpan
  next : CharCodePos
} derive(Debug)

///|
priv struct TokenLinkStart {
  start : CharCodePos
  image : Bool
} derive(Debug)

///|
priv struct TokenNewline {
  /// Points at spaces or `\` on the broken line
  start : CharCodePos
  break_ty : InlineBreakType
  newline : LineSpan
} derive(Debug)

///|
priv struct TokenStrikethroughMarks {
  start : CharCodePos
  may_open : Bool
  may_close : Bool
} derive(Debug)

///|
priv struct TokenMathSpanMarks {
  start : CharCodePos
  count : Int
  may_open : Bool
  may_close : Bool
} derive(Debug)

///|
fn Token::start(self : Token) -> CharCodePos {
  match self {
    AutolinkOrHtmlStart(t) => t.start
    Backticks(t) => t.start
    EmphasisMarks(t) => t.start
    Inline(t) => t.start
    LinkStart(t) => t.start
    Newline(t) => t.start
    RightBrack(t) => t.start
    StrikethroughMarks(t) => t.start
    MathSpanMarks(t) => t.start
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
fn CloserIndex::has_math_span(
  self : CloserIndex,
  count~ : Int,
  after~ : Int,
) -> Bool {
  self.exists(MathSpanMarks(count), after~)
}

///|
/// Used to make the text delimitation precise for nested inlines.
fn tokens_shorten_last_line(to_last~ : Int, toks : Tokens) -> Unit {
  let last = to_last
  for i = toks.0.length() - 1; i >= 0; i = i - 1 {
    match toks.0[i] {
      Newline({ newline, .. } as nl) => {
        toks.0[i] = Newline({ ..nl, newline: { ..newline, last, }, })
        break
      }
      Inline({ endline, .. } as il) => {
        toks.0[i] = Inline({ ..il, endline: { ..endline, last, }, })
        break
      }
      _ => ()
    }
  }
}

///|
fn tokens_drop_stop_after_right_brack(rev_toks : RevTokens) -> Unit {
  for ;; {
    match rev_toks.pop() {
      None | Some(RightBrack(_)) => break
      Some(_) => continue
    }
  }
}

///|
fn tokens_pop_until(start~ : Int, rev_toks : RevTokens) -> Unit {
  for ;; {
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
  tokens_next_line_consumed(rev_toks, [])
}

///|
/// Drops the tokens of `rev_toks` up to and including the next newline,
/// pushes them on `consumed` and returns the newline's line. Leaves
/// `rev_toks` and `consumed` untouched if there is no newline.
fn tokens_next_line_consumed(
  rev_toks : RevTokens,
  consumed : Array[Token],
) -> LineSpan? {
  let len = consumed.length()
  while rev_toks.pop() is Some(t) {
    consumed.push(t)
    if t is Newline({ newline, .. }) {
      return Some(newline)
    }
  }
  while consumed.length() > len {
    rev_toks.push(consumed.unsafe_pop())
  }
  None
}

///|
/// Puts back on `rev_toks` the tokens `consumed` by
/// `tokens_next_line_consumed`.
fn tokens_restore(rev_toks : RevTokens, consumed : Array[Token]) -> Unit {
  while consumed.pop() is Some(t) {
    rev_toks.push(t)
  }
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
  // The final `\` must not be escaped by another `\`
  let escaped_bslash = fn() {
    for k = last - 1, escaped = false {
      guard k >= first && s[k] == '\\' else { break escaped }
      continue k - 1, !escaped
    }
  }
  let (start, break_ty) = if non_space == last &&
    s[non_space] == '\\' &&
    !escaped_bslash() {
    (non_space, Hard)
  } else {
    let start = non_space + 1
    (start, if last - start + 1 >= 2 { Hard } else { Soft })
  }
  Newline({ start, break_ty, newline, })
}

///|
fn tokens_add_backtick(
  toks : Tokens,
  cidx : CloserIndex,
  s : String,
  line : LineSpan,
  prev_bslash~ : Bool,
  start~ : Int,
) -> Int {
  let last = @cmark_base.run_of(char='`', s, last=line.last, start=start + 1)
  let count = last - start + 1
  toks.push(Backticks({ start, count, escaped: prev_bslash, }))
  cidx.add(Backticks(count), start)
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
  toks.push(LinkStart({ start, image: true, }))
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
  let is_prev_white = is_whitespace(prev_char)
  let is_prev_punct = is_unicode_punctuation(prev_char)
  let is_next_white = is_whitespace(next_char)
  let is_next_punct = is_unicode_punctuation(next_char)
  let is_left_flanking = !is_next_white &&
    (!is_next_punct || is_prev_white || is_prev_punct)
  let is_right_flanking = !is_prev_white &&
    (!is_prev_punct || is_next_white || is_next_punct)
  let next = run_last + 1
  guard is_left_flanking || is_right_flanking else { next }
  let may_open = (char == '*' && is_left_flanking) ||
    (char == '_' && is_left_flanking && (!is_right_flanking || is_prev_punct))
  let may_close = (char == '*' && is_right_flanking) ||
    (char == '_' && is_right_flanking && (!is_left_flanking || is_next_punct))
  guard may_open || may_close else { next }
  toks.push(
    EmphasisMarks({
      start,
      char,
      count,
      run_length: count,
      may_open,
      may_close,
    }),
  )
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
  let may_open = !@char.is_ascii_whitespace(next_char)
  let may_close = !@char.is_ascii_whitespace(prev_char)
  toks.push(StrikethroughMarks({ start, may_open, may_close, }))
  next
}

///|
fn tokens_try_add_math_span_marks(
  toks : Tokens,
  cidx : CloserIndex,
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
    may_open = !@char.is_ascii_whitespace(next_char)
    may_close = !@char.is_ascii_whitespace(prev_char)
  }
  guard may_open || may_close else { next }
  toks.push(MathSpanMarks({ start, count, may_open, may_close, }))
  if may_close {
    cidx.add(MathSpanMarks(count), start)
  }
  next
}

///|
fn tokenize(
  exts~ : Bool,
  s : String,
  lines : Array[LineSpan],
) -> (CloserIndex, Tokens, LineSpan, Bool) {
  guard lines is [line, .. lines] else { abort("expected at least one line") }
  let toks : Tokens = Deque([])
  let cidx = CloserIndex::new()
  let only_newlines = for lines = lines, line = line, prev_bslash = false, k = line.first, only_newlines = true {
    if k > line.last {
      match lines {
        [] => break only_newlines
        [newline, .. lines] => {
          let t = Token::newline(s, line, newline)
          toks.push(t)
          continue lines, newline, false, newline.first, only_newlines
        }
      }
    }
    let (next, only_newlines) = match s[k] {
      '\\' => continue lines, line, !prev_bslash, k + 1, only_newlines
      '`' =>
        (tokens_add_backtick(toks, cidx, s, line, prev_bslash~, start=k), false)
      _ if prev_bslash => (k + 1, only_newlines)
      '*' | '_' => {
        let before = toks.0.length()
        let next = tokens_try_add_emphasis(toks, s, line, start=k)
        (next, only_newlines && toks.0.length() == before)
      }
      ']' => {
        toks.push(RightBrack({ start: k, }))
        cidx.add(RightBrack, k)
        (k + 1, false)
      }
      '[' => {
        toks.push(LinkStart({ start: k, image: false, }))
        (k + 1, false)
      }
      '!' => {
        let next = tokens_try_add_image_link_start(toks, s, line, start=k)
        (next, only_newlines && next == k + 1)
      }
      '<' => {
        toks.push(AutolinkOrHtmlStart({ start: k, }))
        (k + 1, false)
      }
      ')' => {
        cidx.add(RightParen, k)
        (k + 1, only_newlines)
      }
      '~' if exts => {
        let before = toks.0.length()
        let next = tokens_try_add_strikethrough_marks(toks, s, line, start=k)
        (next, only_newlines && toks.0.length() == before)
      }
      '$' if exts => {
        let before = toks.0.length()
        let next = tokens_try_add_math_span_marks(toks, cidx, s, line, start=k)
        (next, only_newlines && toks.0.length() == before)
      }
      _ => (k + 1, only_newlines)
    }
    continue lines, line, false, next, only_newlines
  }
  (cidx, toks, line, only_newlines)
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
  let layout_before = { ..line, first: start, }
  let layout_after = {
    let non_blank = self.first_non_blank_in_span(newline)
    { ..newline, last: non_blank - 1, }
  }
  let m = self.meta_of_spans(first=layout_before, last=layout_after)
  let layout_before = self.layout_clean_raw_span(layout_before)
  let layout_after = self.layout_clean_raw_span(layout_after)
  Break({ v: { ty: break_ty, layout_before, layout_after, }, meta: m, })
}

///|
fn Parser::try_add_text_inline(
  self : Parser,
  line : LineSpan,
  first~ : Int,
  last~ : Int,
  acc : Array[Inline],
  strip? : Bool = true,
) -> Unit {
  if first > last {
    return
  }
  let mut first = first
  if strip && first == line.first {
    first = self.first_non_blank_in_span(line) // Strip leading blanks
  }
  acc.push(Text(self.clean_unesc_unref_span({ ..line, first, last, })))
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
      Inlines({ v: is_, meta: self.meta(text_loc), })
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
  let cs = CodeSpan({ v: { backticks: count, code_layout, }, meta, })
  Inline({ start: first, inline: cs, endline: last_line, next: last + 1, })
}

///|
fn Parser::autolink_token(
  self : Parser,
  line : LineSpan,
  first~ : Int,
  last~ : Int,
  is_email~ : Bool,
) -> Token {
  let meta = self.meta(self.text_loc_of_span({ ..line, first, last, }))
  let link = { ..line, first: first + 1, last: last - 1, }
  let link = self.clean_unref_span(link)
  let inline = Autolink({ v: { link, is_email, }, meta, })
  Inline({ start: first, inline, endline: line, next: last + 1, })
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
    { ..first, last_ccode, last_line, }
  }
  let inline = RawHtml({ v: raw, meta: self.meta(text_loc), })
  Inline({ start: first, inline, endline: last_line, next: last + 1, })
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
  let link = { v: link, meta: self.meta(text_loc), }
  let inline : Inline = if image { Image(link) } else { Link(link) }
  Inline({ start: first, inline, endline: last_line, next: last + 1, })
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
  let emph = { v: { delim, inline: emph, }, meta: self.meta(text_loc), }
  let inline = if strong { StrongEmphasis(emph) } else { Emphasis(emph) }
  Inline({ start: first, inline, endline: last_line, next: last + 1, })
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
  let inline = ExtStrikethrough({ v: s, meta: self.meta(text_loc), })
  Inline({ start: first, inline, endline: last_line, next: last + 1, })
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
  let ms = { display: count == 2, tex_layout, }
  let inline = ExtMathSpan({ v: ms, meta, })
  Inline({ start: first, inline, endline: last_line, next: last + 1, })
}

// Parsers

///|
/// https://spec.commonmark.org/current/#code-span
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
  // If the run is preceded by a `\`, its first backtick is escaped: the
  // backtick string that opens starts after it.
  let (cstart, count) = if escaped {
    (start + 1, count - 1)
  } else {
    (start, count)
  }
  guard count > 0 && self.cidx.has_backticks(count~, after=cstart) else { None }
  let first = cstart + count
  let mut line = { ..start_line, first, }
  let spans = []
  let mut k = first
  let old_rev_toks = rev_toks.val.0.copy()
  for ;; {
    match rev_toks.val.pop() {
      None => break
      Some(Backticks({ start, count: c, .. })) => {
        guard c == count else { continue }
        let span : Span = {
          start: line.first,
          span: { ..line, first: k, last: start - 1, },
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
        let span : Span = { start: line.first, span: { ..line, first: k, }, }
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
  let old_rev_toks = rev_toks.val.0.copy()
  let first = cstart + count
  let mut line = { ..start_line, first, }
  let spans = []
  let mut k = first
  for ;; {
    match rev_toks.val.pop() {
      None => break
      Some(MathSpanMarks({ start, count: c, may_close, .. })) => {
        guard c == count && may_close else { continue }
        let span : Span = {
          start: line.first,
          span: { ..line, first: k, last: start - 1, },
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
        let span : Span = { start: line.first, span: { ..line, first: k, }, }
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
/// For the kinds of raw HTML that end with a specific string (comments,
/// processing instructions, CDATA sections and declarations, see
/// `raw_html_end_kind`), the first position in a token stream after which
/// they were found not to end. Later ones cannot end either: this avoids
/// quadratic behaviour on unterminated constructs.
priv struct RawHtmlNoEnd(FixedArray[Int])

///|
fn RawHtmlNoEnd::new() -> RawHtmlNoEnd {
  FixedArray::make(4, @int.MAX_VALUE)
}

///|
/// The kind of raw HTML starting at `start` if it ends with a specific
/// string.
fn raw_html_end_kind(s : String, start~ : CharCodePos) -> Int? {
  fn has_prefix(p : String) -> Bool {
    start + p.length() <= s.length() &&
    s.view(start_offset=start, end_offset=start + p.length()) == p
  }

  if has_prefix("<!--") {
    Some(0)
  } else if has_prefix("<?") {
    Some(1)
  } else if has_prefix("<![CDATA[") {
    Some(2)
  } else if has_prefix("<!") &&
    start + 2 < s.length() &&
    s[start + 2].to_char() is Some(c) &&
    c.is_ascii_alphabetic() {
    Some(3)
  } else {
    None
  }
}

///|
/// Tries to push an inline autolink or raw HTML to the `rev_toks` stack.
/// If this function returns `Some((line_span, token))`, it means the stack has been modified.
fn Parser::try_autolink_or_html(
  self : Parser,
  rev_toks : Ref[RevTokens],
  line : LineSpan,
  start~ : CharCodePos,
  no_end~ : RawHtmlNoEnd,
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
  let end_kind = raw_html_end_kind(self.i, start~)
  if end_kind is Some(k) && no_end.0[k] <= start {
    return None
  }
  // Raw HTML may span lines: remember the tokens consumed by `next_line`
  // to restore them if it turns out not to be raw HTML.
  let consumed = []
  let next_line = NextLineFn(toks => tokens_next_line_consumed(toks, consumed))
  guard @cmark_base.raw_html(next_line~, self.i, rev_toks.val, line~, start~)
    is Some((last_line, spans, last)) else {
    tokens_restore(rev_toks.val, consumed)
    if end_kind is Some(k) {
      no_end.0[k] = @cmp.minimum(no_end.0[k], start)
    }
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
  { meta, key, text, }
}

///|
/// https://spec.commonmark.org/current/#full-reference-link
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
  Some(Some((line, Ref(Full, ref_, def), last)))
}

///|
/// https://spec.commonmark.org/current/#shortcut-reference-link
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
  Some((line, Ref(Shortcut, ref_, def), last))
}

///|
/// https://spec.commonmark.org/current/#collapsed-reference-link
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
  Some((line, Ref(Collapsed, ref_, def), last))
}

///|
/// https://spec.commonmark.org/current/#inline-link
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
      let dest = self.clean_unesc_unref_span({ ..line, first, last, })
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
  let ld : LinkDefinition = { layout, label, defined_label, dest, title, }
  let textloc = self.text_loc_of_lines(
    first=st,
    last=start,
    first_line=start_line,
    last_line=line,
  )
  let ld = { v: ld, meta: self.meta(textloc), }
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
  no_end~ : RawHtmlNoEnd,
) -> (LineSpan, Tokens, CharCodePos)? {
  let _ = start
  let mut line = start_line
  let mut nest = 0
  let acc : Tokens = Deque([])
  for ;; {
    match (rev_toks.val.pop(), nest) {
      (Some(RightBrack({ start: last, })), 0) => {
        tokens_shorten_last_line(to_last=last - 1, acc)
        return Some((line, acc, last))
      }
      (Some(Backticks({ start, count, escaped, })), _) =>
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
      (Some(AutolinkOrHtmlStart({ start, })), _) => {
        guard self.try_autolink_or_html(rev_toks, line, start~, no_end~)
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
  let old_rev_toks = start_rev_toks.val.0.copy()
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
  let link : InlineLink = { text, reference, }
  let t = self.link_token(
    first~,
    last~,
    first_line=start_line,
    last_line=endline,
    image~,
    link,
  )
  let had_link = !image && !self.nested_links
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
  no_end~ : RawHtmlNoEnd,
) -> (LineSpan, Token, Bool)? {
  guard self.cidx.has_right_brack(after=start) else { return None }
  let rev_toks : Ref[RevTokens] = Ref(start_rev_toks.val.0.copy())
  guard self.find_link_text_tokens( // text_last with ] delim 
      rev_toks,
      start_line,
      start~,
      no_end~,
    )
    is Some((line, text_toks, text_last)) else {
    None
  }
  let (text, had_link) = self.parse_tokens(
    text_toks.0,
    {
      let first = start + 1 + image.to_int()
      let last = if start_line == line {
        text_last - 1
      } else {
        start_line.last
      }
      { ..start_line, first, last, }
    },
    strip_first=false, // Blanks after `[` are part of the text
  )
  if had_link && !image {
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

///|
/// Parse inline atoms and links.
/// Links are parsed here otherwise link reference data gets parsed as atoms.
fn Parser::first_pass(
  self : Parser,
  toks : Ref[Tokens],
  line : LineSpan,
) -> Bool {
  let acc : Tokens = Deque([])
  let mut had_link = false
  let mut line = line
  let rev_toks : Ref[RevTokens] = Ref(toks.val.0)
  let no_end = RawHtmlNoEnd::new()
  while rev_toks.val.pop() is Some(t) {
    match t {
      Backticks({ start, count, escaped, }) =>
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
      AutolinkOrHtmlStart({ start, }) =>
        if self.try_autolink_or_html(rev_toks, line, start~, no_end~)
          is Some((line_, t)) {
          line = line_
          acc.push(t)
        }
      LinkStart({ start, image, }) =>
        if self.try_link(rev_toks, line, image~, start~, no_end~)
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
/// Whether the emphasis marks `closer` can close `opener`.
/// https://spec.commonmark.org/current/#can-open-emphasis (rules 9 and 10)
fn emphasis_marks_match(
  opener : TokenEmphasisMarks,
  closer : TokenEmphasisMarks,
) -> Bool {
  opener.char == closer.char &&
  opener.may_open &&
  (
    !(closer.may_open || opener.may_close) ||
    (closer.run_length % 3 == 0 && opener.run_length % 3 == 0) ||
    (opener.run_length + closer.run_length) % 3 != 0
  )
}

///|
/// The tokens of a paragraph (or of a link text) as a doubly linked list,
/// for processing emphasis and strikethrough delimiters.
priv struct DelimList {
  toks : Array[Token]
  /// The line in effect at the start of each token.
  lines : Array[LineSpan]
  next : Array[Int]
  prev : Array[Int]
  mut head : Int
}

///|
fn DelimList::new(toks : Tokens, line : LineSpan) -> DelimList {
  let toks = toks.0.to_array()
  let n = toks.length()
  let lines = []
  let mut line = line
  for t in toks {
    lines.push(line)
    match t {
      Newline({ newline: l, .. }) | Inline({ endline: l, .. }) => line = l
      _ => ()
    }
  }
  let next = Array::makei(n, i => if i + 1 < n { i + 1 } else { -1 })
  let prev = Array::makei(n, i => i - 1)
  { toks, lines, next, prev, head: if n == 0 { -1 } else { 0 }, }
}

///|
fn DelimList::unlink(self : DelimList, i : Int) -> Unit {
  let prev = self.prev[i]
  let next = self.next[i]
  if prev < 0 {
    self.head = next
  } else {
    self.next[prev] = next
  }
  if next >= 0 {
    self.prev[next] = prev
  }
}

///|
/// The `Newline` and `Inline` tokens strictly between `first` and `last`.
fn DelimList::between(self : DelimList, first : Int, last : Int) -> Tokens {
  let acc : Tokens = Deque([])
  for k = self.next[first]; k != last; k = self.next[k] {
    match self.toks[k] {
      Newline(_) | Inline(_) as t => acc.push(t)
      _ => () // Unmatched delimiters are text
    }
  }
  acc
}

///|
/// Replaces the tokens strictly between `first` and `last` by `t`.
fn DelimList::replace_between(
  self : DelimList,
  first : Int,
  last : Int,
  t : Token,
) -> Unit {
  let k = self.toks.length()
  self.toks.push(t)
  self.lines.push(self.lines[first])
  self.prev.push(first)
  self.next.push(last)
  self.next[first] = k
  self.prev[last] = k
}

///|
/// The inline made of the `toks` between `first` and `last` which start
/// after an opener on `first_line` and end before a closer on `last_line`.
fn Parser::delimited_text(
  self : Parser,
  toks : Tokens,
  first~ : CharCodePos,
  last~ : CharCodePos,
  first_line~ : LineSpan,
  last_line~ : LineSpan,
  text_first~ : CharCodePos,
) -> Inline {
  tokens_shorten_last_line(to_last=last, toks)
  let text_start = {
    let last = if first_line == last_line { last } else { first_line.last }
    { ..first_line, first: text_first, last, }
  }
  let text = self.last_pass(toks, text_start)
  self.inlines_inline(first~, last~, first_line~, last_line~, text)
}

///|
/// Turns the emphasis and strikethrough delimiters of `toks` into inlines
/// with the [process emphasis](https://spec.commonmark.org/current/#process-emphasis)
/// procedure. Afterwards only `Inline` and `Newline` tokens remain.
fn Parser::second_pass(
  self : Parser,
  toks : Ref[Tokens],
  line : LineSpan,
) -> Unit {
  let l = DelimList::new(toks.val, line)
  // The delimiter stack: the token indices of delimiters, as a doubly
  // linked list.
  let delims = []
  for i, t in l.toks {
    if t is (EmphasisMarks(_) | StrikethroughMarks(_)) {
      delims.push(i)
    }
  }
  let n = delims.length()
  let dprev = Array::makei(n, i => i - 1)
  let dnext = Array::makei(n, i => i + 1)
  let remove = fn(d) {
    if dprev[d] >= 0 {
      dnext[dprev[d]] = dnext[d]
    }
    if dnext[d] < n {
      dprev[dnext[d]] = dprev[d]
    }
  }
  // For each kind of closer, the delimiter index below which (inclusive)
  // there is no opener for it (`openers_bottom` in the spec).
  let bottoms : Map[(Char, Bool, Int), Int] = Map([])
  let mut d = 0
  while d < n {
    let c = delims[d]
    let (may_close, key) = match l.toks[c] {
      EmphasisMarks(m) => (m.may_close, (m.char, m.may_open, m.run_length % 3))
      StrikethroughMarks(m) => (m.may_close, ('~', false, 0))
      _ => abort("unreachable")
    }
    if !may_close {
      d += 1
      continue
    }
    let bottom = bottoms.get(key).unwrap_or(-1)
    let opener = for j = dprev[d]; j > bottom; j = dprev[j] {
      let matches = match (l.toks[delims[j]], l.toks[c]) {
        (EmphasisMarks(o), EmphasisMarks(c)) => emphasis_marks_match(o, c)
        (StrikethroughMarks(o), StrikethroughMarks(_)) => o.may_open
        _ => false
      }
      if matches {
        break Some(j)
      }
    } nobreak {
      None
    }
    guard opener is Some(od) else {
      bottoms[key] = d - 1
      if !(l.toks[c]
        is (EmphasisMarks({ may_open: true, .. })
        | StrikethroughMarks({ may_open: true, .. }))) {
        remove(d)
      }
      d += 1
      continue
    }
    // The delimiters between the opener and the closer become text
    dnext[od] = d
    dprev[d] = od
    let o = delims[od]
    let first_line = l.lines[o]
    let last_line = l.lines[c]
    let text = l.between(o, c)
    match (l.toks[o], l.toks[c]) {
      (EmphasisMarks(opener), EmphasisMarks(closer)) => {
        let used = if opener.count >= 2 && closer.count >= 2 { 2 } else { 1 }
        let text_first = opener.start + opener.count
        let first = text_first - used
        let last = closer.start + used - 1
        let emph = self.delimited_text(
          text,
          first~,
          last=closer.start - 1,
          first_line~,
          last_line~,
          text_first~,
        )
        let t = self.emphasis_token(
          first~,
          last~,
          first_line~,
          last_line~,
          strong=used == 2,
          emph,
        )
        l.replace_between(o, c, t)
        if opener.count == used {
          l.unlink(o)
          remove(od)
        } else {
          l.toks[o] = EmphasisMarks({ ..opener, count: opener.count - used, })
        }
        if closer.count == used {
          l.unlink(c)
          remove(d)
          d += 1
        } else {
          let count = closer.count - used
          l.toks[c] = EmphasisMarks({ ..closer, start: last + 1, count, })
        }
      }
      (StrikethroughMarks(opener), StrikethroughMarks(closer)) => {
        let text_first = opener.start + 2
        let s = self.delimited_text(
          text,
          first=text_first,
          last=closer.start - 1,
          first_line~,
          last_line~,
          text_first~,
        )
        let t = self.ext_strikethough_token(
          first=opener.start,
          last=closer.start + 1,
          first_line~,
          last_line~,
          s,
        )
        l.replace_between(o, c, t)
        l.unlink(o)
        l.unlink(c)
        remove(od)
        remove(d)
        d += 1
      }
      _ => abort("unreachable")
    }
  }
  let acc : Tokens = Deque([])
  for k = l.head; k >= 0; k = l.next[k] {
    match l.toks[k] {
      Newline(_) | Inline(_) as t => acc.push(t)
      _ => () // Unmatched delimiters are text
    }
  }
  toks.val = acc
}

// Last pass

///|
/// Only `Inline` and `Newline` tokens remain. We fold over them to
/// convert them to `inline` values and `Break`s. `Text` inlines
/// are created for data between them.
///
/// If `strip_first` is `false`, the initial blanks of `line` are kept:
/// `line` does not start a line of the paragraph (e.g. link text).
fn Parser::last_pass(
  self : Parser,
  toks : Tokens,
  line : LineSpan,
  strip_first? : Bool = true,
) -> Array[Inline] {
  let acc = []
  let first_line = line
  let mut line = line
  let mut k = line.first
  for tok in toks.0 {
    let strip = strip_first || line != first_line
    match tok {
      Newline({ start, break_ty, newline, }) => {
        self.try_add_text_inline(line, first=k, last=start - 1, acc, strip~)
        let break_ = self.break_inline(line, start~, break_ty~, newline~)
        line = newline
        acc.push(break_)
        k = newline.first
      }
      Inline({ start, inline, endline, next, }) => {
        self.try_add_text_inline(line, first=k, last=start - 1, acc, strip~)
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
  let strip = strip_first || line != first_line
  self.try_add_text_inline(line, first=k, last=line.last, acc, strip~)
  acc
}

///|
fn Parser::parse_tokens(
  self : Parser,
  toks : Tokens,
  first_line : LineSpan,
  strip_first? : Bool = true,
) -> (Array[Inline], Bool) {
  let toks : Ref[Tokens] = Ref(toks)
  let had_link = self.first_pass(toks, first_line)
  self.second_pass(toks, first_line)
  let inlines = self.last_pass(toks.val, first_line, strip_first~)
  (inlines, had_link)
}

///|
fn Parser::strip_paragraph(
  self : Parser,
  lines : Array[LineSpan],
) -> ((Col, String), Meta, Array[LineSpan]) {
  let (last, trailing_blanks) = {
    guard! lines.pop() is Some(line)
    let { first, last: start, .. } = line
    let non_blank = @cmark_base.last_non_blank(self.i, first~, start~)
    let last = { ..line, last: non_blank, }
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
    let first = { ..line, first: non_blank, }
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
  let (cidx, toks, first_line, only_newlines) = tokenize(
    self.i,
    lines,
    exts=self.exts,
  )
  let is_ = if only_newlines {
    self.last_pass(toks, first_line)
  } else {
    self.cidx = cidx
    let (is_, _) = self.parse_tokens(toks, first_line)
    is_
  }
  let inline = match is_ {
    [i] => i
    _ => Inlines({ v: is_, meta, })
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
  let line = { ..line, first: k, last: nb - 1, }
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
      Inlines({ v: is_, meta, })
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
    let line = { ..line, first, last, }
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
  let after = self.layout_clean_raw_span1({
    ..line,
    first: nb + 1,
    last: n - 1,
  })
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
        let l = self.text_loc_of_span({ ..line, first: k, last: k - 1, })
        Inlines({ v: [], meta: self.meta(l), })
      })
      Col((text, (bbefore, bafter)), k)
    }
  }
}

///|
priv enum StartColResult {
  Col((Inline, TableCellLayout), CharCodePos)
  Start(String, Array[Inline])
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
    if toks.0.is_empty() {
      guard! self.find_pipe(line, before=line.last + 1, k)
        is Ok((text, after, k))
      is_.push_iter(text.iter())
      break ((self.make_col(is_), (blanks_before, after)), k)
    }
    guard! toks.0.front() is Some(Inline({ start, inline, next, .. }))
    if k >= start {
      toks.0.unsafe_pop_front()
      is_.push(inline)
      continue k
    }
    break match self.find_pipe(line, before=start, k) {
      Err(text) => {
        is_.push(text)
        is_.push(inline)
        toks.0.unsafe_pop_front()
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
  for k = k {
    if toks.0.is_empty() {
      guard k <= line.last else { break }
      guard! self.start_col(line, before=line.last + 1, k) is Col(col, k)
      acc.push(col)
      continue k
    }
    guard! toks.0.front() is Some(Inline({ start, inline, next, .. }))
    match self.start_col(line, before=start, k) {
      Col(col, k) => {
        acc.push(col)
        continue k
      }
      Start(before, is_) => {
        toks.0.unsafe_pop_front()
        is_.push(inline)
        let (col, k) = self.finish_col(line, before, is_, toks, next)
        acc.push(col)
        continue k
      }
    }
  }
}

///|
fn Parser::parse_table_row(
  self : Parser,
  line : LineSpan,
) -> Array[(Inline, TableCellLayout)] {
  let (cidx, toks, first_line, _) = tokenize(self.i, [line], exts=self.exts)
  self.cidx = cidx
  let toks : Ref[Tokens] = Ref(toks)
  let _ = self.first_pass(toks, first_line)
  self.second_pass(toks, first_line)
  // We now have modified last pass, inner inlines will have gone through
  // the regular `last_pass` which is fine since we are only interested
  // in creating the toplevel text nodes further splited on (unescaped) `\`.
  let rows = []
  self.parse_cols(line, rows, toks.val, line.first)
  rows
}

///| https://spec.commonmark.org/current/#tag-name
fn tag_name(s : String, last~ : Int = -1, start~ : Int = 0) -> Int? {
  let last = if last < 0 { s.length() + last } else { last }
  for s = s, last = last, k = start + 1 {
    guard k <= last &&
      s[k].to_char() is Some(c) &&
      (@char.is_ascii_alphanum(c) || c == '-') else {
      break Some(k - 1)
    }
    continue s, last, k + 1
  }
}

///| https://spec.commonmark.org/current/#attribute-name
fn attribute_name(s : String, last~ : Int = -1, start~ : Int = 0) -> Next? {
  let last = if last < 0 { s.length() + last } else { last }
  fn char_is_start(c : Char) -> Bool {
    match c {
      '_' | ':' => true
      _ => @char.is_ascii_alphanum(c)
    }
  }

  fn char_is_cont(c : Char) -> Bool {
    match c {
      '.' | '_' | ':' | '-' => true
      _ => @char.is_ascii_alphanum(c)
    }
  }

  if start > last ||
    not(s[start].to_char() is Some(c) && char_is_start(c)) {
    return None
  }
  for s = s, last = last, k = start + 1 {
    if k > last || not(s[k].to_char() is Some(c) && char_is_cont(c)) {
      break Some(k - 1)
    }
    continue s, last, k + 1
  }
}

///| https://spec.commonmark.org/current/#attribute-value
fn[A] attribute_value(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : Array[Span],
  start~ : Int,
) -> (LineSpan, Int)? {
  if start > line.last {
    return None
  }
  let c = s[start].unsafe_to_char()
  // https://spec.commonmark.org/current/#double-quoted-attribute-value
  // https://spec.commonmark.org/current/#unquoted-attribute-value
  if c is ('"' | '\'') {
    return accept_to(char=c, next_line~, s, lines, line~, spans, after=start)
  }
  // https://spec.commonmark.org/current/#unquoted-attribute-value
  fn is_cont(c) {
    not(c is (' ' | '\t' | '"' | '\'' | '=' | '<' | '>' | '`'))
  }

  for s = s, last = line.last, k = start + 1 {
    if k <= last && s[k].to_char() is Some(c) && is_cont(c) {
      continue s, last, k + 1
    }
    let last = k - 1
    push_span(line~, start, last, spans)
    break Some((line, last))
  }
}

///| https://spec.commonmark.org/current/#attribute
/// https://spec.commonmark.org/current/#attribute-value-specification
fn[A] attribute(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : Ref[Array[Span]],
  start~ : Int,
) -> (LineSpan, Last)? {
  guard attribute_name(s, last=line.last, start~) is Some(end_name) else {
    return None
  }
  push_span(line~, start, end_name, spans.val)
  let start = end_name + 1
  guard first_non_blank_over_nl1(next_line~, s, lines, line~, spans.val, start~)
    is Some((line1, last_blank)) else {
    None
  }
  let nb = last_blank + 1
  if s[nb] != '=' {
    return Some((line, end_name)) // No value
  }
  push_span(line=line1, nb, nb, spans.val)
  let start = nb + 1
  guard first_non_blank_over_nl1(
      next_line~,
      s,
      lines,
      line=line1,
      spans.val,
      start~,
    )
    is Some((line, last_blank)) else {
    None
  }
  let start = last_blank + 1
  attribute_value(next_line~, s, lines, line~, spans.val, start~)
}

///| https://spec.commonmark.org/current/#open-tag
fn[A] open_tag(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  let tag_start = start
  guard tag_name(s, last=line.last, start=tag_start + 1) is Some(tag_name_end) else {
    None
  }
  let start = tag_name_end + 1
  let span = { ..line, first: tag_start, last: tag_name_end }
  let spans = Ref::new([{ start: tag_start, span }])
  for lines = lines, line = line, start = start {
    guard first_non_blank_over_nl1(
        next_line~,
        s,
        lines,
        line~,
        spans.val,
        start~,
      )
      is Some((line, last_blank)) else {
      break None
    }
    let next = last_blank + 1
    break match s[next] {
      '>' => {
        push_span(line~, next, next, spans.val)
        Some((line, spans.val, next))
      }
      '/' => {
        let last = next + 1
        if last > line.last || s[last] != '>' {
          None
        } else {
          push_span(line~, next, last, spans.val)
          Some((line, spans.val, last))
        }
      }
      _c =>
        if next == start {
          None
        } else {
          guard attribute(next_line~, s, lines, line~, spans, start=next)
            is Some((line, last)) else {
            None
          }
          continue lines, line, last + 1
        }
    }
  }
}

///| Start is on `</`.
/// https://spec.commonmark.org/current/#closing-tag
fn[A] closing_tag(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  let tag_start = start
  guard tag_name(s, last=line.last, start=start + 2) is Some(tag_name_end) else {
    return None
  }
  let span = { ..line, first: start, last: tag_name_end }
  let spans = Ref::new([{ start: tag_start, span }])
  let start = tag_name_end + 1
  guard first_non_blank_over_nl1(next_line~, s, lines, line~, spans.val, start~)
    is Some((line, last_blank)) else {
    None
  }
  let last = last_blank + 1
  if s[last] != '>' {
    return None
  }
  push_span(line~, last, last, spans.val)
  Some((line, spans.val, last))
}

///| Start is on `<!{letter}`.
/// https://spec.commonmark.org/current/#declaration
fn[A] declaration(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  let spans = []
  accept_to(char='>', next_line~, s, lines, line~, spans, after=start).map(line_k => (
    line_k.0,
    spans,
    line_k.1,
  ))
}

///| https://spec.commonmark.org/current/#processing-instruction
fn[A] processing_instruction(
  next_line : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  let acc = []
  for lines = lines, line = line, start = start, k = start + 2 {
    if k > line.last {
      guard next_line(lines) is Some(new_line) else { break None }
      push_span(line~, start, line.last, acc)
      let start = first_non_blank_in_span(s, new_line)
      continue lines, new_line, start, start
    }
    if s[k] != '?' {
      continue lines, line, start, k + 1
    }
    let last = k + 1
    if last <= line.last && s[last] == '>' { // ?>
      push_span(line~, start, last, acc)
      break Some((line, acc, last))
    }
    continue lines, line, start, last
  }
}

///| Start is on `<!-`.
/// https://spec.commonmark.org/current/#html-comment
fn[A] html_comment(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  // Check we have at least <!-- and not <!--> or <!--->.
  if start + 3 > line.last || s[start + 3] != '-' {
    return None
  }
  if start + 4 <= line.last && s[start + 4] == '>' {
    return None
  }
  if start + 5 <= line.last &&
    s[start + 4] == '-' &&
    s[start + 5] == '>' {
    return None
  }
  let acc = []
  for lines = lines, line = line, start = start, k = start + 4 {
    if k > line.last {
      guard next_line(lines) is Some(new_line) else { break None }
      push_span(line~, start, line.last, acc)
      let start = first_non_blank_in_span(s, new_line)
      continue lines, new_line, start, start
    }
    if s[k] == '-' && s[k - 1] != '-' {
      let last = k + 2
      if last <= line.last && s[k + 1] == '-' {
        break if s[last] == '>' { // And we do not end with -
          push_span(line~, start, last, acc)
          Some((line, acc, last))
        } else {
          None // In the input
        }
      }
    }
    continue lines, line, start, k + 1
  }
}

///| Start is on `<![`.
/// https://spec.commonmark.org/current/#cdata-section
fn[A] cdata_section(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  if start + 8 > line.last {
    return None
  }
  if not(s.substring(start=start + 3).has_prefix("CDATA[")) {
    return None
  }
  let acc = []
  for lines = lines, line = line, start = start, k = start + 9 {
    if k > line.last {
      guard next_line(lines) is Some(new_line) else { break None }
      push_span(line~, start, line.last, acc)
      let start = first_non_blank_in_span(s, new_line)
      continue lines, new_line, start, start
    }
    if s[k] != ']' {
      continue lines, line, start, k + 1
    }
    let last = k + 2
    if last <= line.last &&
      s[k + 1] == ']' &&
      s[last] == '>' { // ]>
      push_span(line~, start, last, acc)
      break Some((line, acc, last))
    }
    continue lines, line, start, k + 1
  }
}

///| https://spec.commonmark.org/current/#html-tag
pub fn[A : Show] raw_html(
  next_line~ : NextLineFn(A),
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> (LineSpan, Array[Span], CharCodePos)? {
  let next = start + 1
  let { last, .. } = line
  guard next <= last && s[start] == '<' else { None }
  match s[next] {
    '/' => closing_tag(next_line~, s, lines, line~, start~)
    '?' => processing_instruction(next_line, s, lines, line~, start~)
    '!' => {
      let next = next + 1
      guard next <= last else { None }
      match s[next].unsafe_to_char() {
        '-' => html_comment(next_line~, s, lines, line~, start~)
        '[' => cdata_section(next_line~, s, lines, line~, start~)
        c => {
          guard c.is_ascii_alphabetic() else { None }
          declaration(next_line~, s, lines, line~, start~)
        }
      }
    }
    _ => open_tag(next_line~, s, lines, line~, start~)
  }
}

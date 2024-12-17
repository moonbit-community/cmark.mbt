///| https://spec.commonmark.org/current/#tag-name
fn tag_name(s : String, last~ : Int = s.length() - 1, start~ : Int = 0) -> Int? {
  loop s, last, start + 1 {
    s, last, k => {
      if k > last || not(@char.is_ascii_alphanum(s[k])) || s[k] == '-' {
        break Some(k - 1)
      }
      continue s, last, k + 1
    }
  }
}

///| https://spec.commonmark.org/current/#attribute-name
fn attribute_name(
  s : String,
  last~ : Int = s.length() - 1,
  start~ : Int = 0
) -> Next? {
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

  if start > last || not(char_is_start(s[start])) {
    return None
  }
  loop s, last, start + 1 {
    s, last, k => {
      if k > last || not(char_is_cont(s[k])) {
        break Some(k - 1)
      }
      continue s, last, k + 1
    }
  }
}

///| https://spec.commonmark.org/current/#attribute-value
fn attribute_value[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : List[Span],
  start~ : Int
) -> (A, LineSpan, List[Span], Int)? {
  if start > line.last {
    return None
  }
  let c = s[start]
  // https://spec.commonmark.org/current/#double-quoted-attribute-value
  // https://spec.commonmark.org/current/#unquoted-attribute-value
  if c == '"' || c == '\'' {
    return accept_to(char=c, next_line~, s, lines, line~, spans, after=start)
  }
  // https://spec.commonmark.org/current/#unquoted-attribute-value
  fn is_cont(c) {
    match c {
      ' ' | '\t' | '"' | '\'' | '=' | '<' | '>' | '`' => false
      _ => true
    }
  }

  loop s, line.last, start + 1 {
    s, last, k => {
      if k > last || not(is_cont(s[k])) {
        let last = k - 1
        let spans = push_span(line~, start, last, spans)
        break Some((lines, line, spans, last))
      }
      continue s, last, k + 1
    }
  }
}

///| https://spec.commonmark.org/current/#attribute
/// https://spec.commonmark.org/current/#attribute-value-specification
fn attribute[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : List[Span],
  start~ : Int
) -> (A, LineSpan, List[Span], Last)? {
  guard let Some(end_name) = attribute_name(s, last=line.last, start~) else {
    _ => return None
  }
  let spans = push_span(line~, start, end_name, spans)
  let start = end_name + 1
  guard let Some((lines1, line1, spans1, last_blank)) = first_non_blank_over_nl1(
    next_line~,
    s,
    lines,
    line~,
    spans,
    start~,
  ) else {
    _ => return None
  }
  let nb = last_blank + 1
  if s[nb] != '=' {
    return Some((lines, line, spans, end_name)) // No value
  }
  let spans1 = push_span(line=line1, nb, nb, spans1)
  let start = nb + 1
  guard let Some((lines, line, spans, last_blank)) = first_non_blank_over_nl1(
    next_line~,
    s,
    lines1,
    line=line1,
    spans1,
    start~,
  ) else {
    _ => return None
  }
  let start = last_blank + 1
  attribute_value(next_line~, s, lines, line~, spans, start~)
}

///| https://spec.commonmark.org/current/#open-tag
fn open_tag[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  let tag_start = start
  guard let Some(tag_name_end) = tag_name(
    s,
    last=line.last,
    start=tag_start + 1,
  ) else {
    _ => return None
  }
  let start = tag_name_end + 1
  let span = { ..line, first: tag_start, last: tag_name_end }
  let spans = List::of([{ start: tag_start, span }])
  loop lines, line, spans, start {
    lines, line, spans, start => {
      guard let Some((lines, line, spans, last_blank)) = first_non_blank_over_nl1(
        next_line~,
        s,
        lines,
        line~,
        spans,
        start~,
      ) else {
        _ => break None
      }
      let next = last_blank + 1
      match s[next] {
        '>' =>
          break Some((lines, line, push_span(line~, next, next, spans), next))
        '/' => {
          let last = next + 1
          if last > line.last || s[last] != '>' {
            break None
          }
          Some((lines, line, push_span(line~, next, last, spans), last))
        }
        _c => {
          if next == start {
            break None
          }
          guard let Some((lines, line, spans, last)) = attribute(
            next_line~,
            s,
            lines,
            line~,
            spans,
            start=next,
          ) else {
            _ => break None
          }
          continue lines, line, spans, last + 1
        }
      }
    }
  }
}

///| Start is on `</`.
/// https://spec.commonmark.org/current/#closing-tag
fn closing_tag[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  let tag_start = start
  guard let Some(tag_name_end) = tag_name(s, last=line.last, start=start + 2) else {
    _ => return None
  }
  let span = { ..line, first: start, last: tag_name_end }
  let spans = List::of([{ start: tag_start, span }])
  let start = tag_name_end + 1
  guard let Some((lines, line, spans, last_blank)) = first_non_blank_over_nl1(
    next_line~,
    s,
    lines,
    line~,
    spans,
    start~,
  ) else {
    _ => return None
  }
  let last = last_blank + 1
  if s[last] != '>' {
    return None
  }
  Some((lines, line, push_span(line~, last, last, spans), last))
}

///| Start is on `<!{letter}`.
/// https://spec.commonmark.org/current/#declaration
fn declaration[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  accept_to(char='>', next_line~, s, lines, line~, Nil, after=start)
}

///| https://spec.commonmark.org/current/#processing-instruction
fn processing_instruction[A](
  next_line : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  loop lines, line, start, List::Nil, start + 2 {
    lines, line, start, acc, k => {
      if k > line.last {
        guard let Some((lines, new_line)) = next_line(lines) else {
          _ => break None
        }
        let acc = push_span(line~, start, line.last, acc)
        let start = first_non_blank_in_span(s, new_line)
        continue lines, new_line, start, acc, start
      }
      if s[k] != '?' {
        continue lines, line, start, acc, k + 1
      }
      let last = k + 1
      if last <= line.last && s[last] == '>' { // ?>
        let acc = push_span(line~, start, last, acc)
        break Some((lines, line, acc, last))
      }
      continue lines, line, start, acc, last
    }
  }
}

///| Start is on `<!-`.
/// https://spec.commonmark.org/current/#html-comment
fn html_comment[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  // Check we have at least <!-- and not <!--> or <!--->.
  if start + 3 > line.last || s[start + 3] != '-' {
    return None
  }
  if start + 4 <= line.last && s[start + 4] == '>' {
    return None
  }
  if start + 5 <= line.last && s[start + 4] == '-' && s[start + 5] == '>' {
    return None
  }
  loop lines, line, start, List::Nil, start + 4 {
    lines, line, start, acc, k => {
      if k > line.last {
        guard let Some((lines, new_line)) = next_line(lines) else {
          _ => break None
        }
        let acc = push_span(line~, start, line.last, acc)
        let start = first_non_blank_in_span(s, new_line)
        continue lines, new_line, start, acc, start
      }
      if s[k] == '-' && s[k - 1] != '-' {
        let last = k + 2
        if last <= line.last && s[k + 1] == '-' {
          break if s[last] == '>' { // And we do not end with - 
            Some((lines, line, push_span(line~, start, last, acc), last))
          } else {
            None // In the input
          }
        }
      }
      continue lines, line, start, acc, k + 1
    }
  }
}

///| Start is on `<![`.
/// https://spec.commonmark.org/current/#cdata-section
fn cdata_section[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  if start + 8 > line.last {
    return None
  }
  if not(s.substring(start=start + 3).starts_with("CDATA[")) {
    return None
  }
  loop lines, line, start, List::Nil, start + 9 {
    lines, line, start, acc, k => {
      if k > line.last {
        guard let Some((lines, new_line)) = next_line(lines) else {
          _ => break None
        }
        let acc = push_span(line~, start, line.last, acc)
        let start = first_non_blank_in_span(s, new_line)
        continue lines, new_line, start, acc, start
      }
      if s[k] != ']' {
        continue lines, line, start, acc, k + 1
      }
      let last = k + 2
      if last <= line.last && s[k + 1] == ']' && s[last] == '>' { // ]>
        break Some((lines, line, push_span(line~, start, last, acc), last))
      }
      continue lines, line, start, acc, k + 1
    }
  }
}

///| https://spec.commonmark.org/current/#html-tag
pub fn raw_html[A : Show](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  let next = start + 1
  let { last, .. } = line
  if next > last || s[start] != '<' {
    return None
  }
  match s[next] {
    '/' => closing_tag(next_line~, s, lines, line~, start~)
    '?' => processing_instruction(next_line, s, lines, line~, start~)
    '!' => {
      let next = next + 1
      if next > last {
        return None
      }
      match s[next] {
        '-' => html_comment(next_line~, s, lines, line~, start~)
        '[' => cdata_section(next_line~, s, lines, line~, start~)
        c =>
          if @char.is_ascii_alpha(c) {
            declaration(next_line~, s, lines, line~, start~)
          } else {
            None
          }
      }
    }
    _ => open_tag(next_line~, s, lines, line~, start~)
  }
}

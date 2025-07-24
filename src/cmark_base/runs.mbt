///| `run_of(char, s, last, start)` is the last position of a consecutive run of `char`
/// in the range `[start, last]` or `start - 1` if `start` is not `char`.
pub fn run_of(
  char~ : Char,
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> Last {
  if start > last || s[start] != char.to_int() {
    return start - 1
  }
  run_of(char~, s, last~, start=start + 1)
}

///| `first_non_blank(s, last, start)` is the first position in the range `[start, last]`
/// that is not blank and `last + 1` if there is none.
pub fn first_non_blank(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> CharCodePos {
  for k in start..=last {
    guard s[k].to_char() is Some(c) && @char.is_ascii_blank(c) else { return k }
  }
  last + 1
}

///| `first_non_blank_in_span(s, span)` is `first_non_blank(s, last=span.last, start=span.first)`.
pub fn first_non_blank_in_span(s : String, span : LineSpan) -> CharCodePos {
  first_non_blank(s, last=span.last, start=span.first)
}

///| `last_non_blank(s, first, start)` is the last position in the range `[first, start]`
/// that is not blank and `first - 1` if there is none.
pub fn last_non_blank(
  s : String,
  first~ : CharCodePos,
  start~ : CharCodePos,
) -> CharCodePos {
  if start < first {
    return first - 1
  }
  match s[start] {
    ' ' | '\t' => last_non_blank(s, first~, start=start - 1)
    _ => start
  }
}

///| `rev_drop_spaces(s, first, start)` is the last position in the range `[first, start]`
/// that is not U+0020 and `first - 1` if there is none.
pub fn rev_drop_spaces(
  s : String,
  first~ : CharCodePos,
  start~ : CharCodePos,
) -> CharCodePos {
  if start < first {
    return first - 1
  }
  match s[start] {
    ' ' => rev_drop_spaces(s, first~, start=start - 1)
    _ => start
  }
}

///|
fn push_span(
  line~ : LineSpan,
  first : CharCodePos,
  last : CharCodePos,
  spans : Array[Span],
) -> Unit {
  let first1 = first
  let last1 = last
  // Merge if on the same line
  if spans is [.., { start, span: { pos, first, .. } }] {
    if line.pos.0 == pos.0 {
      spans[spans.length() - 1] = {
        start,
        span: { ..line, first, last: last1 },
      }
      return
    }
  }
  spans.push({ start: line.first, span: { ..line, first: first1, last: last1 } })
}

///| Includes final `char` in spans.
fn[A] accept_to(
  char~ : Char,
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : Array[Span],
  after~ : CharCodePos,
) -> (LineSpan, Int)? {
  for lines = lines, line = line, start = after, k = after + 1 {
    if k > line.last {
      guard next_line(lines) is Some(new_line) else { break None }
      push_span(line~, start, line.last, spans)
      let start = first_non_blank_in_span(s, new_line)
      continue lines, new_line, start, start
    }
    if s[k] == char.to_int() {
      push_span(line~, start, k, spans)
      break Some((line, k))
    }
    continue lines, line, start, k + 1
  }
}

///| Does not not include final `char` in spans and continues on backslashed `char`.
fn[A] accept_upto(
  char~ : Char,
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : Array[Span],
  after~ : CharCodePos,
) -> (LineSpan, Int)? {
  let start = after + 1
  for char = char, next_line = next_line, s = s, lines = lines, line = line, prev_bslash = false, start = start, acc = spans, k = start {
    if k > line.last {
      guard next_line(lines) is Some(newline) else { break None }
      if newline.first > newline.last { // Empty
        break None
      }
      push_span(line~, start, line.last, acc)
      let start = first_non_blank_in_span(s, newline)
      let prev_bslash = false
      continue char, next_line, s, lines, newline, prev_bslash, start, acc, start
    } else {
      if s[k] == char.to_int() && not(prev_bslash) {
        push_span(line~, start, k - 1, acc)
        break Some((line, k))
      }
      let prev_bslash = s[k] == '\\' && not(prev_bslash)
      continue char, next_line, s, lines, line, prev_bslash, start, acc, k + 1
    }
  }
}

///| `first_non_blank_over_nl(next_line, s, lines, line, start)` is the first byte position starting with `start`
/// that is not blank in `line` or on the next line as determined by `next_line`.
/// Returns `None` if there is no such position.
pub fn[A] first_non_blank_over_nl(
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : CharCodePos,
) -> NextLineResult? {
  let nb = first_non_blank(s, last=line.last, start~)
  if nb <= line.last {
    return Some(ThisLine(nb))
  }
  guard next_line(lines) is Some(new_line) else { return None }
  let nb = first_non_blank_in_span(s, new_line)
  if nb > new_line.last {
    return None
  }
  Some(NextLine(new_line, nb))
}

///| Same as `first_non_blank_over_nl()` but pushes skipped data on `spans`.
fn[A] first_non_blank_over_nl1(
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : Array[Span],
  start~ : CharCodePos,
) -> (LineSpan, CharCodePos)? {
  match first_non_blank_over_nl(next_line~, s, lines, line~, start~) {
    None => None
    Some(ThisLine(nb)) => {
      let line = { ..line, first: start } // No layout
      push_span(line~, start, nb - 1, spans)
      Some((line, nb - 1))
    }
    Some(NextLine(new_line, nb)) => {
      let line = { ..line, first: start } // No layout
      push_span(line~, start, line.last, spans)
      Some((new_line, nb - 1))
    }
  }
}

///| `first_non_escaped_char(c, s, last, start)` is the first `CharCodePos`
/// in the range `[start, last]` that has `c` unescaped and `last + 1` if there is none.
pub fn first_non_escaped_char(
  c : Char,
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> CharCodePos {
  for k = start; ; k = k + 1 {
    if k > last || (s[k] == c.to_int() && (k == start || s[k - 1] != '\\')) {
      break k
    }
  }
}

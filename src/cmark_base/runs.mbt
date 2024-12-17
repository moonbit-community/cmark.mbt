///| `run_of(char, s, last, start)` is the last position of a consecutive run of `char`
/// in the range `[start, last]` or `start - 1` if `start` is not `char`.
pub fn run_of(
  char~ : Char,
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> Last {
  if start > last || s[start] != char {
    return start - 1
  }
  run_of(char~, s, last~, start=start + 1)
}

///| `first_non_blank(s, last, start)` is the first position in the range `[start, last]`
/// that is not blank and `last + 1` if there is none.
pub fn first_non_blank(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> BytePos {
  if start > last {
    return last + 1
  }
  match s[start] {
    ' ' | '\t' => first_non_blank(s, last~, start=start + 1)
    _ => start
  }
}

///| `first_non_blank_in_span(s, span)` is `first_non_blank(s, last=span.last, start=span.first)`.
pub fn first_non_blank_in_span(s : String, span : LineSpan) -> BytePos {
  first_non_blank(s, last=span.last, start=span.first)
}

///| `last_non_blank(s, first, start)` is the last position in the range `[first, start]`
/// that is not blank and `first - 1` if there is none.
pub fn last_non_blank(
  s : String,
  first~ : BytePos,
  start~ : BytePos
) -> BytePos {
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
  first~ : BytePos,
  start~ : BytePos
) -> BytePos {
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
  first : BytePos,
  last : BytePos,
  spans : List[Span]
) -> List[Span] {
  let first1 = first
  let last1 = last
  match spans {
    // Merge if on the same line
    Cons({ start, span: { pos, first, .. } }, acc) =>
      if line.pos.0 == pos.0 {
        return acc.add({ start, span: { ..line, first, last: last1 } })
      }
    _ => ()
  }
  spans.add({ start: line.first, span: { ..line, first: first1, last: last1 } })
}

///| Includes final `char` in spans.
fn accept_to[A](
  char~ : Char,
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : List[Span],
  after~ : BytePos
) -> (A, LineSpan, List[Span], Int)? {
  loop lines, line, after, spans, after + 1 {
    lines, line, start, acc, k => {
      if k > line.last {
        guard let Some((lines, new_line)) = next_line(lines) else {
          _ => break None
        }
        let acc = push_span(line~, start, line.last, acc)
        let start = first_non_blank_in_span(s, new_line)
        continue lines, new_line, start, acc, start
      }
      if s[k] == char {
        let acc = push_span(line~, start, k, acc)
        break Some((lines, line, acc, k))
      }
      continue lines, line, start, acc, k + 1
    }
  }
}

///| Does not not include final `char` in spans and continues on backslashed `char`.
fn accept_upto[A](
  char~ : Char,
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : List[Span],
  after~ : BytePos
) -> (A, LineSpan, List[Span], Int)? {
  let start = after + 1
  loop char, next_line, s, lines, line, false, start, spans, start {
    char, next_line, s, lines, line, prev_bslash, start, acc, k =>
      if k > line.last {
        guard let Some((lines, newline)) = next_line(lines) else {
          _ => break None
        }
        if newline.first > newline.last { // Empty
          break None
        }
        let acc = push_span(line~, start, line.last, acc)
        let start = first_non_blank_in_span(s, newline)
        let prev_bslash = false
        continue char, next_line, s, lines, newline, prev_bslash, start, acc, start
      } else {
        if s[k] == char && not(prev_bslash) {
          let acc = push_span(line~, start, k - 1, acc)
          break Some((lines, line, acc, k))
        }
        let prev_bslash = s[k] == '\\' && not(prev_bslash)
        continue char, next_line, s, lines, line, prev_bslash, start, acc, k + 1
      }
  }
}

///| `first_non_blank_over_nl(next_line, s, lines, line, start)` is the first byte position starting with `start`
/// that is not blank in `line` or on the next line as determined by `next_line`.
/// Returns `None` if there is no such position.
pub fn first_non_blank_over_nl[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  start~ : BytePos
) -> NextLineResult[A]? {
  let nb = first_non_blank(s, last=line.last, start~)
  if nb <= line.last {
    return Some(ThisLine(nb))
  }
  guard let Some((lines, new_line)) = next_line(lines) else { _ => return None }
  let nb = first_non_blank_in_span(s, new_line)
  if nb > new_line.last {
    return None
  }
  Some(NextLine(lines, new_line, nb))
}

///| Same as `first_non_blank_over_nl()` but pushes skipped data on `spans`.
fn first_non_blank_over_nl1[A](
  next_line~ : NextLineFn[A],
  s : String,
  lines : A,
  line~ : LineSpan,
  spans : List[Span],
  start~ : BytePos
) -> (A, LineSpan, List[Span], BytePos)? {
  match first_non_blank_over_nl(next_line~, s, lines, line~, start~) {
    None => None
    Some(ThisLine(nb)) => {
      let line = { ..line, first: start } // No layout
      let spans = push_span(line~, start, nb - 1, spans)
      Some((lines, line, spans, nb - 1))
    }
    Some(NextLine(lines, new_line, nb)) => {
      let line = { ..line, first: start } // No layout
      let spans = push_span(line~, start, line.last, spans)
      Some((lines, new_line, spans, nb - 1))
    }
  }
}

///| `first_non_escaped_char(c, s, last, start)` is the first `BytePos`
/// in the range `[start, last]` that has `c` unescaped and `last + 1` if there is none.
pub fn first_non_escaped_char(
  c : Char,
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> BytePos {
  loop start {
    k => {
      if k > last || (s[k] == c && (k == start || s[k - 1] != '\\')) {
        break k
      }
      continue k + 1
    }
  }
}

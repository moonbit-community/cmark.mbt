// Leaf blocks
// The matching functions assume the indentation has been stripped.

///|
pub(all) enum HtmlBlockEndCond {
  EndStr(String)
  EndCond1
  EndBlank
  EndBlank7
} derive(Show, ToJson, Eq)

///|
pub(all) enum ListType {
  /// With the given marker.
  Unordered(Char)
  /// Starting at given integer, markers ending with given character, i.e. ')' or '.'.
  Ordered(Int, Char)
} derive(Show, FromJson, ToJson, Eq)

///|
pub fn ListType::is_same_type(self : ListType, other : ListType) -> Bool {
  (self, other)
  is ((Ordered(_, c0), Ordered(_, c1)) | (Unordered(c0), Unordered(c1))) &&
  c0 == c1
}

///|
pub(all) enum LineType {
  AtxHeadingLine(HeadingLevel, CharCodePos, First, Last)
  BlankLine
  BlockQuoteLine
  FencedCodeBlockLine(First, Last, (First, Last)?)
  HtmlBlockLine(HtmlBlockEndCond)
  IndentedCodeBlockLine
  ListMarkerLine(ListType, Last)
  ParagraphLine
  SetextUnderlineLine(HeadingLevel, Last)
  ThematicBreakLine(Last)
  ExtTableRow(Last)
  ExtFootnoteLabel(Array[Span], Last, String)
  Nomatch
} derive(Show, ToJson, Eq)

///| https://spec.commonmark.org/current/#thematic-breaks
pub fn LineType::thematic_break(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  if start > last {
    return Nomatch
  }
  match s[start] {
    '-' | '_' | '*' =>
      for s = s, last = last, count = 1, prev = start, k = start + 1 {
        break if k > last {
          if count < 3 {
            Nomatch
          } else {
            ThematicBreakLine(prev)
          }
        } else if s[k] == s[prev] {
          continue s, last, count + 1, k, k + 1
        } else if s[k] is (' ' | '\t') {
          continue s, last, count, prev, k + 1
        } else {
          Nomatch
        }
      }
    _ => Nomatch
  }
}

///| https://spec.commonmark.org/current/#atx-headings
pub fn LineType::atx_heading(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  fn skip_hashes(s : String, last, k) {
    for k = k; k <= last && s[k] == '#'; k = k + 1 {

    } else {
      k
    }
  }

  fn find_end(s : String, last, k) { // Blank on k, last + 1 if blank* [#+] blank*
    let after_blank = first_non_blank(s, last~, start=k + 1)
    if after_blank > last || s[after_blank] != '#' {
      return after_blank
    }
    let after_hash = skip_hashes(s, last, after_blank + 1)
    let after_blank = first_non_blank(s, last~, start=after_hash)
    if after_blank > last || after_blank == after_hash {
      return after_blank
    }
    // This could be the beginning of the end, trigger again
    after_blank - 1
  }

  fn content(s : String, last, k) {
    for s = s, last = last, k = k {
      guard k <= last else { break k - 1 }
      guard s[k] is (' ' | '\t') else { continue s, last, k + 1 }
      let end1 = find_end(s, last, k)
      guard end1 <= last else { break k - 1 }
      continue s, last, end1
    }
  }

  fn level(s : String, last, acc, k) {
    if k > last {
      return AtxHeadingLine(acc, k, k, last)
    }
    if s[k] == '#' {
      if acc < 6 {
        return level(s, last, acc + 1, k + 1)
      } else {
        return Nomatch
      }
    }
    let first = first_non_blank(s, last~, start=k)
    if first > last {
      return AtxHeadingLine(acc, k, last + 1, last) // Empty cases
    }
    if first == k {
      return Nomatch // Need a blank
    }
    let last = if s[first] != '#' {
      content(s, last, first + 1)
    } else {
      let end1 = find_end(s, last, first - 1) // Start on blank
      if end1 > last {
        first - 1
      } else {
        content(s, last, end1)
      }
    }
    AtxHeadingLine(acc, k, first, last)
  }

  if start > last || s[start] != '#' {
    return Nomatch
  }
  level(s, last, 1, start + 1)
}

///| https://spec.commonmark.org/current/#setext-heading
pub fn LineType::setext_heading_underline(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  let level = fn(c) { 2 - (c == '=').to_int() }
  fn underline(s : String, last, start, k) {
    if k > last {
      return SetextUnderlineLine(level(s[start].unsafe_to_char()), k - 1)
    }
    if s[k] == s[start] {
      return underline(s, last, start, k + 1)
    }
    guard s[k] is (' ' | '\t') else { return Nomatch }
    let end_blank = first_non_blank(s, last~, start=k + 1)
    if end_blank > last {
      return SetextUnderlineLine(level(s[start].unsafe_to_char()), k - 1)
    }
    Nomatch
  }

  if start > last {
    return Nomatch
  }
  if s[start] != '-' && s[start] != '=' {
    return Nomatch
  }
  underline(s, last, start, start + 1)
}

///|
pub fn LineType::fenced_code_block_start(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  fn info(s : String, last, nobt, info_first, k) {
    let sk = s[k]
    guard k <= last else { Some((info_first, last)) }
    guard not(nobt && sk == '`') else { None }
    guard sk is (' ' | '\t') else { info(s, last, nobt, info_first, k + 1) }
    let after_blank = first_non_blank(s, last~, start=k)
    guard after_blank <= last else { Some((info_first, k - 1)) }
    info(s, last, nobt, info_first, after_blank)
  }

  fn fence(s : String, last, fence_first, k) {
    for s = s, last = last, fence_first = fence_first, k = k {
      if k <= last && s[k] == s[fence_first] {
        continue s, last, fence_first, k + 1
      }
      let fence_last = k - 1
      let fcount = fence_last - fence_first + 1
      guard fcount >= 3 else { break Some(Nomatch) }
      let info = {
        let after_blank = first_non_blank(s, last~, start=k)
        if after_blank > last {
          None
        } else {
          guard info(s, last, s[fence_first] == '`', after_blank, after_blank)
            is Some(i) else {
            break None
          }
          Some(i)
        }
      }
      break Some(FencedCodeBlockLine(fence_first, fence_last, info))
    }
  }

  if start > last {
    return Nomatch
  }
  for s = s, first = start, last = last, k = start {
    guard k <= last else { break Nomatch }
    if k - first + 1 < 4 && s[k] == ' ' {
      continue s, first, last, k + 1
    }
    guard s[k] is ('~' | '`') else { break Nomatch }
    break fence(s, last, k, k + 1).unwrap_or(Nomatch)
  }
}

///|
pub(all) enum FencedCodeBlockContinue {
  Close(First, Last)
  Code
} derive(Show, ToJson)

///| `fenced_code_block_continue(fence, s, last, start)` indicates
/// whether the fence code continues or closes in the the range
/// [start;last] given the opening `open` which indicates the
/// indent, fence char and number of fence chars.
pub fn FencedCodeBlockContinue::new(
  s : String,
  fence~ : (Char, Int),
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> FencedCodeBlockContinue {
  if start > last {
    return Code
  }
  let (fc, fcount) = fence
  fn fence(s : String, last, fence_first, k) {
    for s = s, last = last, fence_first = fence_first, k = k {
      if k <= last && s[k].unsafe_to_char() == fc {
        continue s, last, fence_first, k + 1
      }
      let fence_last = k - 1
      guard fence_last - fence_first + 1 >= fcount else { break None } // Not closing
      let after_blank = first_non_blank(s, last~, start=k)
      guard after_blank > last else { break None }
      break Some(Close(fence_first, fence_last))
    }
  }

  for s = s, first = start, last = last, k = start {
    guard k <= last else { break Code } // Short blank line
    let sk = s[k].unsafe_to_char()
    if k - first + 1 < 4 && sk == ' ' {
      continue s, first, last, k + 1
    }
    guard sk == fc else { break Code }
    break fence(s, last, k, k + 1).unwrap_or(Code)
  }
}

///|
let html_start_cond_1_set : Set[String] = Set::of([
  "pre", "script", "style", "textarea",
])

///|
let html_start_cond_6_set : Set[String] = Set::of([
  "address", "article", "aside", "base", "basefont", "blockquote", "body", "caption",
  "center", "col", "colgroup", "dd", "details", "dialog", "dir", "div", "dl", "dt",
  "fieldset", "figcaption", "figure", "footer", "form", "frame", "frameset", "h1",
  "h2", "h3", "h4", "h5", "h6", "head", "header", "hr", "html", "iframe", "legend",
  "li", "link", "main", "menu", "menuitem", "nav", "noframes", "ol", "optgroup",
  "option", "p", "param", "section", "source", "summary", "table", "tbody", "td",
  "tfoot", "th", "thead", "title", "tr", "track", "ul",
])

///|
fn LineType::html_block_start_5(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  let next = start + 3 // 3 first chars checked
  let sub = "CDATA["
  if start + 8 > last || not(s.substring(start=next).has_prefix(sub)) {
    return Nomatch
  }
  HtmlBlockLine(EndStr("]]>"))
}

///|
fn LineType::html_block_start_2(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  let next = start + 3 // 3 first chars checked
  if next > last || s[next] != '-' {
    return Nomatch
  }
  HtmlBlockLine(EndStr("-->"))
}

///|
fn LineType::html_block_start_7_open_tag(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  // Has to be on the same line we fake one and use the inline parser
  let line = { pos: line_pos_none, first: start, last }
  guard open_tag(next_line=fn(_x) { None }, s, (), line~, start~)
    is Some((_, _, tag_end)) else {
    Nomatch
  }
  let next = first_non_blank(s, last~, start=tag_end + 1)
  if next > last {
    HtmlBlockLine(EndBlank7)
  } else {
    Nomatch
  }
}

///|
fn LineType::html_block_start_7_close_tag(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  let line = { pos: line_pos_none, first: start, last }
  guard closing_tag(next_line=fn(_x) { None }, s, (), line~, start~)
    is Some((_, _, tag_end)) else {
    Nomatch
  }
  let next = first_non_blank(s, last~, start=tag_end + 1)
  if next > last {
    HtmlBlockLine(EndBlank7)
  } else {
    Nomatch
  }
}

///| https://spec.commonmark.org/current/#html-blocks
pub fn LineType::html_block_start(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  let next = start + 1
  if next > last || s[start] != '<' {
    return Nomatch
  }
  match s[next].unsafe_to_char() {
    '?' => HtmlBlockLine(EndStr("?>")) // 3
    '!' => {
      let next = next + 1
      if next > last {
        return Nomatch
      }
      match s[next].unsafe_to_char() {
        '[' => LineType::html_block_start_5(s, last~, start~)
        '-' => LineType::html_block_start_2(s, last~, start~)
        c =>
          if c.is_ascii_alphabetic() {
            HtmlBlockLine(EndStr(">")) // 4
          } else {
            Nomatch
          }
      }
    }
    c => {
      guard c.is_ascii_alphabetic() || c == '/' else { return Nomatch }
      let tag_first = if c == '/' { next + 1 } else { next }
      let tag_last = for s = s, last = last, i = tag_first {
        if i > last || not(s[i].unsafe_to_char().is_ascii_alphabetic()) {
          break i - 1
        }
        continue s, last, i + 1
      }
      let tag = s.substring(start=tag_first, end=tag_last + 1).to_lower()
      let is_open_end = {
        let n = tag_last + 1
        n > last || s[n] is (' ' | '\t' | '>')
      }
      let is_open_close_end = is_open_end ||
        (
          tag_last + 2 <= last &&
          s.substring(start=tag_last + 1, end=tag_last + 3) == "/>"
        )
      if c != '/' {
        if html_start_cond_1_set.contains(tag) && is_open_end {
          LineType::HtmlBlockLine(EndCond1) // 1
        } else if html_start_cond_6_set.contains(tag) && is_open_close_end {
          LineType::HtmlBlockLine(EndBlank) // 6
        } else {
          LineType::html_block_start_7_open_tag(s, last~, start~)
        }
      } else if html_start_cond_6_set.contains(tag) && is_open_close_end {
        HtmlBlockLine(EndBlank) // 6
      } else {
        LineType::html_block_start_7_close_tag(s, last~, start~)
      }
    }
  }
}

///| https://spec.commonmark.org/current/#html-blocks end condition 1.
fn LineType::html_block_end_cond_1(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> Bool {
  let lower_s = s.to_lower()
  for last = last, k = start {
    guard k + 3 <= last else { break false }
    guard s[k] == '<' && s[k + 1] == '/' else { continue last, k + 1 }
    let next = k + 2
    let is_end_tag = {
      let lower_s_sub = lower_s.substring(start=next)
      match s[next] {
        'p' => lower_s_sub.has_prefix("pre>")
        's' =>
          if s[k + 3] == 't' {
            lower_s_sub.has_prefix("style>")
          } else {
            lower_s_sub.has_prefix("script>")
          }
        't' => lower_s_sub.has_prefix("textarea>")
        _ => false
      }
    }
    guard not(is_end_tag) else { break true }
    continue last, k + 1
  }
}

///|
pub fn LineType::html_block_end(
  s : String,
  end_cond~ : HtmlBlockEndCond,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> Bool {
  match end_cond {
    EndStr(str) => @char.sub_includes(s, affix=str, first=start, last~)
    EndCond1 => LineType::html_block_end_cond_1(s, last~, start~)
    EndBlank | EndBlank7 => first_non_blank(s, last~, start~) == last + 1
  }
}

///|
pub fn LineType::ext_table_row(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  guard start <= last && s[start] == '|' else { Nomatch }
  let first = start + 1
  let last_nb = last_non_blank(s, first~, start=last)
  let before = last_nb - 1
  guard last_nb >= first && s[last_nb] == '|' else { Nomatch }
  guard before < first || s[before] != '\\' else { Nomatch }
  ExtTableRow(last_nb)
}

///|
pub fn LineType::ext_footnote_label(
  buf : Buffer,
  s : String,
  line_pos~ : LinePos,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  guard start <= last && s[start] == 91 && s[start + 1] == 94 else { Nomatch }
  let rbrack = first_non_escaped_char(']', s, last~, start=start + 2)
  let colon = rbrack + 1
  guard colon <= last && s[colon] == 58 && colon - start + 1 >= 5 else {
    Nomatch
  }
  // Get the normalized label
  let line = { pos: line_pos, first: start, last }
  guard link_label(buf, next_line=fn(_x) { None }, s, (), line~, start~)
    is Some((_, spans, _, key)) else {
    Nomatch
  }
  ExtFootnoteLabel(spans, colon, key)
}

///|
/// https://spec.commonmark.org/current/#link-reference-definition
pub fn could_be_link_ref_definition(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> Bool {
  if start > last {
    return false
  }
  for s = s, first = start, last = last, k = start {
    guard k <= last else { break false }
    if k - first + 1 < 4 && s[k] == ' ' {
      continue s, first, last, k + 1
    }
    break s[k] == '['
  }
}

// Container blocks

///|
/// https://spec.commonmark.org/current/#list-marker
pub fn LineType::list_marker(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> LineType {
  if start > last {
    return Nomatch
  }
  match s[start].unsafe_to_char() {
    '-' | '+' | '*' as c => {
      let next = start + 1
      if next > last ||
        (s[next].to_char() is Some(c) && @char.is_ascii_blank(c)) {
        ListMarkerLine(Unordered(c), start)
      } else {
        Nomatch
      }
    }
    '0'..='9' as c =>
      for s = s, last = last, count = 1, acc = @char.ascii_digit_to_int(c), k = start +
            1 {
        if k > last || count > 9 {
          return Nomatch
        }
        break match s[k].unsafe_to_char() {
          '0'..='9' as c =>
            continue s,
              last,
              count + 1,
              acc * 10 + @char.ascii_digit_to_int(c),
              k + 1
          '.' | ')' as c => {
            let next = k + 1
            if next > last ||
              (s[next].to_char() is Some(c) && @char.is_ascii_blank(c)) {
              ListMarkerLine(Ordered(acc, c), k)
            } else {
              Nomatch
            }
          }
          _ => Nomatch
        }
      }
    _ => Nomatch
  }
}

///|
pub fn ext_task_marker(
  s : String,
  last~ : CharCodePos,
  start~ : CharCodePos,
) -> (Char, CharCodePos)? {
  guard start < last else { None }
  guard s[start] == '[' else { None }
  let mut next = start + 1
  guard @char.at_checked(s, next) is Ok(u) else { None }
  next += @char.length_utf16(u.to_int())
  guard next <= last && s[next] == ']' else { None }
  next += 1
  guard next <= last else { Some((u, last)) }
  guard s[next] == ' ' else { None }
  Some((u, next))
}

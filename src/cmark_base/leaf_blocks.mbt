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
  match (self, other) {
    (Ordered(_, c0), Ordered(_, c1)) => c0 == c1
    (Unordered(c0), Unordered(c1)) => c0 == c1
    _ => false
  }
}

///|
pub(all) enum LineType {
  AtxHeadingLine(HeadingLevel, BytePos, First, Last)
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
  ExtFootnoteLabel(RevSpans, Last, String)
  Nomatch
} derive(Show, ToJson, Eq)

///| https://spec.commonmark.org/current/#thematic-breaks
pub fn LineType::thematic_break(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  if start > last {
    return Nomatch
  }
  match s[start] {
    '-' | '_' | '*' =>
      loop s, last, 1, start, start + 1 {
        s, last, count, prev, k =>
          if k > last {
            if count < 3 {
              Nomatch
            } else {
              ThematicBreakLine(prev)
            }
          } else if s[k] == s[prev] {
            continue s, last, count + 1, k, k + 1
          } else if s[k] == ' ' || s[k] == '\t' {
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
  last~ : BytePos,
  start~ : BytePos
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
    loop s, last, k {
      s, last, k => {
        guard k <= last else { k - 1 }
        guard s[k] == ' ' || s[k] == '\t' else { continue s, last, k + 1 }
        let end1 = find_end(s, last, k)
        guard end1 <= last else { k - 1 }
        continue s, last, end1
      }
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
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  let level = fn(c) { if c == '=' { 1 } else { 2 } }
  fn underline(s : String, last, start, k) {
    if k > last {
      return SetextUnderlineLine(level(s[start]), k - 1)
    }
    if s[k] == s[start] {
      return underline(s, last, start, k + 1)
    }
    if s[k] != ' ' && s[k] != '\t' {
      return Nomatch
    }
    let end_blank = first_non_blank(s, last~, start=k + 1)
    if end_blank > last {
      return SetextUnderlineLine(level(s[start]), k - 1)
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
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  fn info(s : String, last, nobt, info_first, k) -> _!Exit {
    if k > last {
      return Some((info_first, last))
    }
    if nobt && s[k] == '`' {
      raise Exit
    }
    if s[k] != ' ' && s[k] != '\t' {
      return info!(s, last, nobt, info_first, k + 1)
    }
    let after_blank = first_non_blank(s, last~, start=k)
    if after_blank > last {
      return Some((info_first, k - 1))
    }
    info!(s, last, nobt, info_first, after_blank)
  }

  fn fence(s : String, last, fence_first, k) -> _!Exit {
    loop s, last, fence_first, k {
      s, last, fence_first, k => {
        if k <= last && s[k] == s[fence_first] {
          continue s, last, fence_first, k + 1
        }
        let fence_last = k - 1
        let fcount = fence_last - fence_first + 1
        if fcount < 3 {
          return Nomatch
        }
        let info = {
          let after_blank = first_non_blank(s, last~, start=k)
          if after_blank > last {
            None
          } else {
            info!(s, last, s[fence_first] == '`', after_blank, after_blank)
          }
        }
        FencedCodeBlockLine(fence_first, fence_last, info)
      }
    }
  }

  if start > last {
    return Nomatch
  }
  loop s, start, last, start {
    s, first, last, k => {
      if k > last {
        break Nomatch
      }
      if k - first + 1 < 4 && s[k] == ' ' {
        continue s, first, last, k + 1
      }
      if s[k] != '~' && s[k] != '`' {
        break Nomatch
      }
      try {
        fence!(s, last, k, k + 1)
      } catch {
        Exit => Nomatch
      }
    }
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
  last~ : BytePos,
  start~ : BytePos
) -> FencedCodeBlockContinue {
  if start > last {
    return Code
  }
  let (fc, fcount) = fence
  fn fence(s : String, last, fence_first, k) -> _!Exit {
    loop s, last, fence_first, k {
      s, last, fence_first, k => {
        if k <= last && s[k] == fc {
          continue s, last, fence_first, k + 1
        }
        let fence_last = k - 1
        guard fence_last - fence_first + 1 >= fcount else { raise Exit } // Not closing
        let after_blank = first_non_blank(s, last~, start=k)
        guard after_blank > last else { raise Exit }
        Close(fence_first, fence_last)
      }
    }
  }

  loop s, start, last, start {
    s, first, last, k => {
      if k > last {
        break Code // Short blank line
      }
      if k - first + 1 < 4 && s[k] == ' ' {
        continue s, first, last, k + 1
      }
      if s[k] != fc {
        break Code
      }
      try {
        fence!(s, last, k, k + 1)
      } catch {
        Exit => Code
      }
    }
  }
}

///|
let html_start_cond_1_set : @immut/hashset.T[String] = @immut/hashset.of(
  ["pre", "script", "style", "textarea"],
)

///|
let html_start_cond_6_set : @immut/hashset.T[String] = @immut/hashset.of(
  [
    "address", "article", "aside", "base", "basefont", "blockquote", "body", "caption",
    "center", "col", "colgroup", "dd", "details", "dialog", "dir", "div", "dl", "dt",
    "fieldset", "figcaption", "figure", "footer", "form", "frame", "frameset", "h1",
    "h2", "h3", "h4", "h5", "h6", "head", "header", "hr", "html", "iframe", "legend",
    "li", "link", "main", "menu", "menuitem", "nav", "noframes", "ol", "optgroup",
    "option", "p", "param", "section", "source", "summary", "table", "tbody", "td",
    "tfoot", "th", "thead", "title", "tr", "track", "ul",
  ],
)

///|
fn LineType::html_block_start_5(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  let next = start + 3 // 3 first chars checked
  let sub = "CDATA["
  if start + 8 > last || s.substring(start=next).starts_with(sub).not() {
    return Nomatch
  }
  HtmlBlockLine(EndStr("]]>"))
}

///|
fn LineType::html_block_start_2(
  s : String,
  last~ : BytePos,
  start~ : BytePos
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
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  // Has to be on the same line we fake one and use the inline parser
  let line = { pos: line_pos_none, first: start, last }
  guard let Some((_, _, _, tag_end)) = open_tag(
    next_line=fn(_x) { None },
    s,
    (),
    line~,
    start~,
  ) else {
    _ => return Nomatch
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
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  let line = { pos: line_pos_none, first: start, last }
  guard let Some((_, _, _, tag_end)) = closing_tag(
    next_line=fn(_x) { None },
    s,
    (),
    line~,
    start~,
  ) else {
    _ => return Nomatch
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
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  let next = start + 1
  if next > last || s[start] != '<' {
    return Nomatch
  }
  match s[next] {
    '?' => HtmlBlockLine(EndStr("?>")) // 3
    '!' => {
      let next = next + 1
      if next > last {
        return Nomatch
      }
      match s[next] {
        '[' => html_block_start_5(s, last~, start~)
        '-' => html_block_start_2(s, last~, start~)
        c =>
          if @char.is_ascii_alpha(c) {
            HtmlBlockLine(EndStr(">")) // 4
          } else {
            Nomatch
          }
      }
    }
    c => {
      guard @char.is_ascii_alpha(c) || c == '/' else { return Nomatch }
      let tag_first = if c == '/' { next + 1 } else { next }
      let tag_last = loop s, last, tag_first {
        s, last, i => {
          if i > last || @char.is_ascii_alpha(s[i]).not() {
            break i - 1
          }
          continue s, last, i + 1
        }
      }
      let tag = s.substring(start=tag_first, end=tag_last + 1).to_lower()
      let is_open_end = {
        let n = tag_last + 1
        n > last || s[n] == ' ' || s[n] == '\t' || s[n] == '>'
      }
      let is_open_close_end = is_open_end ||
        (
          tag_last + 2 <= last &&
          s.substring(start=tag_last + 1, end=tag_last + 3) == "/>"
        )
      if c != '/' {
        if html_start_cond_1_set.contains(tag) && is_open_end {
          HtmlBlockLine(EndCond1) // 1
        } else if html_start_cond_6_set.contains(tag) && is_open_close_end {
          HtmlBlockLine(EndBlank) // 6
        } else {
          html_block_start_7_open_tag(s, last~, start~)
        }
      } else if html_start_cond_6_set.contains(tag) && is_open_close_end {
        HtmlBlockLine(EndBlank) // 6
      } else {
        html_block_start_7_close_tag(s, last~, start~)
      }
    }
  }
}

///| https://spec.commonmark.org/current/#html-blocks end condition 1.
fn LineType::html_block_end_cond_1(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> Bool {
  let lower_s = s.to_lower()
  loop last, start {
    last, k => {
      guard k + 3 <= last else { break false }
      guard s[k] == '<' && s[k + 1] == '/' else { continue last, k + 1 }
      let next = k + 2
      let is_end_tag = {
        let lower_s_sub = lower_s.substring(start=next)
        match s[next] {
          'p' => lower_s_sub.starts_with("pre>")
          's' =>
            if s[k + 3] == 't' {
              lower_s_sub.starts_with("style>")
            } else {
              lower_s_sub.starts_with("script>")
            }
          't' => lower_s_sub.starts_with("textarea>")
          _ => false
        }
      }
      guard is_end_tag.not() else { break true }
      continue last, k + 1
    }
  }
}

///|
pub fn LineType::html_block_end(
  s : String,
  end_cond~ : HtmlBlockEndCond,
  last~ : BytePos,
  start~ : BytePos
) -> Bool {
  match end_cond {
    EndStr(str) => @char.sub_includes(s, affix=str, first=start, last~)
    EndCond1 => html_block_end_cond_1(s, last~, start~)
    EndBlank | EndBlank7 => first_non_blank(s, last~, start~) == last + 1
  }
}

///|
pub fn LineType::ext_table_row(
  s : String,
  last~ : BytePos,
  start~ : BytePos
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
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  guard start <= last && s[start] == '[' && s[start + 1] == '^' else { Nomatch }
  let rbrack = first_non_escaped_char(']', s, last~, start=start + 2)
  let colon = rbrack + 1
  guard colon <= last && s[colon] == ':' && colon - start + 1 >= 5 else {
    Nomatch
  }
  // Get the normalized label
  let line = { pos: line_pos, first: start, last }
  guard let Some((_, _, rev_spans, _, key)) = link_label(
    buf,
    next_line=fn(_x) { None },
    s,
    (),
    line~,
    start~,
  ) else {
    _ => Nomatch
  }
  ExtFootnoteLabel(rev_spans, colon, key)
}

// https://spec.commonmark.org/current/#link-reference-definition
///|
pub fn could_be_link_ref_definition(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> Bool {
  if start > last {
    return false
  }
  loop s, start, last, start {
    s, first, last, k => {
      if k > last {
        break false
      }
      if k - first + 1 < 4 && s[k] == ' ' {
        continue s, first, last, k + 1
      }
      s[k] == '['
    }
  }
}

// Container blocks

// https://spec.commonmark.org/current/#list-marker
///|
pub fn LineType::list_marker(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> LineType {
  if start > last {
    return Nomatch
  }
  match s[start] {
    '-' | '+' | '*' as c => {
      let next = start + 1
      if next > last || @char.is_ascii_blank(s[next]) {
        ListMarkerLine(Unordered(c), start)
      } else {
        Nomatch
      }
    }
    '0'..='9' as c =>
      loop s, last, 1, @char.ascii_digit_to_int(c), start + 1 {
        s, last, count, acc, k => {
          if k > last || count > 9 {
            return Nomatch
          }
          match s[k] {
            '0'..='9' as c =>
              continue s,
                last,
                count + 1,
                acc * 10 + @char.ascii_digit_to_int(c),
                k + 1
            '.' | ')' as c => {
              let next = k + 1
              if next > last || @char.is_ascii_blank(s[next]) {
                ListMarkerLine(Ordered(acc, c), k)
              } else {
                Nomatch
              }
            }
            _ => Nomatch
          }
        }
      }
    _ => Nomatch
  }
}

///|
pub fn ext_task_marker(
  s : String,
  last~ : BytePos,
  start~ : BytePos
) -> (Char, BytePos)? {
  guard start < last else { None }
  guard s[start] == '[' else { None }
  let mut next = start + 1
  guard let Ok(u) = @char.at_checked(s, next) else { _ => None }
  next += @char.length_utf16(u)
  guard next <= last && s[next] == ']' else { None }
  next += 1
  guard next <= last else { Some((u, last)) }
  guard s[next] == ' ' else { None }
  Some((u, next))
}

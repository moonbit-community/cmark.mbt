///|
priv struct State {
  safe : Bool
  backend_blocks : Bool
  ids : StringSet
  mut footnote_count : Int
  footnotes : Map[LabelKey, HtmlRenderFootnote]
} derive(Show)

///|
test {
  // Prevent warning about unused Show
  (fn(s : State) { s.to_string() }) |> ignore()
}

///|
priv struct HtmlRenderFootnote {
  text : String
  id : String
  mut count : Int
  footnote : @cmark.Footnote
} derive(Show, ToJson)

///|
test {
  // Prevent warning about unused ToJson
  (fn(h : HtmlRenderFootnote) { h.to_json() }) |> ignore()
}

///|
impl Eq for HtmlRenderFootnote with op_equal(self, other) {
  self.id == other.id
}

///|
impl Compare for HtmlRenderFootnote with compare(self, other) {
  self.id.compare(other.id)
}

///|
priv suberror EState State

///|
typealias Set[String] as StringSet

///|
priv struct Joined[T] {
  iter : Iter[T]
  sep : String
}

///|
pub fn safe(c : Context) -> Bool {
  guard c.state is Some(EState({ safe, .. }))
  safe
}

///|
fn backend_blocks(c : Context) -> Bool {
  guard c.state is Some(EState({ backend_blocks, .. }))
  backend_blocks
}

///|
fn init_context(
  backend_blocks~ : Bool = false,
  safe~ : Bool,
  c : Context,
  _doc : Doc,
) -> Unit {
  let st = {
    safe,
    backend_blocks,
    ids: StringSet::new(),
    footnote_count: 0,
    footnotes: Map::new(),
  }
  c.state = Some(EState(st))
}

///|
fn uid(c : Context, id : String) -> String {
  guard c.state is Some(EState({ ids, .. }))
  for counter = 0 {
    let id1 = if counter == 0 { id } else { "\{id}-\{counter}" }
    if ids.contains(id1) {
      continue counter + 1
    }
    ids.add(id1)
    break id1
  }
}

///|
fn footnote_id(l : String) -> String {
  let res = StringBuilder::new()
  res.write_string("fn-")
  for c in l.substring(start=1) {
    res.write_char(
      match c {
        ' ' | '\t' => '-'
        c => c
      },
    )
  }
  res.to_string()
}

///|
fn footnote_ref_id(fnid : String, c : Int) -> String {
  ["ref", c.to_string(), fnid].join("-")
}

///|
fn make_footnote_ref_ids(
  c : Context,
  label : String,
  f : @cmark.Footnote,
) -> (String, String, String) {
  guard c.state is Some(EState({ footnotes, footnote_count, .. } as st))
  guard footnotes.get(label) is Some({ text, id, .. } as rf) else {
    let footnote_count = footnote_count + 1
    st.footnote_count = footnote_count
    let text = "[\{footnote_count}]"
    let id = footnote_id(label)
    footnotes[label] = { text, id, count: 1, footnote: f }
    (text, id, footnote_ref_id(id, 1))
  }
  rf.count += 1
  (text, id, footnote_ref_id(id, rf.count))
}

// Escaping

///|
fn joined_string(c : Context, join : Joined[String]) -> Unit {
  let mut first = true
  for s in join.iter {
    if not(first) {
      c.b.write_string(join.sep)
    }
    html_escaped_string(c, s)
    first = false
  }
}

///|
// fn buffer_add_html_escaped_char(b : Buffer, ch : Char) -> Unit {
//   match ch {
//     '\u{0}' => b.write_char(@char.rep)
//     '&' => b.write_string("&amp;")
//     '<' => b.write_string("&lt;")
//     '>' => b.write_string("&gt;")
//     // '\'' => b.write_string("&apos;")
//     '"' => b.write_string("&quot;")
//     _ => b.write_char(ch)
//   }
// }

///|
// fn html_escaped_char(c : Context, ch : Char) -> Unit {
//   buffer_add_html_escaped_char(c.b, ch)
// }

///|
fn buffer_add_html_escaped_string(b : Buffer, s : String) -> Unit {
  let len = s.length()
  let max_idx = len - 1
  fn flush(b : Buffer, start : Int, i : Int) {
    if start < len {
      b.write_substring(s, start, i - start)
    }
  }

  for start = 0, i = 0 {
    if i > max_idx {
      flush(b, start, i)
      break
    }
    let next = i + 1
    match s[i] {
      '\u{0}' => {
        flush(b, start, i)
        b.write_char(@char.rep)
        continue next, next
      }
      '&' => {
        flush(b, start, i)
        b.write_string("&amp;")
        continue next, next
      }
      '<' => {
        flush(b, start, i)
        b.write_string("&lt;")
        continue next, next
      }
      '>' => {
        flush(b, start, i)
        b.write_string("&gt;")
        continue next, next
      }
      // '\'' => {
      //  flush(b, start, i)
      //  b.write_string("&apos;")
      //  continue next, next
      //  }
      '"' => {
        flush(b, start, i)
        b.write_string("&quot;")
        continue next, next
      }
      _ => continue start, next
    }
  }
}

///|
fn html_escaped_string(c : Context, s : String) -> Unit {
  buffer_add_html_escaped_string(c.b, s)
}

///|
fn buffer_add_pct_encoded_string(b : Buffer, s : String) -> Unit { // Percent encoded + HTML escaped
  fn unsafe_hexdigit(i : Int) {
    (if i < 10 { i + 0x30 } else { i + 0x37 }).unsafe_to_char()
  }

  // See https://tools.ietf.org/html/rfc3986
  fn is_delim(c : Char) -> Bool {
    c
    is ('%'
    | '-'
    | '.'
    | '_'
    | '~'
    | '!'
    | '$'
    | '('
    | ')'
    | '*'
    | '+'
    | ','
    | ';'
    | '='
    | ':'
    | '/'
    | '?'
    | '#'
    | '@')
  }

  let flush = fn(b : Buffer, max : Int, start : Int, i : Int) -> Unit {
    if start <= max {
      b.write_substring(s, start, i - start)
    }
  }
  let max = s.length() - 1
  for start = 0, i = 0 {
    if i > max {
      flush(b, max, start, i)
      break
    }
    let next = i + 1
    match s[i] {
      c if c.to_char() is Some(c) && (@char.is_ascii_alphanum(c) || is_delim(c)) =>
        continue start, next
      '&' => {
        flush(b, max, start, i)
        b.write_string("&amp;")
        continue next, next
      }
      '\'' => {
        flush(b, max, start, i)
        b.write_string("&apos;")
        continue next, next
      }
      c => {
        flush(b, max, start, i)
        let hi = (c >> 4) & 0xF
        let lo = c & 0xF
        b.write_char('%')
        b.write_char(unsafe_hexdigit(hi))
        b.write_char(unsafe_hexdigit(lo))
        continue next, next
      }
    }
  }
}

///|
fn pct_encoded_string(c : Context, s : String) -> Unit {
  buffer_add_pct_encoded_string(c.b, s)
}

// Rendering functions

///|
fn comment(c : Context, s : String) -> Unit {
  c.b.write_string("<!--")
  html_escaped_string(c, s)
  c.b.write_string("-->")
}

///|
fn comment_undefined_label(c : Context, l : @cmark.InlineLink) -> Unit {
  guard l.referenced_label() is Some(def) else { return }
  comment(c, "Undefined label \{def.key}")
}

// fn comment_unknown_def_type(c : Context, l : @cmark.InlineLink) -> Unit {
//   guard l.referenced_label() is Some(def) else { return  }
//   comment(c, "Unknown label definition type for \{def.key}")
// }

///|
fn comment_footnote_image(c : Context, l : @cmark.InlineLink) -> Unit {
  guard l.referenced_label() is Some(def) else { return }
  comment(c, "Footnote \{def.key} referenced as image")
}

///|
fn block_lines(c : Context, ls : Array[@cmark.StringNode]) -> Unit {
  guard ls.get(0) is Some({ v, .. }) else { return }
  c.b.write_string(v)
  for l in ls[1:] {
    c.b.write_char('\n')
    c.b.write_string(l.v)
  }
}

// Inline rendering

///|
fn autolink(c : Context, a : @cmark.InlineAutolink) -> Unit {
  let pre = if a.is_email { "mailto:" } else { "" }
  let url = pre + a.link.v
  let url = if @cmark.InlineLink::is_unsafe(url) { "" } else { url }
  c.b.write_string("<a href=\"")
  pct_encoded_string(c, url)
  c.b.write_string("\">")
  html_escaped_string(c, a.link.v)
  c.b.write_string("</a>")
}

///|
fn break_(c : Context, b : @cmark.InlineBreak) -> Unit {
  match b.ty {
    Hard => c.b.write_string("<br>\n")
    Soft => c.b.write_char('\n')
  }
}

///|
fn code_span(c : Context, cs : @cmark.InlineCodeSpan) -> Unit {
  c.b.write_string("<code>")
  html_escaped_string(c, cs.code())
  c.b.write_string("</code>")
}

///|
fn emphasis(c : Context, e : @cmark.InlineEmphasis) -> Unit raise {
  c.b.write_string("<em>")
  c.inline(e.inline)
  c.b.write_string("</em>")
}

///|
fn strong_emphasis(c : Context, e : @cmark.InlineEmphasis) -> Unit raise {
  c.b.write_string("<strong>")
  c.inline(e.inline)
  c.b.write_string("</strong>")
}

///|
fn link_dest_and_title(
  c : Context,
  ld : @cmark.LinkDefinition,
) -> (String, Joined[String]?) {
  let dest = match ld.dest {
    None => ""
    Some({ v, .. }) =>
      if safe(c) && @cmark.InlineLink::is_unsafe(v) {
        ""
      } else {
        v
      }
  }
  let title = ld.title.map(fn(title) {
    { iter: title.iter().map(fn(t) { t.node.v }), sep: "\n" }
  })
  (dest, title)
}

///|
fn image(c : Context, i : @cmark.InlineLink, close~ : String = " >") -> Unit {
  match i.reference_definition(c.doc.defs) {
    Some(LinkDef({ v: ld, .. })) => {
      let (link, title) = link_dest_and_title(c, ld)
      c.b.write_string("<img src=\"")
      pct_encoded_string(c, link)
      c.b.write_string("\" alt=\"")
      let lines = i.text.to_plain_text(break_on_soft=false)
      for line in lines {
        let joined = { iter: line.iter(), sep: "\n" }
        joined_string(c, joined)
      }
      c.b.write_char('"')
      if title is Some(title) {
        c.b.write_string(" title=\"")
        joined_string(c, title)
        c.b.write_char('"')
      }
      c.b.write_string(close)
    }
    Some(FootnoteDef(_)) => comment_footnote_image(c, i)
    // Some(_) => comment_unknown_def_type(c, i)
    None => comment_undefined_label(c, i)
  }
}

///|
fn link_footnote(
  c : Context,
  l : @cmark.InlineLink,
  f : @cmark.Footnote,
) -> Unit raise {
  let key = l.referenced_label().unwrap().key
  let (text, label, ref_) = make_footnote_ref_ids(c, key, f)
  let is_full_ref = l.reference is Ref(Full, _, _)
  if is_full_ref {
    c.b.write_string("<a href=\"#")
    pct_encoded_string(c, label)
    c.b.write_string("\" id=\"")
    html_escaped_string(c, ref_)
    c.b.write_string("\" role=\"doc-noteref\">")
    c.inline(l.text)
    c.b.write_string("</a>")
  } else {
    c.b.write_string("<sup><a href=\"#")
    pct_encoded_string(c, label)
    c.b.write_string("\" id=\"")
    html_escaped_string(c, ref_)
    c.b.write_string("\" role=\"doc-noteref\" class=\"fn-label\">")
    c.b.write_string(text)
    c.b.write_string("</a></sup>")
  }
}

///|
fn link(c : Context, l : @cmark.InlineLink) -> Unit raise {
  match l.reference_definition(c.doc.defs) {
    Some(LinkDef({ v: ld, .. })) => {
      let (link, title) = link_dest_and_title(c, ld)
      c.b.write_string("<a href=\"")
      pct_encoded_string(c, link)
      if title is Some(title) {
        c.b.write_string("\" title=\"")
        joined_string(c, title)
      }
      c.b.write_string("\">")
      c.inline(l.text)
      c.b.write_string("</a>")
    }
    Some(FootnoteDef(f)) => link_footnote(c, l, f.v)
    // Some(_) => comment_unknown_def_type(c, l)
    None => comment_undefined_label(c, l)
  }
}

///|
fn raw_html(c : Context, h : @cmark.InlineRawHtml) -> Unit {
  if safe(c) {
    comment(c, "CommonMark raw HTML omitted")
    return
  }
  if h.inner().is_empty() {
    return
  }
  c.b.write_string(h.inner()[0].node.v)
  for x in h.inner().to_array()[1:] {
    c.b.write_char('\n')
    c.b.write_string(x.node.v)
  }
}

///|
fn strikethrough(c : Context, s : @cmark.InlineStrikethrough) -> Unit raise {
  c.b.write_string("<del>")
  c.inline(s.inner())
  c.b.write_string("</del>")
}

///|
fn math_span(c : Context, ms : @cmark.InlineMathSpan) -> Unit {
  fn tex_line(c : Context, l : @cmark.Tight) {
    html_escaped_string(c, l.to_string())
  }

  fn tex_lines(c : Context, ls : ArrayView[@cmark.Tight]) {
    guard ls.length() != 0 else { return }
    let head = ls[0]
    tex_line(c, head)
    for l in ls[1:] {
      c.b.write_char('\n')
      tex_line(c, l)
    }
  }

  let tex = ms.tex_layout
  guard not(tex.is_empty()) else { return }
  let (lb, rb) = if ms.display { ("\\[", "\\]") } else { ("\\(", "\\)") }
  c.b.write_string(lb)
  tex_lines(c, tex.to_array()[:])
  c.b.write_string(rb)
}

///|
fn inline(c : Context, i : @cmark.Inline) -> Bool raise {
  match i {
    Autolink(a) => autolink(c, a.v)
    Break(b) => break_(c, b.v)
    CodeSpan(cs) => code_span(c, cs.v)
    Emphasis(e) => emphasis(c, e.v)
    Image(i) => image(c, i.v)
    Inlines(is_) =>
      for i in is_.v {
        c.inline(i)
      }
    Link(l) => link(c, l.v)
    RawHtml(html) => raw_html(c, html.v)
    StrongEmphasis(e) => strong_emphasis(c, e.v)
    Text(t) => html_escaped_string(c, t.v)
    ExtStrikethrough(s) => strikethrough(c, s.v)
    ExtMathSpan(ms) => math_span(c, ms.v)
    // _ => comment(c, "<!-- Unknown inline -->")
  }
  true
}

// Block rendering

///|
fn block_quote(c : Context, bq : @cmark.BlockQuote) -> Unit raise {
  c.b.write_string("<blockquote>\n")
  c.block(bq.block)
  c.b.write_string("</blockquote>\n")
}

///|
fn code_block(c : Context, cb : @cmark.CodeBlock) -> Unit {
  let i = cb.info_string.map(fn(i) { i.v })
  let lang = i.bind(@cmark.CodeBlock::language_of_info_string)
  let line = fn(l : @cmark.StringNode) {
    html_escaped_string(c, l.v)
    c.b.write_char('\n')
  }
  if lang is Some((lang, _env)) {
    if backend_blocks(c) && lang[0] == '=' {
      if lang == "=html" && not(safe(c)) {
        block_lines(c, cb.code.to_array())
      }
      return
    }
  }
  c.b.write_string("<pre><code")
  if lang is Some((lang, _env)) {
    c.b.write_string(" class=\"language-")
    html_escaped_string(c, lang)
    c.b.write_char('"')
  }
  c.b.write_char('>')
  for l in cb.code {
    line(l)
  }
  c.b.write_string("</code></pre>\n")
}

///|
fn heading(c : Context, h : @cmark.BlockHeading) -> Unit raise {
  c.b.write_string("<h")
  c.b.write_object(h.level)
  match h.id {
    None => c.b.write_char('>')
    Some(Auto(id) | Id(id)) => {
      let id = uid(c, id)
      c.b.write_string(" id=\"")
      c.b.write_string(id)
      c.b.write_string("\"><a class=\"anchor\" aria-hidden=\"true\" href=\"#")
      c.b.write_string(id)
      c.b.write_string("\"></a>")
    }
  }
  c.inline(h.inline)
  c.b.write_string("</h")
  c.b.write_object(h.level)
  c.b.write_string(">\n")
}

///|
fn paragraph(c : Context, p : @cmark.BlockParagraph) -> Unit raise {
  c.b.write_string("<p>")
  c.inline(p.inline)
  c.b.write_string("</p>\n")
}

///|
fn item_block(tight~ : Bool, c : Context, b : @cmark.Block) -> Unit raise {
  match (b, tight) {
    (BlankLine(_), _) => ()
    (Paragraph({ v, .. }), true) => c.inline(v.inline)
    (Blocks({ v, .. }), _) =>
      loop (c, true, v.to_array()[:], tight) {
        (c, add_nl, [BlankLine(_), .. bs], tight) =>
          continue (c, add_nl, bs, tight)
        (c, _, [Paragraph({ v, .. }), .. bs], true as tight) => {
          c.inline(v.inline)
          continue (c, true, bs, tight)
        }
        (c, add_nl, [b, .. bs], tight) => {
          if add_nl {
            c.b.write_char('\n')
          }
          c.block(b)
          continue (c, false, bs, tight)
        }
        _ => ()
      }
    _ => {
      c.b.write_char('\n')
      c.block(b)
    }
  }
}

///|
fn list_item(
  tight~ : Bool,
  c : Context,
  i : @cmark.Node[@cmark.ListItem],
) -> Unit raise {
  c.b.write_string("<li>")
  guard i.v.ext_task_marker is Some(mark) else {
    item_block(tight~, c, i.v.block)
    c.b.write_string("</li>\n")
    return
  }
  let close = match @cmark.ListTaskStatus::from_marker(mark.v) {
    Unchecked => {
      c.b.write_string(
        "<div class=\"task\"><input type=\"checkbox\" disabled><div>",
      )
      "</div></div></li>\n"
    }
    Checked | Other(_) => {
      c.b.write_string(
        "<div class=\"task\"><input type=\"checkbox\" disabled checked><div>",
      )
      "</div></div></li>\n"
    }
    Cancelled => {
      c.b.write_string(
        "<div class=\"task\"><input type=\"checkbox\" disabled><del>",
      )
      "<del></div></li>\n"
    }
  }
  item_block(tight~, c, i.v.block)
  c.b.write_string(close)
}

///|
fn list(c : Context, l : @cmark.BlockList) -> Unit raise {
  let tight = l.tight
  match l.ty {
    Unordered(_) => {
      c.b.write_string("<ul>\n")
      for i in l.items {
        list_item(tight~, c, i)
      }
      c.b.write_string("</ul>\n")
    }
    Ordered(start, _) => {
      c.b.write_string("<ol")
      if start == 1 {
        c.b.write_string(">\n")
      } else {
        c.b.write_string(" start=\"")
        c.b.write_object(start)
        c.b.write_string("\">\n")
      }
      for i in l.items {
        list_item(tight~, c, i)
      }
      c.b.write_string("</ol>\n")
    }
  }
}

///|
fn html_block(c : Context, html : @cmark.HtmlBlock) -> Unit {
  if safe(c) {
    comment(c, "CommonMark HTML block omitted")
    c.b.write_char('\n')
    return
  }
  for l in html.inner() {
    c.b.write_string(l.v)
    c.b.write_char('\n')
  }
}

///|
fn thematic_break(c : Context) -> Unit {
  c.b.write_string("<hr>\n")
}

///|
fn math_block(c : Context, cb : @cmark.CodeBlock) -> Unit {
  c.b.write_string("\\[\n")
  for l in cb.code {
    html_escaped_string(c, l.v)
    c.b.write_char('\n')
  }
  c.b.write_string("\\]\n")
}

///|
fn table(c : Context, t : @cmark.Table) -> Unit raise {
  fn start(c : Context, align : @cmark.TableAlign?, tag) {
    c.b.write_char('<')
    c.b.write_string(tag)
    match align {
      None => c.b.write_char('>')
      Some(Left) => c.b.write_string(" class=\"left\">")
      Some(Center) => c.b.write_string(" class=\"center\">")
      Some(Right) => c.b.write_string(" class=\"right\">")
    }
  }

  fn close(c : Context, tag) {
    c.b.write_string("</")
    c.b.write_string(tag)
    c.b.write_string(">\n")
  }

  fn cols(
    c : Context,
    tag,
    align : ArrayView[@cmark.Node[@cmark.TableSep]],
    count,
    cs : ArrayView[(_, _)],
  ) raise {
    match (align, cs) {
      ([{ v, .. }, .. align], [(col, _), .. cs]) => {
        start(c, v.inner().0, tag)
        c.inline(col)
        close(c, tag)
        cols(c, tag, align, count - 1, cs)
      }
      ([{ v, .. }, .. align], []) => {
        start(c, v.inner().0, tag)
        close(c, tag)
        cols(c, tag, align, count - 1, [][:])
      }
      ([], [(col, _), .. cs]) => {
        start(c, None, tag)
        c.inline(col)
        close(c, tag)
        cols(c, tag, [][:], count - 1, cs)
      }
      ([], []) =>
        for i in 0..<count {
          start(c, None, tag)
          close(c, tag)
        }
    }
  }

  fn row(c : Context, tag, align, count, cs) raise {
    c.b.write_string("<tr>\n")
    cols(c, tag, align, count, cs)
    c.b.write_string("</tr>\n")
  }

  fn header(c : Context, count, align, cols) raise {
    row(c, "th", align, count, cols)
  }

  fn data(c : Context, count, align, cols) raise {
    row(c, "td", align, count, cols)
  }

  fn rows(
    c : Context,
    col_count,
    align : ArrayView[_],
    rs : ArrayView[(@cmark.Node[@cmark.TableRow], _)],
  ) raise {
    match rs {
      [({ v: Header(cols), .. }, _), .. rs] => {
        let (align, rs) = match rs {
          [({ v: Sep(align), .. }, _), .. rs] => (align.to_array()[:], rs)
          _ => (align, rs)
        }
        header(c, col_count, align, cols.to_array()[:])
        rows(c, col_count, align, rs)
      }
      [({ v: Data(cols), .. }, _), .. rs] => {
        data(c, col_count, align, cols.to_array()[:])
        rows(c, col_count, align, rs)
      }
      [({ v: Sep(align), .. }, _), .. rs] =>
        rows(c, col_count, align.to_array()[:], rs)
      [] => ()
    }
  }

  c.b.write_string("<div role=\"region\"><table>\n")
  rows(c, t.col_count, [][:], t.rows.to_array()[:])
  c.b.write_string("</table></div>")
}

///|
fn block(c : Context, b : @cmark.Block) -> Bool raise {
  match b {
    BlockQuote(bq) => block_quote(c, bq.v)
    Blocks(bs) =>
      for b in bs.v {
        c.block(b)
      }
    CodeBlock(cb) => code_block(c, cb.v)
    Heading(h) => heading(c, h.v)
    HtmlBlock(lines) => html_block(c, lines.v)
    List(l) => list(c, l.v)
    Paragraph(p) => paragraph(c, p.v)
    ThematicBreak(_) => thematic_break(c)
    ExtMathBlock(cb) => math_block(c, cb.v)
    ExtTable(t) => table(c, t.v)
    BlankLine(_) | LinkRefDefinition(_) | ExtFootnoteDefinition(_) => ()
  }
  true
}

// XHTML rendering

///|
fn xhtml_block(c : Context, b : @cmark.Block) -> Bool raise {
  match b {
    ThematicBreak(_) => {
      c.b.write_string("<hr />\n")
      true
    }
    _ => block(c, b)
  }
}

///|
fn xhtml_inline(c : Context, i : @cmark.Inline) -> Bool raise {
  match i {
    Break(b) =>
      if b.v.ty == Hard {
        c.b.write_string("<br />\n")
        return true
      }
    Image(i) => {
      image(c, i.v, close=" />")
      return true
    }
    _ => ()
  }
  inline(c, i)
}

// Document rendering

///|
fn footnotes(c : Context, fs : Map[LabelKey, HtmlRenderFootnote]) -> Unit raise {
  let fs = fs.values().to_array()
  fs.sort()
  c.b.write_string("<section role=\"doc-endnotes\"><ol>\n")
  for f in fs {
    let { id, footnote, .. } = f
    c.b.write_string("<li id=\"")
    html_escaped_string(c, id)
    c.b.write_string("\">\n")
    c.block(footnote.block)
    c.b.write_string("<span>")
    let { count: refc, .. } = f
    for r in 1..=refc {
      c.b.write_string("<a href=\"#")
      pct_encoded_string(c, footnote_ref_id(id, r))
      c.b.write_string("\" role=\"doc-backlink\" class=\"fn-label\">↩︎︎")
      if refc > 1 {
        c.b.write_string("<sup>")
        c.b.write_object(r)
        c.b.write_string("</sup>")
      }
      c.b.write_string("</a>")
    }
    c.b.write_string("</span></li>")
  }
  c.b.write_string("</ol></section>\n")
}

///|
fn doc(c : Context, d : Doc) -> Bool raise {
  let _ = c.block(d.block)
  if c.state is Some(fs) {
    guard fs is EState({ footnotes: fs, .. })
    if not(fs.is_empty()) {
      footnotes(c, fs)
    }
  }
  true
}

// Renderer

///|
pub fn renderer(
  backend_blocks~ : Bool = false,
  safe~ : Bool,
) -> @cmark_renderer.Renderer {
  @cmark_renderer.Renderer::new(
    init_context=fn(ctx, doc) { init_context(backend_blocks~, safe~, ctx, doc) },
    inline~,
    block~,
    doc~,
  )
}

///|
pub fn xhtml_renderer(
  backend_blocks~ : Bool = false,
  safe~ : Bool,
) -> @cmark_renderer.Renderer {
  @cmark_renderer.Renderer::new(
    init_context=fn(ctx, doc) { init_context(backend_blocks~, safe~, ctx, doc) },
    inline=xhtml_inline,
    block=xhtml_block,
    doc~,
  )
}

///|
pub fn from_doc(
  backend_blocks~ : Bool = false,
  safe~ : Bool,
  doc : Doc,
) -> String raise {
  renderer(backend_blocks~, safe~).doc_to_string(doc)
}

///|
/// Render CommonMark String to HTML with the default parsing preferences.
///
/// For more parsing options, call `@cmark.Doc::from_string()` and `from_doc()` manually.
pub fn render(
  backend_blocks~ : Bool = false,
  safe~ : Bool = false,
  strict~ : Bool = true,
  s : String,
) -> String raise {
  from_doc(backend_blocks~, safe~, @cmark.Doc::from_string(s, strict~))
}

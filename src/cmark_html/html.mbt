///
struct State {
  safe : Bool
  backend_blocks : Bool
  ids : StringSet
  mut footnote_count : Int
  footnotes : LabelMap[HtmlRenderFootnote]
} derive(Show)

///
struct HtmlRenderFootnote {
  text : String
  id : String
  mut count : Int
  footnote : @cmark.Footnote
} derive(Show, ToJson)

pub(all) type! EState State

typealias StringSet = Set[String]

///
pub fn safe(c : Context) -> Bool {
  guard let Some(EState({ safe, .. })) = c.state
  safe
}

///
fn backend_blocks(c : Context) -> Bool {
  guard let Some(EState({ backend_blocks, .. })) = c.state
  backend_blocks
}

///
fn init_context(
  backend_blocks~ : Bool = false,
  safe~ : Bool,
  c : Context,
  _doc : Doc
) -> Unit {
  let st = {
    safe,
    backend_blocks,
    ids: StringSet::new(),
    footnote_count: 0,
    footnotes: LabelMap::new(),
  }
  c.state = Some(EState(st))
}

///
fn uid(c : Context, id : String) -> String {
  guard let Some(EState({ ids, .. })) = c.state
  loop ids, id, 0 {
    ids, id, c => {
      let id1 = if c == 0 { id } else { "\{id}-\{c}" }
      if ids.contains(id1) {
        continue ids, id, c + 1
      }
      ids.add(id1)
      id1
    }
  }
}

///
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

///
fn footnote_ref_id(fnid : String, c : Int) -> String {
  String::concat(separator="-", ["ref", c.to_string(), fnid])
}

///
fn make_footnote_ref_ids(
  c : Context,
  label : String,
  f : @cmark.Footnote
) -> (String, String, String) {
  guard let Some(EState({ footnotes, footnote_count, .. } as st)) = c.state
  guard let Some({ text, id, count: refc, .. } as rf) = footnotes[label] else {
    None => {
      let footnote_count = footnote_count + 1
      st.footnote_count = footnote_count
      let text = "[\{footnote_count}]"
      let id = footnote_id(label)
      footnotes[label] = { text, id, count: 1, footnote: f }
      (text, id, footnote_ref_id(id, 1))
    }
  }
  let refc = refc + 1
  rf.count = refc
  (text, id, footnote_ref_id(id, refc))
}

// Escaping

///
pub fn buffer_add_html_escaped_char(b : Buffer, ch : Char) -> Unit {
  match ch {
    '\x00' => b.write_char(@char.rep)
    '&' => b.write_string("&amp;")
    '<' => b.write_string("&lt;")
    '>' => b.write_string("&gt;")
    // '\'' => b.write_string("&apos;")
    '"' => b.write_string("&quot;")
    _ => b.write_char(ch)
  }
}

///
pub fn html_escaped_char(c : Context, ch : Char) -> Unit {
  buffer_add_html_escaped_char(c.b, ch)
}

///
pub fn buffer_add_html_escaped_string(b : Buffer, s : String) -> Unit {
  let len = s.length()
  let max_idx = len - 1
  fn flush(b : Buffer, start : Int, i : Int) {
    if start < len {
      b.write_string(s.substring(start~, end=i))
    }
  }

  loop 0, 0 {
    start, i => {
      if i > max_idx {
        flush(b, start, i)
        break
      }
      let next = i + 1
      match s[i] {
        '\x00' => {
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
}

///
pub fn html_escaped_string(c : Context, s : String) -> Unit {
  buffer_add_html_escaped_string(c.b, s)
}

///
pub fn buffer_add_pct_encoded_string(b : Buffer, s : String) -> Unit { // Percent encoded + HTML escaped
  let unsafe_hexdigit = fn(i : Int) -> Byte {
    (if i < 10 { i + 0x30 } else { i + 0x37 }).to_byte()
  }
  let flush = fn(b : Buffer, max : Int, start : Int, i : Int) -> Unit {
    if start <= max {
      b.write_string(s.substring(start~, end=i))
    }
  }
  loop b, s, s.length() - 1, 0, 0 {
    b, s, max, start, i => {
      if i > max {
        flush(b, max, start, i)
        break
      }
      let next = i + 1
      let c = s[i]
      if @char.is_ascii_alphanum(c) ||
        #|-._~!$()*+,;=:/?#@
        .contains_char(c) {
        continue b, s, max, start, next
      }
      if c == '&' {
        flush(b, max, start, i)
        b.write_string("&amp;")
        continue b, s, max, next, next
      }
      if c == '\'' {
        flush(b, max, start, i)
        b.write_string("&apos;")
        continue b, s, max, next, next
      }
      flush(b, max, start, i)
      let hi = (c.to_int() >> 4) & 0xF
      let lo = c.to_int() & 0xF
      b.write_char('%')
      b.write_byte(unsafe_hexdigit(hi))
      b.write_byte(unsafe_hexdigit(lo))
      continue b, s, max, next, next
    }
  }
}

///
pub fn pct_encoded_string(c : Context, s : String) -> Unit {
  buffer_add_pct_encoded_string(c.b, s)
}

// Rendering functions

///
fn comment(c : Context, s : String) -> Unit {
  c.b.write_string("<!--")
  html_escaped_string(c, s)
  c.b.write_string("-->")
}

///
fn comment_undefined_label(c : Context, l : @cmark.InlineLink) -> Unit {
  guard let Some(def) = l.referenced_label() else { _ => return }
  comment(c, "Undefined label \{def.key}")
}

// fn comment_unknown_def_type(c : Context, l : @cmark.InlineLink) -> Unit {
//   guard let Some(def) = l.referenced_label() else { _ => return  }
//   comment(c, "Unknown label definition type for \{def.key}")
// }

///
fn comment_footnote_image(c : Context, l : @cmark.InlineLink) -> Unit {
  guard let Some(def) = l.referenced_label() else { _ => return }
  comment(c, "Footnote \{def.key} referenced as image")
}

///
fn block_lines(c : Context, ls : List[@cmark.StringNode]) -> Unit {
  guard let Cons({ v, .. }, ls) = ls else { _ => return }
  c.b.write_string(v)
  for l in ls {
    c.b.write_char('\n')
    c.b.write_string(l.v)
  }
}

// Inline rendering

///
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

///
fn break_(c : Context, b : @cmark.InlineBreak) -> Unit {
  match b.ty {
    Hard => c.b.write_string("<br>\n")
    Soft => c.b.write_char('\n')
  }
}

///
fn code_span(c : Context, cs : @cmark.InlineCodeSpan) -> Unit {
  c.b.write_string("<code>")
  html_escaped_string(c, cs.code())
  c.b.write_string("</code>")
}

///
fn emphasis!(c : Context, e : @cmark.InlineEmphasis) -> Unit {
  c.b.write_string("<em>")
  c.inline!(e.inline)
  c.b.write_string("</em>")
}

///
fn strong_emphasis!(c : Context, e : @cmark.InlineEmphasis) -> Unit {
  c.b.write_string("<strong>")
  c.inline!(e.inline)
  c.b.write_string("</strong>")
}

///
fn link_dest_and_title(
  c : Context,
  ld : @cmark.LinkDefinition
) -> (String, String) {
  let dest = match ld.dest {
    None => ""
    Some({ v, .. }) =>
      if safe(c) && @cmark.InlineLink::is_unsafe(v) {
        ""
      } else {
        v
      }
  }
  let title = match ld.title {
    None => ""
    Some(title) =>
      title.iter().map(fn(t) { t.node.v }).to_array()
      |> String::concat(separator="\n")
  }
  (dest, title)
}

///
fn image(c : Context, i : @cmark.InlineLink, close~ : String = " >") -> Unit {
  match i.reference_definition(c.doc.defs) {
    Some(LinkDef({ v: ld, .. })) => {
      let plain_text = fn(i : @cmark.Inline) -> String {
        let lines = i.to_plain_text(break_on_soft=false)
        lines.map(fn(l) { String::concat(l.to_array()) }).to_array()
        |> String::concat(separator="\n")
      }
      let (link, title) = link_dest_and_title(c, ld)
      c.b.write_string("<img src=\"")
      pct_encoded_string(c, link)
      c.b.write_string("\" alt=\"")
      html_escaped_string(c, plain_text(i.text))
      c.b.write_char('"')
      if title != "" {
        c.b.write_string(" title=\"")
        html_escaped_string(c, title)
        c.b.write_char('"')
      }
      c.b.write_string(close)
    }
    Some(FootnoteDef(_)) => comment_footnote_image(c, i)
    // Some(_) => comment_unknown_def_type(c, i)
    None => comment_undefined_label(c, i)
  }
}

///
fn link_footnote!(
  c : Context,
  l : @cmark.InlineLink,
  f : @cmark.Footnote
) -> Unit {
  let key = l.referenced_label().unwrap().key
  let (text, label, ref_) = make_footnote_ref_ids(c, key, f)
  let is_full_ref = match l.reference {
    Ref(Full, _, _) => true
    _ => false
  }
  if is_full_ref {
    c.b.write_string("<a href=\"#")
    pct_encoded_string(c, label)
    c.b.write_string("\" id=\"")
    html_escaped_string(c, ref_)
    c.b.write_string("\" role=\"doc-noteref\">")
    c.inline!(l.text)
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

///
fn link!(c : Context, l : @cmark.InlineLink) -> Unit {
  match l.reference_definition(c.doc.defs) {
    Some(LinkDef({ v: ld, .. })) => {
      let (link, title) = link_dest_and_title(c, ld)
      c.b.write_string("<a href=\"")
      pct_encoded_string(c, link)
      if title != "" {
        c.b.write_string("\" title=\"")
        html_escaped_string(c, title)
      }
      c.b.write_string("\">")
      c.inline!(l.text)
      c.b.write_string("</a>")
    }
    Some(FootnoteDef(f)) => link_footnote!(c, l, f.v)
    // Some(_) => comment_unknown_def_type(c, l)
    None => comment_undefined_label(c, l)
  }
}

///
fn raw_html(c : Context, h : @cmark.InlineRawHtml) -> Unit {
  if safe(c) {
    comment(c, "CommonMark raw HTML omitted")
    return
  }
  if h._.is_empty() {
    return
  }
  c.b.write_string(h._.unsafe_head().node.v)
  for x in h._.tail() {
    c.b.write_char('\n')
    c.b.write_string(x.node.v)
  }
}

///
fn strikethrough!(c : Context, s : @cmark.InlineStrikethrough) -> Unit {
  c.b.write_string("<del>")
  c.inline!(s._)
  c.b.write_string("</del>")
}

///
fn math_span(c : Context, ms : @cmark.InlineMathSpan) -> Unit {
  fn tex_line(c : Context, l : @cmark.Tight) {
    html_escaped_string(c, l.to_string())
  }

  fn tex_lines(c : Context, ls : List[@cmark.Tight]) {
    guard let Some(head) = ls.head() else { _ => return }
    tex_line(c, head)
    for l in ls.tail() {
      c.b.write_char('\n')
      tex_line(c, l)
    }
  }

  let tex = ms.tex_layout
  guard tex.is_empty().not() else { return }
  let (lb, rb) = if ms.display { ("\\[", "\\]") } else { ("\\(", "\\)") }
  c.b.write_string(lb)
  tex_lines(c, tex)
  c.b.write_string(rb)
}

///
fn inline!(c : Context, i : @cmark.Inline) -> Bool {
  match i {
    Autolink(a) => autolink(c, a.v)
    Break(b) => break_(c, b.v)
    CodeSpan(cs) => code_span(c, cs.v)
    Emphasis(e) => emphasis!(c, e.v)
    Image(i) => image(c, i.v)
    Inlines(is_) =>
      for i in is_.v {
        c.inline!(i)
      }
    Link(l) => link!(c, l.v)
    RawHtml(html) => raw_html(c, html.v)
    StrongEmphasis(e) => strong_emphasis!(c, e.v)
    Text(t) => html_escaped_string(c, t.v)
    ExtStrikethrough(s) => strikethrough!(c, s.v)
    ExtMathSpan(ms) => math_span(c, ms.v)
    // _ => comment(c, "<!-- Unknown inline -->")
  }
  true
}

// Block rendering

///
fn block_quote!(c : Context, bq : @cmark.BlockQuote) -> Unit {
  c.b.write_string("<blockquote>\n")
  c.block!(bq.block)
  c.b.write_string("</blockquote>\n")
}

///
fn code_block(c : Context, cb : @cmark.CodeBlock) -> Unit {
  let i = cb.info_string.map(fn(i) { i.v })
  let lang = i.bind(@cmark.CodeBlock::language_of_info_string)
  let line = fn(l : @cmark.StringNode) {
    html_escaped_string(c, l.v)
    c.b.write_char('\n')
  }
  match lang {
    Some((lang, _env)) =>
      if backend_blocks(c) && lang[0] == '=' {
        if lang == "=html" && safe(c).not() {
          block_lines(c, cb.code)
        }
        return
      }
    _ => ()
  }
  c.b.write_string("<pre><code")
  match lang {
    None => ()
    Some((lang, _env)) => {
      c.b.write_string(" class=\"language-")
      html_escaped_string(c, lang)
      c.b.write_char('"')
    }
  }
  c.b.write_char('>')
  for l in cb.code {
    line(l)
  }
  c.b.write_string("</code></pre>\n")
}

///
fn heading!(c : Context, h : @cmark.BlockHeading) -> Unit {
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
  c.inline!(h.inline)
  c.b.write_string("</h")
  c.b.write_object(h.level)
  c.b.write_string(">\n")
}

///
fn paragraph!(c : Context, p : @cmark.BlockParagraph) -> Unit {
  c.b.write_string("<p>")
  c.inline!(p.inline)
  c.b.write_string("</p>\n")
}

///
fn item_block!(tight~ : Bool, c : Context, b : @cmark.Block) -> Unit {
  match (b, tight) {
    (BlankLine(_), _) => ()
    (Paragraph({ v, .. }), true) => c.inline!(v.inline)
    (Blocks({ v, .. }), _) =>
      loop c, true, v, tight {
        c, add_nl, Cons(BlankLine(_), bs), tight =>
          continue c, add_nl, bs, tight
        c, _, Cons(Paragraph({ v, .. }), bs), true as tight => {
          c.inline!(v.inline)
          continue c, true, bs, tight
        }
        c, add_nl, Cons(b, bs), tight => {
          if add_nl {
            c.b.write_char('\n')
          }
          c.block!(b)
          continue c, false, bs, tight
        }
        _, _, _, _ => ()
      }
    _ => {
      c.b.write_char('\n')
      c.block!(b)
    }
  }
}

///
fn list_item!(
  tight~ : Bool,
  c : Context,
  i : @cmark.Node[@cmark.ListItem]
) -> Unit {
  c.b.write_string("<li>")
  guard let Some(mark) = i.v.ext_task_marker else {
    _ => {
      item_block!(tight~, c, i.v.block)
      c.b.write_string("</li>\n")
      return
    }
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
  item_block!(tight~, c, i.v.block)
  c.b.write_string(close)
}

///
fn list!(c : Context, l : @cmark.BlockList) -> Unit {
  let tight = l.tight
  match l.ty {
    Unordered(_) => {
      c.b.write_string("<ul>\n")
      for i in l.items {
        list_item!(tight~, c, i)
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
        list_item!(tight~, c, i)
      }
      c.b.write_string("</ol>\n")
    }
  }
}

///
fn html_block(c : Context, html : @cmark.HtmlBlock) -> Unit {
  if safe(c) {
    comment(c, "CommonMark HTML block omitted")
    c.b.write_char('\n')
    return
  }
  for l in html._ {
    c.b.write_string(l.v)
    c.b.write_char('\n')
  }
}

///
fn thematic_break(c : Context) -> Unit {
  c.b.write_string("<hr>\n")
}

///
fn math_block(c : Context, cb : @cmark.CodeBlock) -> Unit {
  c.b.write_string("\\[\n")
  for l in cb.code {
    html_escaped_string(c, l.v)
    c.b.write_char('\n')
  }
  c.b.write_string("\\]\n")
}

///
fn table!(c : Context, t : @cmark.Table) -> Unit {
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

  fn cols!(
    c : Context,
    tag,
    align : List[@cmark.Node[(_, _)]],
    count,
    cs : List[(_, _)]
  ) {
    match (align, cs) {
      (Cons({ v, .. }, align), Cons((col, _), cs)) => {
        start(c, v.0, tag)
        c.inline!(col)
        close(c, tag)
        cols!(c, tag, align, count - 1, cs)
      }
      (Cons({ v, .. }, align), Nil) => {
        start(c, v.0, tag)
        close(c, tag)
        cols!(c, tag, align, count - 1, Nil)
      }
      (Nil, Cons((col, _), cs)) => {
        start(c, None, tag)
        c.inline!(col)
        close(c, tag)
        cols!(c, tag, Nil, count - 1, cs)
      }
      (Nil, Nil) =>
        for i in 0..<count {
          start(c, None, tag)
          close(c, tag)
        }
    }
  }

  fn row!(c : Context, tag, align : List[_], count, cs : List[_]) {
    c.b.write_string("<tr>\n")
    cols!(c, tag, align, count, cs)
    c.b.write_string("</tr>\n")
  }

  fn header!(c : Context, count, align, cols) {
    row!(c, "th", align, count, cols)
  }

  fn data!(c : Context, count, align, cols) {
    row!(c, "td", align, count, cols)
  }

  fn rows!(
    c : Context,
    col_count,
    align : List[_],
    rs : List[(@cmark.Node[@cmark.TableRow], _)]
  ) {
    match rs {
      Cons(({ v: Header(cols), .. }, _), rs) => {
        let (align, rs) = match rs {
          Cons(({ v: Sep(align), .. }, _), rs) => (align, rs)
          _ => (align, rs)
        }
        header!(c, col_count, align, cols)
        rows!(c, col_count, align, rs)
      }
      Cons(({ v: Data(cols), .. }, _), rs) => {
        data!(c, col_count, align, cols)
        rows!(c, col_count, align, rs)
      }
      Cons(({ v: Sep(align), .. }, _), rs) => rows!(c, col_count, align, rs)
      Nil => ()
    }
  }

  c.b.write_string("<div role=\"region\"><table>\n")
  rows!(c, t.col_count, Nil, t.rows)
  c.b.write_string("</table></div>")
}

///
fn block!(c : Context, b : @cmark.Block) -> Bool {
  match b {
    BlockQuote(bq) => block_quote!(c, bq.v)
    Blocks(bs) =>
      for b in bs.v {
        c.block!(b)
      }
    CodeBlock(cb) => code_block(c, cb.v)
    Heading(h) => heading!(c, h.v)
    HtmlBlock(lines) => html_block(c, lines.v)
    List(l) => list!(c, l.v)
    Paragraph(p) => paragraph!(c, p.v)
    ThematicBreak(_) => thematic_break(c)
    ExtMathBlock(cb) => math_block(c, cb.v)
    ExtTable(t) => table!(c, t.v)
    BlankLine(_) | LinkRefDefinition(_) | ExtFootnoteDefinition(_) => ()
  }
  true
}

// XHTML rendering

///
fn xhtml_block!(c : Context, b : @cmark.Block) -> Bool {
  match b {
    ThematicBreak(_) => {
      c.b.write_string("<hr />\n")
      true
    }
    _ => block!(c, b)
  }
}

///
fn xhtml_inline!(c : Context, i : @cmark.Inline) -> Bool {
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
  inline!(c, i)
}

// Document rendering

///
fn footnotes!(c : Context, fs : LabelMap[HtmlRenderFootnote]) -> Unit {
  let fs = fs.values().to_array()
  fs.sort_by_key(fn(f) { f.id })
  c.b.write_string("<section role=\"doc-endnotes\"><ol>\n")
  for f in fs {
    let { id, footnote, .. } = f
    c.b.write_string("<li id=\"")
    html_escaped_string(c, id)
    c.b.write_string("\">\n")
    c.block!(footnote.block)
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
    c.b.write_string("</span>")
    c.b.write_string("</li>")
  }
  c.b.write_string("</ol></section>\n")
}

///
fn doc!(c : Context, d : Doc) -> Bool {
  let _ = c.block!(d.block)
  match c.state {
    Some(fs) => {
      guard let EState({ footnotes: fs, .. }) = fs
      if fs.is_empty().not() {
        footnotes!(c, fs)
      }
    }
    None => ()
  }
  true
}

// Renderer

///
pub fn renderer(
  backend_blocks~ : Bool = false,
  safe~ : Bool
) -> @cmark_renderer.Renderer {
  @cmark_renderer.Renderer::new(
    init_context=fn(ctx, doc) { init_context(backend_blocks~, safe~, ctx, doc) },
    inline~,
    block~,
    doc~,
  )
}

///
pub fn xhtml_renderer(
  backend_blocks~ : Bool = false,
  safe~ : Bool
) -> @cmark_renderer.Renderer {
  @cmark_renderer.Renderer::new(
    init_context=fn(ctx, doc) { init_context(backend_blocks~, safe~, ctx, doc) },
    inline=xhtml_inline,
    block=xhtml_block,
    doc~,
  )
}

///
pub fn from_doc!(
  backend_blocks~ : Bool = false,
  safe~ : Bool,
  doc : Doc
) -> String {
  renderer(backend_blocks~, safe~).doc_to_string!(doc)
}

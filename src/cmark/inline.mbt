// Inlines.
// NOTE: Document data in inline nodes is always stored unescaped and with entity and character references resolved.

///|
pub(all) enum Inline {
  Autolink(Node[InlineAutolink])
  Break(Node[InlineBreak])
  CodeSpan(Node[InlineCodeSpan])
  Emphasis(Node[InlineEmphasis])
  Image(Node[InlineLink])
  Inlines(Node[Seq[Inline]])
  Link(Node[InlineLink])
  RawHtml(Node[InlineRawHtml])
  StrongEmphasis(Node[InlineEmphasis])
  Text(Node[InlineText])
  ExtStrikethrough(Node[InlineStrikethrough])
  ExtMathSpan(Node[InlineMathSpan])
} derive(Eq, Show, ToJson)

///|
pub fn Inline::empty() -> Inline {
  Inlines({ v: [], meta: Meta::none() })
}

///|
pub fn Inline::is_empty(self : Inline) -> Bool {
  match self {
    Inlines({ v: raw, .. }) => raw.is_empty()
    Text({ v: raw, .. }) => raw.is_empty()
    _ => false
  }
}

///| `meta(i)` is the metadata of `i`.
pub fn Inline::meta(
  self : Inline,
  // ext~ : (Inline) -> Meta!InvalidArgumentError = fn(_i) {
  //   raise InvalidArgumentError("Inline.meta")
  // }
) -> Meta {
  match self {
    Autolink({ meta, .. })
    | Break({ meta, .. })
    | CodeSpan({ meta, .. })
    | Emphasis({ meta, .. })
    | Image({ meta, .. })
    | Inlines({ meta, .. })
    | Link({ meta, .. })
    | RawHtml({ meta, .. })
    | StrongEmphasis({ meta, .. })
    | Text({ meta, .. })
    | ExtStrikethrough({ meta, .. })
    | ExtMathSpan({ meta, .. }) => meta
  }
}

///| `normalize(i)` has the same content as `i` but is such that for any
/// occurence of `Inlines(is, _)` in `i` the list of inlines `is`:
/// - `is` is not a singleton list.
/// - Has no two consecutive `Text _` cases. If that occurs the texts are
///   concatenated, the meta of the first one is kept and its text
///   location extended to include the second one.
/// - Has no `Inlines _` case. The meta is dropped and the nested
///   inlines are spliced in `is` where the case occurs.
pub fn Inline::normalize(self : Inline) -> Inline {
  match self {
    Autolink(_)
    | Break(_)
    | CodeSpan(_)
    | RawHtml(_)
    | Text(_)
    | Inlines({ v: Seq([]), .. })
    | ExtMathSpan(_) as i => i
    Image({ v: raw, meta }) =>
      Image({ v: { ..raw, text: raw.text.normalize() }, meta })
    Link({ v: raw, meta }) =>
      Link({ v: { ..raw, text: raw.text.normalize() }, meta })
    Emphasis({ v: raw, meta }) =>
      Emphasis({ v: { ..raw, inline: raw.inline.normalize() }, meta })
    StrongEmphasis({ v: raw, meta }) =>
      StrongEmphasis({ v: { ..raw, inline: raw.inline.normalize() }, meta })
    ExtStrikethrough({ v: raw, meta }) =>
      ExtStrikethrough({ v: raw.inner().normalize(), meta })
    Inlines({ v: Seq([i]), .. }) => i
    Inlines({ v: Seq([i, .. is_]), meta }) => {
      let acc = [i.normalize()]
      let is_ = Array::from_iter(is_.iter())
      for {
        guard is_.pop() is Some(curr) else { break }
        match curr {
          Inlines({ v: is1, .. }) =>
            for i1 in is1.inner().rev() {
              is_.push(i1)
            }
          Text({ v: t1, meta: meta1 }) as i1 =>
            match acc {
              [.., Text({ v: t, meta })] =>
                acc[acc.length() - 1] = Text({
                  v: t + t1,
                  meta: { ..meta, loc: meta.loc.span(meta1.loc) },
                })
              _ => acc.push(i1.normalize())
            }
          i => acc.push(i.normalize())
        }
      }
      match acc {
        [i] => i
        is_ => Inlines({ v: is_, meta })
      }
    }
  }
}

///| `to_plain_text(i, break_on_soft~, acc~)` has the plain text of `i`
/// as a sequence of lines represented by a list of strings to be
/// concatenated. If `break_on_soft` is `true` soft line breaks
/// are turned into hard line breaks.
pub fn Inline::to_plain_text(
  self : Inline,
  break_on_soft~ : Bool,
) -> Seq[Seq[String]] {
  let acc = Seq::from_array([Seq::empty()])
  let push = fn(s) { acc[acc.length() - 1].inner().push(s) }
  let newline = fn() { acc.inner().push([]) }
  let st = [self]
  for {
    guard st.pop() is Some(curr) else { break }
    match curr {
      Autolink(a) => push("<\{a.v.link.v}>")
      Break({ v: { ty: Hard, .. }, .. }) => newline()
      Break({ v: { ty: Soft, .. }, .. }) =>
        if break_on_soft {
          newline()
        } else {
          push(" ")
        }
      CodeSpan(cs) => push(cs.v.code())
      Emphasis({ v: { inline, .. }, .. })
      | StrongEmphasis({ v: { inline, .. }, .. }) => st.push(inline)
      Inlines({ v: is1, .. }) =>
        for i in is1.inner().rev() {
          st.push(i)
        }
      Link(l) => st.push(l.v.text)
      RawHtml(_) => ()
      Text(t) => push(t.v)
      ExtStrikethrough(i) => st.push(i.v.inner())
      ExtMathSpan(m) => push(m.v.tex())
      i => st.push(i)
    }
  }
  acc
}

///|
pub fn Inline::id(
  self : Inline,
  buf~ : Buffer = Buffer::new(size_hint=256),
) -> String {
  let text = self.to_plain_text(break_on_soft=false)
  let s = text.inner().map(fn(l) { l.inner().join("") }).join("\n")
  // Collapses non initial white 
  let collapse_blanks = fn(prev) {
    if @char.is_ascii_blank(prev) && not(buf.is_empty()) {
      buf.write_char('-')
    }
  }
  let max = s.length() - 1
  for prev = '\u{0}', k = 0 {
    if k > max {
      break buf.to_string()
    }
    match s.get_char(k).unwrap() {
      ' ' | '\t' as prev_ccode => continue prev_ccode, k + 1
      '_' | '-' as c => {
        collapse_blanks(prev)
        buf.write_char(c)
        continue c, k + 1
      }
      c => {
        collapse_blanks(prev)
        let mut u = s.get_char(k).unwrap()
        if u == '\u{0000}' {
          u = @char.rep
        }
        let k = k + @char.length_utf16(u.to_int())
        if @char.is_ascii_punctuation(c) || @unicode.is_punctuation(c) {
          continue '\u{0}', k
        }
        match @casefold.casefold_char(u) {
          One(c) => buf.write_char(c)
          Two(c1, c2) => {
            buf.write_char(c1)
            buf.write_char(c2)
          }
          Three(c1, c2, c3) => {
            buf.write_char(c1)
            buf.write_char(c2)
            buf.write_char(c3)
          }
        }
        let prev = c
        continue prev, k
      }
    }
  }
}

///|
pub(all) struct InlineAutolink {
  /// https://spec.commonmark.org/0.30/#email-address
  is_email : Bool
  /// https://spec.commonmark.org/0.30/#absolute-uri
  /// https://spec.commonmark.org/0.30/#email-address
  link : StringNode
} derive(Eq, Show, ToJson)

///|
pub fn InlineAutolink::new(link : StringNode) -> InlineAutolink {
  let raw_link = "<{$link.raw}>"
  { is_email: not(@cmark_base.autolink_email(raw_link).is_empty()), link }
}

///|
pub(all) struct InlineBreak {
  layout_before : BlanksNode
  ty : InlineBreakType
  layout_after : BlanksNode
} derive(Eq, Show, ToJson)

///|
pub fn InlineBreak::new(
  layout_before~ : BlanksNode = layout_empty,
  layout_after~ : BlanksNode = layout_empty,
  ty : InlineBreakType,
) -> InlineBreak {
  { layout_before, ty, layout_after }
}

///|
pub(all) enum InlineBreakType {
  Hard
  Soft
} derive(Eq, Compare, Show, FromJson, ToJson)

///| The type for [code spans](https://spec.commonmark.org/0.30/#code-spans).
pub(all) struct InlineCodeSpan {
  backticks : Count
  code_layout : Seq[Tight]
} derive(Eq, Show, ToJson)

///|
pub fn InlineCodeSpan::new(
  backticks~ : Count,
  code_layout : Seq[Tight],
) -> InlineCodeSpan {
  { backticks, code_layout }
}

///|
fn InlineCodeSpan::min_backticks(
  min~ : Count,
  counts : @sorted_set.T[Count],
) -> Count {
  let mut min = min
  for c in counts {
    guard min == c else { return min }
    min = c + 1
  }
  min
}

///| `from_string(s)` is a code span for `s`. `s` can start with or
/// include backticks; the appropriate minimal backtick count and
/// possible needed leading and trailing space are computed
/// accordingly. If `s` contains newlines, blanks after newlines
/// are treated as layout like during parsing. `meta` is used for
/// the lines of the resulting code layout (see `code_layout`).
/// the resulting code layout (see `code_layout`).
pub fn InlineCodeSpan::from_string(
  meta~ : Meta = Meta::none(),
  s : String,
) -> InlineCodeSpan {
  if s.is_empty() {
    return { backticks: 1, code_layout: [Tight::empty(meta~)] }
  }
  // This finds out the needed backtick count, whether spaces are needed,
  // and treats blanks after newline as layout 
  let max = s.length() - 1
  let need_sp = s is (['`', ..] | [.., '`'])
  let s = if need_sp { " \{s} " } else { s }
  let bt_counts = @sorted_set.new()
  let acc = []
  let code_layout = for btc = 0, start = 0, k = 0 {
    if k > max {
      // assert (btc = 0) because of [need_sp]
      let layout = if acc.is_empty() {
        [{ blanks: "", node: { v: s, meta } }]
      } else {
        BlockLine::flush_tight(meta~, s, start, max, acc)
        acc
      }
      break layout
    }
    let sk = s[k]
    if sk == '`' {
      continue btc + 1, start, k + 1
    }
    if btc > 0 {
      bt_counts.add(btc)
    }
    guard sk is ('\n' | '\r') else { continue 0, start, k + 1 }
    BlockLine::flush_tight(meta~, s, start, k - 1, acc)
    let start = if k + 1 <= max && sk == '\r' && s[k + 1] == '\n' {
      k + 2
    } else {
      k + 1
    }
    continue 0, start, start
  }
  { code_layout, backticks: InlineCodeSpan::min_backticks(min=1, bt_counts) }
}

///| https://spec.commonmark.org/0.30/#code-spans
pub fn InlineCodeSpan::code(self : InlineCodeSpan) -> String {
  let s = self.code_layout.iter().map(Tight::to_string).to_array().join(" ")
  guard s != "" else { "" }
  if s is [' ', .. mid, ' '] && not(mid.iter().all(fn(it) { it == ' ' })) {
    return s.substring(start=1, end=s.length() - 1)
  }
  s
}

///| The type for emphasis and strong emphasis.
/// https://spec.commonmark.org/0.30/#emphasis-and-strong-emphasis
pub(all) struct InlineEmphasis {
  delim : Char
  inline : Inline
} derive(Eq, Show, ToJson)

///|
pub fn InlineEmphasis::new(
  delim~ : Char = '*',
  inline : Inline,
) -> InlineEmphasis {
  { delim, inline }
}

///|
pub(all) struct InlineLink {
  text : Inline
  reference : ReferenceKind
} derive(Eq, Show, ToJson)

///|
pub(all) enum ReferenceKind {
  /// https://spec.commonmark.org/0.30/#inline-link
  Inline(Node[LinkDefinition])
  /// https://spec.commonmark.org/0.30/#reference-link
  /// First label is the label of the reference, second label is the label of the referenced definition.
  Ref(ReferenceLayout, Label, Label)
} derive(Eq, Show, ToJson)

///|
/// The type for reference link layouts.
pub(all) enum ReferenceLayout {
  /// https://spec.commonmark.org/0.30/#collapsed-reference-link
  Collapsed
  /// https://spec.commonmark.org/0.30/#full-reference-link
  Full
  /// https://spec.commonmark.org/0.30/#shortcut-reference-link
  Shortcut
} derive(Eq, Show, FromJson, ToJson)

///|
pub fn InlineLink::new(text : Inline, reference : ReferenceKind) -> InlineLink {
  { text, reference }
}

///| `referenced_label(l)` is the label referenced by the label of `l`.
/// This is the second label of `Ref(_)` or `None` on inline references.
pub fn InlineLink::referenced_label(self : InlineLink) -> Label? {
  match self.reference {
    Inline(_) => None
    Ref(_, _, label) => Some(label)
  }
}

///| `reference_definition(defs, l)` is the definition of `l`'s reference.
/// If `l` is an `Inline` reference this returns its link definition
/// wrapped in a `LinkDef`. If `l` is `Ref` this looks up the
/// `referenced_label` in `defs`.
pub fn InlineLink::reference_definition(
  self : InlineLink,
  defs : LabelDefs,
) -> LabelDef? {
  match self.reference {
    Inline(ld) => Some(LinkDef(ld))
    Ref(_, _, def) => defs.get(def.key)
  }
}

///| `is_unsafe(l)` is `true` if `l` is deemed unsafe.
/// This is the case if `l` starts with a caseless match of
/// `javascript:`, `vbscript:`, `file:` or `data:` except if
/// `data:image/{gif,png,jpeg,webp}`.
/// These rules were taken from the C reference implementation of CommonMark
/// and are likely incomplete. If you are trying to prevent XSS you should
/// post-process rendering outputs with a dedicated HTML sanitizer.
pub fn InlineLink::is_unsafe(l : String) -> Bool {
  let allowed_data_url = fn(l : String) {
    // Extract mediatype from data:[<mediatype>][;base64],<data>
    let start_offset = 4
    let j = match l.view(start_offset~).find(",") {
      Some(i) => i + start_offset
      None => return false
    }
    let k = match l.view(start_offset~).find(";") {
      Some(i) => i + start_offset
      None => j
    }
    let allowed = ["image/gif", "image/png", "image/jpeg", "image/webp"]
    allowed.contains(l.substring(start=5, end=@cmp.minimum(j, k)))
  }
  let lower = @casefold.casefold(l)
  lower.has_prefix("javascript:") ||
  lower.has_prefix("vbscript:") ||
  lower.has_prefix("file:") ||
  (lower.has_prefix("data:") && not(allowed_data_url(l)))
}

///| The type for [inline raw HTML](https://spec.commonmark.org/0.30/#raw-html) (can span multiple lines).
pub(all) type InlineRawHtml Seq[Tight] derive(Eq, Show, ToJson)

///| The type for [textual content](https://spec.commonmark.org/0.30/#textual-content).
///
/// Normally these strings should not contain newlines. This can
/// however happen if the source had newlines as
/// [character references](https://spec.commonmark.org/0.30/#entity-and-numeric-character-references).
pub typealias String as InlineText

// Extensions

///|
pub(all) type InlineStrikethrough Inline derive(Eq, Show, ToJson)

///|
pub(all) struct InlineMathSpan {
  display : Bool
  tex_layout : Seq[Tight]
} derive(Eq, Show, ToJson)

///|
pub fn InlineMathSpan::tex(self : Self) -> String {
  self.tex_layout.inner().map(Tight::to_string).join(" ")
}

// Inlines.
// NOTE: Document data in inline nodes is always stored unescaped and with entity and character references resolved.

pub enum Inline {
  Autolink(Node[InlineAutolink])
  Break(Node[InlineBreak])
  CodeSpan(Node[InlineCodeSpan])
  Emphasis(Node[InlineEmphasis])
  Image(Node[InlineLink])
  Inlines(Node[List[Inline]])
  Link(Node[InlineLink])
  RawHtml(Node[InlineRawHtml])
  StrongEmphasis(Node[InlineEmphasis])
  Text(Node[InlineText])
  ExtStrikethrough(Node[InlineStrikethrough])
  // ExtMathSpan
} derive(Eq, Show, FromJson, ToJson)

pub fn Inline::empty() -> Inline {
  Inlines({ v: Nil, meta: Meta::none() })
}

pub fn Inline::is_empty(self : Inline) -> Bool {
  match self {
    Inlines({ v: raw, .. }) => raw.is_empty()
    Text({ v: raw, .. }) => raw.is_empty()
    _ => false
  }
}

/// `meta(i)` is the metadata of `i`.
pub fn Inline::meta(
  self : Inline
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
    | Text({ meta, .. }) | ExtStrikethrough({ meta, .. }) => meta
  }
}

/// `normalize(i)` has the same content as `i` but is such that for any
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
    | Break(_) | CodeSpan(_) | RawHtml(_) | Text(_) | Inlines({ v: Nil, .. })
    as
    i => i
    Image({ v: raw, meta }) =>
      Image({ v: { ..raw, text: raw.text.normalize() }, meta })
    Link({ v: raw, meta }) =>
      Link({ v: { ..raw, text: raw.text.normalize() }, meta })
    Emphasis({ v: raw, meta }) =>
      Emphasis({ v: { ..raw, inline: raw.inline.normalize() }, meta })
    StrongEmphasis({ v: raw, meta }) =>
      StrongEmphasis({ v: { ..raw, inline: raw.inline.normalize() }, meta })
    ExtStrikethrough({ v: raw, meta }) =>
      ExtStrikethrough({ v: raw._.normalize(), meta })
    Inlines({ v: Cons(i, Nil), .. }) => i
    Inlines({ v: Cons(i, is_), meta }) => {
      let is_ = loop List::of([i.normalize()]), is_ {
        acc, Cons(Inlines({ v: is1, .. }), is_) =>
          continue acc, is1.rev().rev_concat(is_)
        acc, Cons(Text({ v: t1, meta: meta1 }) as i1, is_) =>
          match acc {
            Cons(Text({ v: t, meta }), acc) => {
              let i = Text(
                { v: t + t1, meta: { ..meta, loc: meta.loc.span(meta1.loc) } },
              )
              continue acc.add(i), is_
            }
            _ => continue acc.add(i1.normalize()), is_
          }
        acc, Cons(i, is_) => continue acc.add(i.normalize()), is_
        acc, Nil => break acc.rev()
      }
      match is_ {
        Cons(i, Nil) => i
        is_ => Inlines({ v: is_, meta })
      }
    }
  }
}

/// `to_plain_text(i, break_on_soft~, acc~)` has the plain text of `i`
/// as a sequence of lines represented by a list of strings to be
/// concatenated. If `break_on_soft` is `true` soft line breaks
/// are turned into hard line breaks.
pub fn Inline::to_plain_text(
  self : Inline,
  break_on_soft~ : Bool
) -> List[List[String]] {
  let push = fn(s, acc : List[List[_]]) {
    acc.tail().add(acc.unsafe_head().add(s))
  }
  let newline = fn(acc : List[List[_]]) {
    acc.tail().add(acc.unsafe_head().rev()).add(Nil)
  }
  loop List::of([List::Nil]), List::of([self]) {
    acc, Cons(Autolink(a), is_) => continue push("<\{a.v.link.v}>", acc), is_
    acc, Cons(Break({ v: { ty: Hard, .. }, .. }), is_) =>
      continue newline(acc), is_
    acc, Cons(Break({ v: { ty: Soft, .. }, .. }), is_) =>
      continue if break_on_soft { newline(acc) } else { push(" ", acc) }, is_
    acc, Cons(CodeSpan(cs), is_) => continue push(cs.v.code(), acc), is_
    acc,
    Cons(Emphasis({ v: { inline, .. }, .. }), is_)
    | Cons(StrongEmphasis({ v: { inline, .. }, .. }), is_) =>
      continue acc, Cons(inline, is_)
    acc, Cons(Inlines({ v: is1, .. }), is_) =>
      continue acc, is1.rev().rev_concat(is_)
    acc, Cons(Link(l), is_) => continue acc, Cons(l.v.text, is_)
    acc, Cons(RawHtml(_), is_) => continue acc, is_
    acc, Cons(Text(t), is_) => continue push(t.v, acc), is_
    acc, Cons(ExtStrikethrough(i), is_) => continue acc, Cons(i.v._, is_)
    // acc, Cons(ExtMathSpan(m), is_) => continue push(m.v.tex(), acc), is_
    acc, Cons(i, is_) => continue acc, Cons(i, is_) // TODO: Consider `ext`?
    acc, Nil => acc.tail().add(acc.unsafe_head().rev()).rev()
  }
}

pub fn Inline::id(
  self : Inline,
  buf~ : Buffer = Buffer::new(size_hint=256)
) -> String {
  let text = self.to_plain_text(break_on_soft=false)
  let s = text.map(fn(it) { String::concat(it.to_array()) }).to_array()
    |> String::concat(separator="\n")
  // Collapses non initial white 
  let collapse_blanks = fn(prev) {
    if @char.is_ascii_blank(prev) && buf.is_empty().not() {
      buf.write_char('-')
    }
  }
  loop buf, s, s.length() - 1, '\x00', 0 {
    b, s, max, prev, k => {
      if k > max {
        break buf.to_unchecked_string()
      }
      match s[k] {
        ' ' | '\t' as prev_byte => continue b, s, max, prev_byte, k + 1
        '_' | '-' as c => {
          collapse_blanks(prev)
          buf.write_char(c)
          continue b, s, max, c, k + 1
        }
        c => {
          collapse_blanks(prev)
          let mut u = @char.at(s, k)
          if u == '\u{0000}' {
            u = @char.rep
          }
          let k = k + @char.length_utf16(u)
          // TODO: Use `is_unicode_punctuation()`.
          if @char.is_ascii_punctuation(c) {
            continue b, s, max, '\x00', k
          }
          // TODO: Use `unicode_casefold()`
          buf.write_char(@char.to_ascii_lower(u))
          let prev = c
          continue b, s, max, prev, k
        }
      }
    }
  }
}

pub struct InlineAutolink {
  /// https://spec.commonmark.org/0.30/#email-address
  is_email : Bool
  /// https://spec.commonmark.org/0.30/#absolute-uri
  /// https://spec.commonmark.org/0.30/#email-address
  link : StringNode
} derive(Eq, Show, FromJson, ToJson)

pub fn InlineAutolink::new(link : StringNode) -> InlineAutolink {
  let raw_link = "<{$link.raw}>"
  { is_email: not(@cmark_base.autolink_email(raw_link).is_empty()), link }
}

pub struct InlineBreak {
  layout_before : BlanksNode
  ty : InlineBreakType
  layout_after : BlanksNode
} derive(Eq, Show, FromJson, ToJson)

pub fn InlineBreak::new(
  layout_before~ : BlanksNode = layout_empty,
  layout_after~ : BlanksNode = layout_empty,
  ty : InlineBreakType
) -> InlineBreak {
  { layout_before, ty, layout_after }
}

pub enum InlineBreakType {
  Hard
  Soft
} derive(Eq, Compare, Show, FromJson, ToJson)

/// The type for [code spans](https://spec.commonmark.org/0.30/#code-spans).
pub struct InlineCodeSpan {
  backticks : Count
  code_layout : List[Tight]
} derive(Eq, Show, FromJson, ToJson)

pub fn InlineCodeSpan::new(
  backticks~ : Count,
  code_layout : List[Tight]
) -> InlineCodeSpan {
  { backticks, code_layout }
}

fn InlineCodeSpan::min_backticks(min~ : Count, counts : List[Count]) -> Count {
  loop min, counts.sort() {
    min, Nil => min
    min, Cons(c, cs) => if min != c { break min } else { continue c + 1, cs }
  }
}

/// `from_string(s)` is a code span for `s`. `s` can start with or
/// include backticks; the appropriate minimal backtick count and
/// possible needed leading and trailing space are computed
/// accordingly. If `s` contains newlines, blanks after newlines
/// are treated as layout like during parsing. `meta` is used for
/// the lines of the resulting code layout (see `code_layout`).
/// the resulting code layout (see `code_layout`).
pub fn InlineCodeSpan::from_string(
  meta~ : Meta = Meta::none(),
  s : String
) -> InlineCodeSpan {
  if s.is_empty() {
    return { backticks: 1, code_layout: List::of([Tight::empty(meta~)]) }
  }
  // This finds out the needed backtick count, whether spaces are needed,
  // and treats blanks after newline as layout 
  let max = s.length() - 1
  let need_sp = s[0] == '`' || s[max] == '`'
  let s = if need_sp { " \{s} " } else { s }
  let (bt_counts, code_layout) = loop List::Nil, List::Nil, max, 0, 0, 0 {
    bt_counts, acc, max, btc, start, k => {
      if k > max {
        // assert (btc = 0) because of [need_sp]
        let layout = if acc.is_empty() {
          List::of([{ blanks: "", node: { v: s, meta } }])
        } else {
          BlockLine::flush_tight(meta~, s, start, max, acc)
        }
        break (bt_counts, layout)
      }
      if s[k] == '`' {
        continue bt_counts, acc, max, btc + 1, start, k + 1
      }
      let bt_counts = if btc > 0 { bt_counts.add(btc) } else { bt_counts }
      if not(s[k] == '\n' || s[k] == '\r') {
        continue bt_counts, acc, max, 0, start, k + 1
      }
      let acc = BlockLine::flush_tight(meta~, s, start, k - 1, acc)
      let start = if k + 1 <= max && s[k] == '\r' && s[k + 1] == '\n' {
        k + 2
      } else {
        k + 1
      }
      continue bt_counts, acc, max, 0, start, start
    }
  }
  { code_layout, backticks: InlineCodeSpan::min_backticks(min=1, bt_counts) }
}

/// https://spec.commonmark.org/0.30/#code-spans
pub fn InlineCodeSpan::code(self : InlineCodeSpan) -> String {
  let s = self.code_layout.iter().map(Tight::to_string).to_array()
    |> String::concat(separator=" ")
  if s == "" {
    return ""
  }
  if s[0] == ' ' &&
    s[s.length() - 1] == ' ' &&
    not(s.iter().all(fn(it) { it == ' ' })) {
    return s.substring(start=1, end=s.length() - 1)
  }
  s
}

/// The type for emphasis and strong emphasis.
/// https://spec.commonmark.org/0.30/#emphasis-and-strong-emphasis
pub struct InlineEmphasis {
  delim : Char
  inline : Inline
} derive(Eq, Show, FromJson, ToJson)

pub fn InlineEmphasis::new(
  delim~ : Char = '*',
  inline : Inline
) -> InlineEmphasis {
  { delim, inline }
}

pub struct InlineLink {
  text : Inline
  reference : ReferenceKind
} derive(Eq, Show, FromJson, ToJson)

pub enum ReferenceKind {
  /// https://spec.commonmark.org/0.30/#inline-link
  Inline(Node[LinkDefinition])
  /// https://spec.commonmark.org/0.30/#reference-link
  /// First label is the label of the reference, second label is the label of the referenced definition.
  Ref(ReferenceLayout, Label, Label)
} derive(Eq, Show, FromJson, ToJson)

// The type for reference link layouts.
pub enum ReferenceLayout {
  /// https://spec.commonmark.org/0.30/#collapsed-reference-link
  Collapsed
  /// https://spec.commonmark.org/0.30/#full-reference-link
  Full
  /// https://spec.commonmark.org/0.30/#shortcut-reference-link
  Shortcut
} derive(Eq, Show, FromJson, ToJson)

pub fn InlineLink::new(text : Inline, reference : ReferenceKind) -> InlineLink {
  { text, reference }
}

/// `referenced_label(l)` is the label referenced by the label of `l`.
/// This is the second label of `Ref(_)` or `None` on inline references.
pub fn InlineLink::referenced_label(self : InlineLink) -> Label? {
  match self.reference {
    Inline(_) => None
    Ref(_, _, label) => Some(label)
  }
}

/// `reference_definition(defs, l)` is the definition of `l`'s reference.
/// If `l` is an `Inline` reference this returns its link definition
/// wrapped in a `LinkDef`. If `l` is `Ref` this looks up the
/// `referenced_label` in `defs`.
pub fn InlineLink::reference_definition(
  self : InlineLink,
  defs : LabelDefs
) -> LabelDef? {
  match self.reference {
    Inline(ld) => Some(LinkDef(ld))
    Ref(_, _, def) => defs[def.key]
  }
}

/// `is_unsafe(l)` is `true` if `l` is deemed unsafe.
/// This is the case if `l` starts with a caseless match of
/// `javascript:`, `vbscript:`, `file:` or `data:` except if
/// `data:image/{gif,png,jpeg,webp}`.
/// These rules were taken from the C reference implementation of CommonMark
/// and are likely incomplete. If you are trying to prevent XSS you should
/// post-process rendering outputs with a dedicated HTML sanitizer.
pub fn InlineLink::is_unsafe(l : String) -> Bool {
  let allowed_data_url = fn(l : String) {
    // Extract mediatype from data:[<mediatype>][;base64],<data>
    let j = l.index_of(",", from=4)
    guard j != -1 else { return false }
    let mut k = l.index_of(";", from=4)
    if k == -1 {
      k = j
    }
    let allowed = ["image/gif", "image/png", "image/jpeg", "image/webp"]
    allowed.contains(l.substring(start=5, end=@math.minimum(j, k)))
  }
  // TODO: Use `casefold()`.
  let lower = l.to_lower()
  lower.starts_with("javascript:") ||
  lower.starts_with("vbscript:") ||
  lower.starts_with("file:") ||
  (lower.starts_with("data:") && not(allowed_data_url(l)))
}

/// The type for [inline raw HTML](https://spec.commonmark.org/0.30/#raw-html) (can span multiple lines).
pub type InlineRawHtml List[Tight] derive(Eq, Show, FromJson, ToJson)

/// The type for [textual content](https://spec.commonmark.org/0.30/#textual-content).
///
/// Normally these strings should not contain newlines. This can
/// however happen if the source had newlines as
/// [character references](https://spec.commonmark.org/0.30/#entity-and-numeric-character-references).
pub typealias InlineText = String

// Extensions

pub type InlineStrikethrough Inline derive(Eq, Show, FromJson, ToJson)

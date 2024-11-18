/// A markdown block.
pub enum Block {
  BlankLine(Node[BlockBlankLine])
  BlockQuote(Node[BlockQuote])
  Blocks(Node[List[Block]])
  CodeBlock(Node[CodeBlock])
  Heading(Node[BlockHeading])
  HtmlBlock(Node[HtmlBlock])
  LinkRefDefinition(Node[LinkDefinition])
  List(Node[BlockList])
  Paragraph(Node[BlockParagraph])
  ThematicBreak(Node[BlockThematicBreak])
  // ExtMathBlock
  ExtTable(Node[Table])
  ExtFootnoteDefinition(Node[Footnote])
} derive(Show, FromJson, ToJson)

pub fn Block::empty() -> Block {
  Blocks({ v: Nil, meta: Meta::none() })
}

pub fn Block::meta(self : Block) -> Meta {
  match self {
    BlankLine(bl) => bl.meta
    BlockQuote(bl) => bl.meta
    Blocks(bl) => bl.meta
    CodeBlock(bl) => bl.meta
    Heading(bl) => bl.meta
    HtmlBlock(bl) => bl.meta
    LinkRefDefinition(bl) => bl.meta
    List(bl) => bl.meta
    Paragraph(bl) => bl.meta
    ThematicBreak(bl) => bl.meta
    ExtFootnoteDefinition(bl) => bl.meta
    ExtTable(bl) => bl.meta
  }
}

/// Normalize a block.
///
/// `b.normalize()` has the same content as `b` but is such that for any
/// occurrence of `Blocks` in `b` the list of blocks `bs`:
/// - `bs` is not a singleton list.
/// - Has no `Blocks` case. The meta is dropped and the nested
///   blocks are spliced in `bs` where the case occurs.
pub fn Block::normalize(self : Block) -> Block {
  match self {
    BlockQuote(bl) => BlockQuote(bl.map(BlockQuote::normalize_block))
    List(bl) => List(bl.map(BlockList::normalize_items))
    Blocks({ v: Cons(b, bs), meta }) => {
      let bs = loop List::Nil.add(b.normalize()), bs {
        acc, Cons(Blocks({ v: bs1, .. }), bs) =>
          continue acc, bs1.rev().rev_concat(bs)
        acc, Cons(b, bs) => continue acc.add(b.normalize()), bs
        acc, Nil => acc.rev()
      }
      match bs {
        Cons(b, Nil) => b
        _ => Blocks({ v: bs, meta })
      }
    }
    ExtFootnoteDefinition(bl) =>
      ExtFootnoteDefinition(bl.map(Footnote::normalize_block))
    _ => self
  }
}

/// Collects the given `Block`'s link definitions (e.g. `LinkRefDefinition`
/// and `ExtFootnoteDefinition`) and adds them to `init` (defaults to an empty map).
pub fn Block::defs(
  self : Block,
  init~ : LabelDefs = LabelDefs::empty()
) -> LabelDefs {
  match self {
    BlockQuote(bl) => bl.v.block.defs(init~)
    Blocks(bl) => bl.v.fold(init~, fn(init, b) { b.defs(init~) })
    List(bl) => bl.v.items.fold(init~, fn(init, it) { it.v.block.defs(init~) })
    LinkRefDefinition(bl) =>
      bl.v.defined_label.map_or(
        init,
        fn(it) { init.insert(it.key, LinkDef(bl)) },
      )
    ExtFootnoteDefinition(footnote) =>
      footnote.v.defined_label.map_or(
        init,
        fn(it) { init.insert(it.key, FootnoteDef(footnote)) },
      )
    _ => init
  }
}

/// The type for [blank lines](https://spec.commonmark.org/0.30/#blank-lines).
/// These can be ignored during rendering, they are kept for layout.
pub typealias BlockBlankLine = Blanks

/// The type for [block quotes](https://spec.commonmark.org/0.30/#block-quotes).
pub struct BlockQuote {
  /// The indentation to the block quote marker found on the first line.
  indent : Indent
  /// The quoted block.
  block : Block
} derive(Show, FromJson, ToJson)

pub fn BlockQuote::new(indent~ : Int = 0, block : Block) -> BlockQuote {
  { indent, block }
}

pub fn BlockQuote::map_block(
  self : BlockQuote,
  f : (Block) -> Block
) -> BlockQuote {
  { ..self, block: f(self.block) }
}

pub fn BlockQuote::normalize_block(self : BlockQuote) -> BlockQuote {
  self.map_block(Block::normalize)
}

/// The type for [indented](https://spec.commonmark.org/0.30/#indented-code-block) and
/// [fenced](:https://spec.commonmark.org/0.30/#fenced-code-blocks) code blocks.
pub struct CodeBlock {
  layout : CodeBlockLayout
  info_string : StringNode?
  code : List[StringNode]
} derive(Show, FromJson, ToJson)

pub enum CodeBlockLayout {
  Indented
  Fenced(CodeBlockFencedLayout)
} derive(Show, FromJson, ToJson)

pub struct CodeBlockFencedLayout {
  indent : Indent
  opening_fence : StringNode
  closing_fence : StringNode?
} derive(Show, FromJson, ToJson)

pub fn CodeBlockFencedLayout::default() -> CodeBlockFencedLayout {
  { indent: 0, opening_fence: layout_empty, closing_fence: Some(layout_empty) }
}

pub fn CodeBlock::new(
  layout~ : CodeBlockLayout = Fenced(CodeBlockFencedLayout::default()),
  info_string~ : StringNode? = None,
  code : List[StringNode]
) -> CodeBlock {
  let layout = match (info_string, layout) {
    (Some(_), Indented) =>
      CodeBlockLayout::Fenced(CodeBlockFencedLayout::default())
    (_, layout) => layout
  }
  { layout, info_string, code }
}

// [make_fence cb] is a fence character and count suitable for [cb].
pub fn CodeBlock::make_fence(self : CodeBlock) -> (Char, Count) {
  let ch = match self.info_string {
    Some(info) => if info.v.contains_char('`') { '~' } else { '`' }
    _ => '`'
  }
  let counts = loop ch, List::Nil, self.code {
    _, counts, Nil => counts
    ch, counts, Cons({ v: c, .. }, cs) => {
      let mut k = 0
      while k < c.length() && c[k] == ch {
        k += 1
      }
      let counts = if k != 0 { counts.add(k) } else { counts }
      continue ch, counts, cs
    }
  }
  (ch, InlineCodeSpan::min_backticks(min=3, counts))
}

// [language_of_info_string s] extracts a (non-empty) language, the first word of [s] and a trimmed remainder.
// Assumes [s] is {!String.trim}ed which is what {!info_string} gives you.
pub fn CodeBlock::language_of_info_string(s : String) -> (String, String)? {
  if s.is_empty() {
    return None
  }
  let max = s.length() - 1
  let white = loop s, max, 0 {
    s, max, i => {
      if i > max || @char.is_ascii_whitespace(s[i]) {
        break i
      }
      continue s, max, i + 1
    }
  }
  let rem_first = @cmark_base.first_non_blank(s, last=max, start=white)
  let lang = s.substring(start=0, end=white)
  if lang.is_empty() {
    return None
  }
  Some((lang, s.substring(start=rem_first, end=max + 1)))
}

fn CodeBlock::is_math_block(s : String?) -> Bool {
  guard let Some(s) = s else { _ => return false }
  language_of_info_string(s).map(fn(i) { i.0 }) == Some("math")
}

/// The type for [ATX](https://spec.commonmark.org/0.30/#atx-headings) 
/// and [Setext](https://spec.commonmark.org/0.30/#setext-headings) headings.
pub struct BlockHeading {
  layout : BlockHeadingLayout
  level : Int
  inline : Inline
  id : BlockHeadingId?
} derive(Show, FromJson, ToJson)

pub enum BlockHeadingLayout {
  Atx(BlockHeadingAtxLayout)
  Setext(BlockHeadingSetextLayout)
} derive(Show, FromJson, ToJson)

pub struct BlockHeadingAtxLayout {
  indent : Indent
  after_opening : Blanks
  closing : String
} derive(Show, FromJson, ToJson)

pub fn BlockHeadingAtxLayout::default() -> BlockHeadingAtxLayout {
  { indent: 0, after_opening: "", closing: "" }
}

pub struct BlockHeadingSetextLayout {
  leading_indent : Indent
  trailing_blanks : Blanks
  underline_indent : Indent
  underline_count : Node[Count]
  underline_blanks : Blanks
} derive(Show, FromJson, ToJson)

pub enum BlockHeadingId {
  Auto(String)
  Id(String)
} derive(Show, FromJson, ToJson)

pub fn BlockHeading::new(
  id~ : BlockHeadingId? = None,
  layout~ : BlockHeadingLayout = Atx(BlockHeadingAtxLayout::default()),
  level~ : Int,
  inline : Inline
) -> BlockHeading {
  { layout, level, inline, id }
}

/// The type for [HTML blocks](https://spec.commonmark.org/0.30/#html-blocks).
pub type HtmlBlock List[StringNode] derive(Show, FromJson, ToJson)

pub struct ListItem {
  before_marker : Indent
  marker : StringNode
  after_marker : Indent
  block : Block
  ext_task_marker : Node[Char]?
} derive(Show, FromJson, ToJson)

pub typealias ListItemBlock = ListItem

pub fn ListItem::new(
  before_marker~ : Indent = 0,
  marker~ : StringNode = layout_empty,
  after_marker~ : Indent = 1,
  ext_task_marker~ : Node[Char]?,
  block : Block
) -> ListItem {
  { before_marker, marker, after_marker, block, ext_task_marker }
}

pub fn ListItem::map_block(self : ListItem, f : (Block) -> Block) -> ListItem {
  { ..self, block: f(self.block) }
}

pub fn ListItem::normalize_block(self : ListItem) -> ListItem {
  self.map_block(Block::normalize)
}

pub enum ListTaskStatus {
  Cancelled
  Checked
  Unchecked
  Other(Char)
}

pub fn ListTaskStatus::from_marker(marker : Char) -> ListTaskStatus {
  match marker {
    ' ' => Unchecked
    'x' | 'X' | '✓' | '✔' | '𐄂' | '🗸' => Checked
    '~' => Cancelled
    _ => Other(marker)
  }
}

/// The type for [lists](https://spec.commonmark.org/0.30/#lists).
pub struct BlockList {
  ty : ListType
  tight : Bool
  items : List[Node[ListItem]]
} derive(Show, FromJson, ToJson)

pub fn BlockList::map_items(
  self : BlockList,
  f : (ListItem) -> ListItem
) -> BlockList {
  { ..self, items: self.items.map(fn(it) { it.map(f) }) }
}

pub fn BlockList::normalize_items(self : BlockList) -> BlockList {
  self.map_items(ListItem::normalize_block)
}

/// The type for [paragraphs](https://spec.commonmark.org/0.30/#paragraphs).
pub struct BlockParagraph {
  leading_indent : Indent
  inline : Inline
  trailing_blanks : Blanks
} derive(Show, FromJson, ToJson)

pub fn BlockParagraph::new(
  leading_indent~ : Indent = 0,
  trailing_blanks~ : Blanks = "",
  inline : Inline
) -> BlockParagraph {
  { leading_indent, inline, trailing_blanks }
}

/// The type for [thematic breaks](https://spec.commonmark.org/0.30/#thematic-break).
pub struct BlockThematicBreak {
  indent : Indent
  layout : String
} derive(Show, FromJson, ToJson)

pub fn BlockThematicBreak::new(
  indent~ : Indent = 0,
  layout~ : String = "---"
) -> BlockThematicBreak {
  { indent, layout }
}

// Extensions

pub struct Footnote {
  indent : Indent
  label : Label
  defined_label : Label?
  block : Block
} derive(Show, FromJson, ToJson)

pub fn Footnote::new(
  indent~ : Indent = 0,
  defined_label? : Label?,
  label : Label,
  block : Block
) -> Footnote {
  let defined_label = defined_label.or(Some(label))
  { indent, label, defined_label, block }
}

pub fn Footnote::map_block(self : Footnote, f : (Block) -> Block) -> Footnote {
  { ..self, block: f(self.block) }
}

pub fn Footnote::normalize_block(self : Footnote) -> Footnote {
  self.map_block(Block::normalize)
}

fn Label::stub(label : Label, defined_label : Label?) -> LabelDef {
  FootnoteDef(
    Node::new({ indent: 0, label, defined_label, block: Block::empty() }),
  )
}

pub struct Table {
  indent : Indent
  col_count : Count
  rows : List[(Node[TableRow], Blanks)]
} derive(Show, FromJson, ToJson)

pub enum TableAlign {
  Left
  Center
  Right
} derive(Show, FromJson, ToJson)

pub enum TableRow {
  Header(List[(Inline, TableCellLayout)])
  Sep(List[Node[TableSep]])
  Data(List[(Inline, TableCellLayout)])
} derive(Show, FromJson, ToJson)

pub typealias TableSep = (TableAlign?, Count)

pub typealias TableCellLayout = (Blanks, Blanks)

pub fn Table::new(
  indent~ : Indent = 0,
  rows : List[(Node[TableRow], Blanks)]
) -> Table {
  {
    indent,
    rows,
    col_count: loop 0, rows {
      c, Cons(({ v: Header(cols) | Data(cols), .. }, _), rs) =>
        continue @math.maximum(cols.length(), c), rs
      c, Cons(({ v: Sep(cols), .. }, _), rs) =>
        continue @math.maximum(cols.length(), c), rs
      c, Nil => c
    },
  }
}

pub fn Table::parse_sep_row(
  cs : List[(Inline, TableCellLayout)]
) -> List[Node[TableSep]]? {
  loop List::Nil, cs {
    acc, Nil => Some(acc.rev())
    acc, Cons((Text({ v, meta }), ("", "")), cs) => {
      guard v.is_empty().not() else { None }
      let max = v.length() - 1
      let first_colon = v[0] == ':'
      let last_colon = v[max] == ':'
      let first = if first_colon { 1 } else { 0 }
      let last = if last_colon { max - 1 } else { max }
      for i in first..=last {
        guard v[i] == '-' else { break None }

      } else {
        let count = last - first + 1
        let sep = match (first_colon, last_colon) {
          (false, false) => None
          (true, true) => Some(Center)
          (true, false) => Some(Left)
          (false, true) => Some(Right)
        }
        continue acc.add({ v: (sep, count), meta }), cs
      }
    }
    _, _ => None
  }
}

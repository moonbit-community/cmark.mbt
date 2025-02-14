///| A markdown block.
pub(all) enum Block {
  BlankLine(Node[BlockBlankLine])
  BlockQuote(Node[BlockQuote])
  Blocks(Node[Seq[Block]])
  CodeBlock(Node[CodeBlock])
  Heading(Node[BlockHeading])
  HtmlBlock(Node[HtmlBlock])
  LinkRefDefinition(Node[LinkDefinition])
  List(Node[BlockList])
  Paragraph(Node[BlockParagraph])
  ThematicBreak(Node[BlockThematicBreak])
  ExtMathBlock(Node[CodeBlock])
  ExtTable(Node[Table])
  ExtFootnoteDefinition(Node[Footnote])
} derive(Show, ToJson)

///|
pub fn Block::empty() -> Block {
  Blocks({ v: [], meta: Meta::none() })
}

///|
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
    ExtMathBlock(bl) => bl.meta
  }
}

///| Normalize a block.
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
    Blocks({ v: Seq([.., _] as bs), meta }) => {
      let mut bs = bs
      let acc = [bs.pop().unwrap().normalize()]
      for {
        match bs.pop() {
          Some(Blocks({ v: bs1, .. })) => bs += bs1._
          Some(b) => acc.push(b.normalize())
          None => break
        }
      }
      match acc {
        [b] => b
        _ => Blocks({ v: bs, meta })
      }
    }
    ExtFootnoteDefinition(bl) =>
      ExtFootnoteDefinition(bl.map(Footnote::normalize_block))
    _ => self
  }
}

///| Collects the given `Block`'s link definitions (e.g. `LinkRefDefinition`
/// and `ExtFootnoteDefinition`) and adds them to `init` (defaults to an empty map).
pub fn Block::defs(
  self : Block,
  init~ : LabelDefs = LabelDefs::new()
) -> LabelDefs {
  match self {
    BlockQuote(bl) => bl.v.block.defs(init~)
    Blocks(bl) => bl.v.fold(init~, fn(init, b) { b.defs(init~) })
    List(bl) => bl.v.items.fold(init~, fn(init, it) { it.v.block.defs(init~) })
    LinkRefDefinition(bl) =>
      bl.v.defined_label.map_or(init, fn(it) { init..set(it.key, LinkDef(bl)) })
    ExtFootnoteDefinition(footnote) =>
      footnote.v.defined_label.map_or(init, fn(it) {
        init..set(it.key, FootnoteDef(footnote))
      })
    _ => init
  }
}

///| The type for [blank lines](https://spec.commonmark.org/0.30/#blank-lines).
/// These can be ignored during rendering, they are kept for layout.
pub(all) typealias BlockBlankLine = Blanks

///| The type for [block quotes](https://spec.commonmark.org/0.30/#block-quotes).
pub(all) struct BlockQuote {
  /// The indentation to the block quote marker found on the first line.
  indent : Indent
  /// The quoted block.
  block : Block
} derive(Show, ToJson)

///|
pub fn BlockQuote::new(indent~ : Int = 0, block : Block) -> BlockQuote {
  { indent, block }
}

///|
pub fn BlockQuote::map_block(
  self : BlockQuote,
  f : (Block) -> Block
) -> BlockQuote {
  { ..self, block: f(self.block) }
}

///|
pub fn BlockQuote::normalize_block(self : BlockQuote) -> BlockQuote {
  self.map_block(Block::normalize)
}

///| The type for [indented](https://spec.commonmark.org/0.30/#indented-code-block) and
/// [fenced](:https://spec.commonmark.org/0.30/#fenced-code-blocks) code blocks.
pub(all) struct CodeBlock {
  layout : CodeBlockLayout
  info_string : StringNode?
  code : Seq[StringNode]
} derive(Show, ToJson)

///|
pub(all) enum CodeBlockLayout {
  Indented
  Fenced(CodeBlockFencedLayout)
} derive(Show, ToJson)

///|
pub(all) struct CodeBlockFencedLayout {
  indent : Indent
  opening_fence : StringNode
  closing_fence : StringNode?
} derive(Show, ToJson)

///|
pub fn CodeBlockFencedLayout::default() -> CodeBlockFencedLayout {
  { indent: 0, opening_fence: layout_empty, closing_fence: Some(layout_empty) }
}

///|
pub fn CodeBlock::new(
  layout~ : CodeBlockLayout = Fenced(CodeBlockFencedLayout::default()),
  info_string~ : StringNode? = None,
  code : Seq[StringNode]
) -> CodeBlock {
  let layout = match (info_string, layout) {
    (Some(_), Indented) =>
      CodeBlockLayout::Fenced(CodeBlockFencedLayout::default())
    (_, layout) => layout
  }
  { layout, info_string, code }
}

///| [make_fence cb] is a fence character and count suitable for [cb].
pub fn CodeBlock::make_fence(self : CodeBlock) -> (Char, Count) {
  let ch = match self.info_string {
    Some(info) => if info.v.contains_char('`') { '~' } else { '`' }
    _ => '`'
  }
  let counts = @sorted_set.new()
  for n in self.code {
    let c = n.v
    let k = for k = 0; k < c.length() && c[k] == ch; k = k + 1 {

    } else {
      k
    }
    if k != 0 {
      counts.add(k)
    }
  }
  (ch, InlineCodeSpan::min_backticks(min=3, counts))
}

///| [language_of_info_string s] extracts a (non-empty) language, the first word of [s] and a trimmed remainder.
/// Assumes [s] is {!String.trim}ed which is what {!info_string} gives you.
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

///|
fn CodeBlock::is_math_block(s : String?) -> Bool {
  guard s is Some(s) else { return false }
  CodeBlock::language_of_info_string(s).map(fn(i) { i.0 }) == Some("math")
}

///| The type for [ATX](https://spec.commonmark.org/0.30/#atx-headings) 
/// and [Setext](https://spec.commonmark.org/0.30/#setext-headings) headings.
pub(all) struct BlockHeading {
  layout : BlockHeadingLayout
  level : Int
  inline : Inline
  id : BlockHeadingId?
} derive(Show, ToJson)

///|
pub(all) enum BlockHeadingLayout {
  Atx(BlockHeadingAtxLayout)
  Setext(BlockHeadingSetextLayout)
} derive(Show, ToJson)

///|
pub(all) struct BlockHeadingAtxLayout {
  indent : Indent
  after_opening : Blanks
  closing : String
} derive(Show, FromJson, ToJson)

///|
pub fn BlockHeadingAtxLayout::default() -> BlockHeadingAtxLayout {
  { indent: 0, after_opening: "", closing: "" }
}

///|
pub(all) struct BlockHeadingSetextLayout {
  leading_indent : Indent
  trailing_blanks : Blanks
  underline_indent : Indent
  underline_count : Node[Count]
  underline_blanks : Blanks
} derive(Show, ToJson)

///|
pub(all) enum BlockHeadingId {
  Auto(String)
  Id(String)
} derive(Show, FromJson, ToJson)

///|
pub fn BlockHeading::new(
  id~ : BlockHeadingId? = None,
  layout~ : BlockHeadingLayout = Atx(BlockHeadingAtxLayout::default()),
  level~ : Int,
  inline : Inline
) -> BlockHeading {
  { layout, level, inline, id }
}

///| The type for [HTML blocks](https://spec.commonmark.org/0.30/#html-blocks).
pub(all) type HtmlBlock Seq[StringNode] derive(Show, ToJson)

///|
pub(all) struct ListItem {
  before_marker : Indent
  marker : StringNode
  after_marker : Indent
  block : Block
  ext_task_marker : Node[Char]?
} derive(Show, ToJson)

///|
pub(all) typealias ListItemBlock = ListItem

///|
pub fn ListItem::new(
  before_marker~ : Indent = 0,
  marker~ : StringNode = layout_empty,
  after_marker~ : Indent = 1,
  ext_task_marker~ : Node[Char]?,
  block : Block
) -> ListItem {
  { before_marker, marker, after_marker, block, ext_task_marker }
}

///|
pub fn ListItem::map_block(self : ListItem, f : (Block) -> Block) -> ListItem {
  { ..self, block: f(self.block) }
}

///|
pub fn ListItem::normalize_block(self : ListItem) -> ListItem {
  self.map_block(Block::normalize)
}

///|
pub(all) enum ListTaskStatus {
  Cancelled
  Checked
  Unchecked
  Other(Char)
}

///|
pub fn ListTaskStatus::from_marker(marker : Char) -> ListTaskStatus {
  match marker {
    ' ' => Unchecked
    'x' | 'X' | '✓' | '✔' | '𐄂' | '🗸' => Checked
    '~' => Cancelled
    _ => Other(marker)
  }
}

///| The type for [lists](https://spec.commonmark.org/0.30/#lists).
pub(all) struct BlockList {
  ty : ListType
  tight : Bool
  items : Seq[Node[ListItem]]
} derive(Show, ToJson)

///|
pub fn BlockList::map_items(
  self : BlockList,
  f : (ListItem) -> ListItem
) -> BlockList {
  { ..self, items: self.items.map(fn(it) { it.map(f) }) }
}

///|
pub fn BlockList::normalize_items(self : BlockList) -> BlockList {
  self.map_items(ListItem::normalize_block)
}

///| The type for [paragraphs](https://spec.commonmark.org/0.30/#paragraphs).
pub(all) struct BlockParagraph {
  leading_indent : Indent
  inline : Inline
  trailing_blanks : Blanks
} derive(Show, ToJson)

///|
pub fn BlockParagraph::new(
  leading_indent~ : Indent = 0,
  trailing_blanks~ : Blanks = "",
  inline : Inline
) -> BlockParagraph {
  { leading_indent, inline, trailing_blanks }
}

///| The type for [thematic breaks](https://spec.commonmark.org/0.30/#thematic-break).
pub(all) struct BlockThematicBreak {
  indent : Indent
  layout : String
} derive(Show, FromJson, ToJson)

///|
pub fn BlockThematicBreak::new(
  indent~ : Indent = 0,
  layout~ : String = "---"
) -> BlockThematicBreak {
  { indent, layout }
}

// Extensions

///|
pub(all) struct Footnote {
  indent : Indent
  label : Label
  defined_label : Label?
  block : Block
} derive(Show, ToJson)

///|
pub fn Footnote::new(
  indent~ : Indent = 0,
  defined_label? : Label?,
  label : Label,
  block : Block
) -> Footnote {
  let defined_label = defined_label.or(Some(label))
  { indent, label, defined_label, block }
}

///|
pub fn Footnote::map_block(self : Footnote, f : (Block) -> Block) -> Footnote {
  { ..self, block: f(self.block) }
}

///|
pub fn Footnote::normalize_block(self : Footnote) -> Footnote {
  self.map_block(Block::normalize)
}

///|
fn Label::stub(label : Label, defined_label : Label?) -> LabelDef {
  FootnoteDef(
    Node::new({ indent: 0, label, defined_label, block: Block::empty() }),
  )
}

///|
pub(all) struct Table {
  indent : Indent
  col_count : Count
  rows : Seq[(Node[TableRow], Blanks)]
} derive(Show, ToJson)

///|
pub(all) enum TableAlign {
  Left
  Center
  Right
} derive(Show, FromJson, ToJson)

///|
pub(all) enum TableRow {
  Header(Seq[(Inline, TableCellLayout)])
  Sep(Seq[Node[TableSep]])
  Data(Seq[(Inline, TableCellLayout)])
} derive(Show, ToJson)

///|
pub(all) typealias TableSep = (TableAlign?, Count)

///|
pub(all) typealias TableCellLayout = (Blanks, Blanks)

///|
pub fn Table::new(
  indent~ : Indent = 0,
  rows : Seq[(Node[TableRow], Blanks)]
) -> Table {
  let mut col_count = 0
  for row in rows {
    match row.0.v {
      Header(cols) | Data(cols) =>
        col_count = @math.maximum(col_count, cols.length())
      Sep(cols) => col_count = @math.maximum(col_count, cols.length())
    }
  }
  { indent, rows, col_count }
}

///|
fn Table::parse_sep_row(
  cs : ArrayView[(Inline, TableCellLayout)]
) -> Array[Node[TableSep]]? {
  loop [], cs {
    acc, [] => Some(acc)
    acc, [(Text({ v, meta }), ("", "")), .. cs] => {
      guard not(v.is_empty()) else { None }
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
        continue acc..push({ v: (sep, count), meta }), cs
      }
    }
    _, _ => None
  }
}

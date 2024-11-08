/// Abstract syntax tree mappers.
///
/// Mappers help with pushing abstract syntax tree transformations in every
/// node with a minimal amount of code by defaulting the cases you
/// don't handle. The default map maps leaves to themselves and
/// otherwise propagates the map to all children.
///
/// This map has the form of `List::filter_map`, however it is akin
/// to `List.concat_map` as it allows:
/// - Node deletion by mapping to `None`
/// - Node transformation by mapping to `Some _`
/// - Node expansion by mapping to `Some (Inlines _)` or `Some (Blocks _)`
pub struct Mapper {
  inline_ext_default : MapFn[Inline]
  block_ext_default : MapFn[Block]
  inline : MapperFn[Inline]
  block : MapperFn[Block]
}

pub typealias MapFn[A] = (Mapper, A) -> FilterMap[A]!MapperError

pub typealias MapperFn[A] = (Mapper, A) -> MapperResult[A]

/// The type for mapper results.
/// `Default` means doing the default map.
pub enum MapperResult[A] {
  Default
  Map(FilterMap[A])
} derive(Eq, Show, ToJson)

pub typealias FilterMap[A] = A?

pub fn Mapper::delete[A]() -> MapperResult[A] {
  Map(None)
}

pub fn Mapper::ret[A](a : A) -> MapperResult[A] {
  Map(Some(a))
}

pub fn Mapper::none[A](self : Mapper, _a : A) -> MapperResult[A] {
  let _ = self
  Default
}

pub fn Mapper::inline_ext_none[A](
  self : Mapper,
  _a : A
) -> FilterMap[A]!MapperError {
  let _ = self
  raise MapperError("unknown inline extension")
}

pub fn Mapper::block_ext_none[A](
  self : Mapper,
  _a : A
) -> FilterMap[A]!MapperError {
  let _ = self
  raise MapperError("unknown block extension")
}

pub fn Mapper::new(
  ~inline_ext_default : MapFn[Inline] = Mapper::inline_ext_none,
  ~block_ext_default : MapFn[Block] = Mapper::block_ext_none,
  ~inline : MapperFn[Inline] = Mapper::none,
  ~block : MapperFn[Block] = Mapper::none
) -> Mapper {
  { inline_ext_default, block_ext_default, inline, block }
}

pub fn Mapper::map_inline(self : Mapper, i : Inline) -> FilterMap[Inline] {
  guard let Default = (self.inline)(self, i) else { Map(i) => i }
  match i {
    // | ExtMathSpan(_)
    Autolink(_) | Break(_) | CodeSpan(_) | RawHtml(_) | Text(_) => Some(i)
    Image({ v, meta }) => {
      let text = self.map_inline(v.text).or(Inline::empty())
      Some(Image({ v: { ..v, text, }, meta }))
    }
    Link({ v, meta }) => {
      guard let Some(text) = self.map_inline(v.text) else { _ => None }
      Some(Link({ v: { ..v, text, }, meta }))
    }
    Emphasis({ v, meta }) => {
      guard let Some(inline) = self.map_inline(v.inline) else { _ => None }
      Some(Emphasis({ v: { ..v, inline, }, meta }))
    }
    StrongEmphasis({ v, meta }) => {
      guard let Some(inline) = self.map_inline(v.inline) else { _ => None }
      Some(StrongEmphasis({ v: { ..v, inline, }, meta }))
    }
    Inlines({ v, meta }) => {
      // TODO: Use .filter_map
      guard let Cons(_, _) as v = v.filter_map(fn(x) { self.map_inline(x) }) else {
        _ => None
      }
      Some(Inlines({ v, meta }))
    }
    ExtStrikethrough({ v, meta }) => {
      guard let Some(v) = self.map_inline(v._) else { _ => None }
      Some(ExtStrikethrough({ v, meta }))
    }
    // ext => (self.inline_ext_default)(self, ext)
  }
}

pub fn Mapper::map_block(self : Mapper, b : Block) -> FilterMap[Block] {
  guard let Default = (self.block)(self, b) else { Map(b) => b }
  match b {
    // | ExtMathBlock(_)
    BlankLine(_)
    | CodeBlock(_) | HtmlBlock(_) | LinkRefDefinition(_) | ThematicBreak(_)
    as
    b => Some(b)
    Heading({ v, meta }) => {
      let inline = self
        .map_inline(v.inline)
        .or(Inlines({ v: Nil, meta: Meta::none() }))
      Some(Heading({ v: { ..v, inline, }, meta }))
    }
    BlockQuote({ v, meta }) => {
      let block = self
        .map_block(v.block)
        .or(Blocks({ v: Nil, meta: Meta::none() }))
      Some(BlockQuote({ v: { ..v, block, }, meta }))
    }
    Blocks({ v, meta }) =>
      match v.filter_map(fn(x) { self.map_block(x) }) {
        Nil => None
        v => Some(Blocks({ v, meta }))
      }
    List({ v, meta }) => {
      fn map_list_item(i : Node[ListItem]) {
        let { v, meta } = i
        guard let Some(block) = self.map_block(i.v.block) else { _ => None }
        Some({ v: { ..v, block, }, meta })
      }

      match v.items.filter_map(map_list_item) {
        Nil => None
        items => Some(List({ v: { ..v, items, }, meta }))
      }
    }
    Paragraph({ v, meta }) => {
      guard let Some(inline) = self.map_inline(v.inline) else { _ => None }
      Some(Paragraph({ v: { ..v, inline, }, meta }))
    }
    ExtFootnoteDefinition({ v, meta }) => {
      let block = self
        .map_block(v.block)
        .or_else(fn() { Blocks(Node::new(Nil)) }) // Can be empty
      Some(ExtFootnoteDefinition({ v: { ..v, block, }, meta }))
    }
    ExtTable({ v, meta }) => {
      fn map_col(i, layout) {
        self.map_inline(i).map(fn(i) { (i, layout) })
      }

      fn map_row(row) {
        let ({ v, meta }, blanks) = row
        match v {
          Header(is) => {
            let is = is.filter_map(fn(i) { map_col(i.0, i.1) })
            ({ v: Header(is), meta }, blanks)
          }
          Sep(_) => row
          Data(is) => {
            let is = is.filter_map(fn(i) { map_col(i.0, i.1) })
            ({ v: Data(is), meta }, blanks)
          }
        }
      }

      Some(ExtTable({ v: { ..v, rows: v.rows.map(map_row) }, meta }))
    }
    // ext => (self.block_ext_default)(self, ext)
  }
}

pub fn Mapper::map_doc(self : Mapper, d : Doc) -> Doc {
  let map_block = fn(b) { self.map_block(b).or(Block::empty()) }
  let map_def = fn(b : LabelDef) {
    guard let FootnoteDef({ v, meta }) = b else { b => b }
    let block = map_block(v.block)
    FootnoteDef({ v: { ..v, block, }, meta })
  }
  let block = map_block(d.block)
  let defs = d.defs.map(map_def)
  { ..d, block, defs }
}

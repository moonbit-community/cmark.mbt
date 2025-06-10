///| Abstract syntax tree mappers.
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
pub(all) struct Mapper {
  inline_ext_default : MapFn[Inline]
  block_ext_default : MapFn[Block]
  inline : MapperFn[Inline]
  block : MapperFn[Block]
}

///|
pub(all) type MapFn[A] (Mapper, A) -> A?!MapperError

///|
pub(all) type MapperFn[A] (Mapper, A) -> MapperResult[A]

///| The type for mapper results.
/// `Default` means doing the default map.
pub(all) enum MapperResult[A] {
  Default
  Map(A?)
} derive(Eq, Show, ToJson)

///|
pub impl[A] Default for MapperResult[A] with default() {
  Default
}

///|
pub fn[A] Mapper::delete() -> MapperResult[A] {
  Map(None)
}

///|
pub fn[A] Mapper::ret(a : A) -> MapperResult[A] {
  Map(Some(a))
}

///|
pub fn[A] Mapper::none(self : Mapper, _a : A) -> MapperResult[A] {
  let _ = self
  Default
}

///|
pub fn[A] Mapper::inline_ext_none(self : Mapper, _a : A) -> A?!MapperError {
  let _ = self
  raise MapperError("unknown inline extension")
}

///|
pub fn[A] Mapper::block_ext_none(self : Mapper, _a : A) -> A?!MapperError {
  let _ = self
  raise MapperError("unknown block extension")
}

///|
pub fn Mapper::new(
  inline_ext_default~ : MapFn[Inline] = Mapper::inline_ext_none,
  block_ext_default~ : MapFn[Block] = Mapper::block_ext_none,
  inline~ : MapperFn[Inline] = Mapper::none,
  block~ : MapperFn[Block] = Mapper::none
) -> Mapper {
  { inline_ext_default, block_ext_default, inline, block }
}

///|
pub fn Mapper::map_inline(self : Mapper, i : Inline) -> Inline? {
  if (self.inline)(self, i) is Map(i) {
    return i
  }
  match i {
    Autolink(_)
    | Break(_)
    | CodeSpan(_)
    | RawHtml(_)
    | Text(_)
    | ExtMathSpan(_) => Some(i)
    Image({ v, meta }) => {
      let text = self.map_inline(v.text).or(Inline::empty())
      Some(Image({ v: { ..v, text, }, meta }))
    }
    Link({ v, meta }) => {
      guard self.map_inline(v.text) is Some(text) else { None }
      Some(Link({ v: { ..v, text, }, meta }))
    }
    Emphasis({ v, meta }) => {
      guard self.map_inline(v.inline) is Some(inline) else { None }
      Some(Emphasis({ v: { ..v, inline, }, meta }))
    }
    StrongEmphasis({ v, meta }) => {
      guard self.map_inline(v.inline) is Some(inline) else { None }
      Some(StrongEmphasis({ v: { ..v, inline, }, meta }))
    }
    Inlines({ v, meta }) => {
      let v = v._.filter_map(fn(x) { self.map_inline(x) })
      guard not(v.is_empty()) else { None }
      Some(Inlines({ v, meta }))
    }
    ExtStrikethrough({ v, meta }) => {
      guard self.map_inline(v._) is Some(v) else { None }
      Some(ExtStrikethrough({ v, meta }))
    }
    // ext => (self.inline_ext_default)(self, ext)
  }
}

///|
pub fn Mapper::map_block(self : Mapper, b : Block) -> Block? {
  if (self.block)(self, b) is Map(b) {
    return b
  }
  match b {
    BlankLine(_)
    | CodeBlock(_)
    | HtmlBlock(_)
    | LinkRefDefinition(_)
    | ThematicBreak(_)
    | ExtMathBlock(_) as b => Some(b)
    Heading({ v, meta }) => {
      let inline = self
        .map_inline(v.inline)
        .or(Inlines({ v: [], meta: Meta::none() }))
      Some(Heading({ v: { ..v, inline, }, meta }))
    }
    BlockQuote({ v, meta }) => {
      let block = self
        .map_block(v.block)
        .or(Blocks({ v: [], meta: Meta::none() }))
      Some(BlockQuote({ v: { ..v, block, }, meta }))
    }
    Blocks({ v, meta }) =>
      match v._.filter_map(fn(x) { self.map_block(x) }) {
        [] => None
        v => Some(Blocks({ v, meta }))
      }
    List({ v, meta }) => {
      fn map_list_item(i : Node[ListItem]) {
        let { v, meta } = i
        guard self.map_block(i.v.block) is Some(block) else { None }
        Some({ v: { ..v, block, }, meta })
      }

      match v.items._.filter_map(map_list_item) {
        [] => None
        items => Some(List({ v: { ..v, items, }, meta }))
      }
    }
    Paragraph({ v, meta }) => {
      guard self.map_inline(v.inline) is Some(inline) else { None }
      Some(Paragraph({ v: { ..v, inline, }, meta }))
    }
    ExtFootnoteDefinition({ v, meta }) => {
      let block = self
        .map_block(v.block)
        .or_else(fn() { Blocks(Node::new([])) }) // Can be empty
      Some(ExtFootnoteDefinition({ v: { ..v, block, }, meta }))
    }
    ExtTable({ v, meta }) => {
      fn map_col(i, layout) {
        self.map_inline(i).map(fn(i) { (i, layout) })
      }

      fn map_row(row) {
        let ({ v, meta }, blanks) = row
        match v {
          Header(is_) => {
            let is_ = is_._.filter_map(fn(i) { map_col(i.0, i.1) })
            ({ v: Header(is_), meta }, blanks)
          }
          Sep(_) => row
          Data(is_) => {
            let is_ = is_._.filter_map(fn(i) { map_col(i.0, i.1) })
            ({ v: Data(is_), meta }, blanks)
          }
        }
      }

      Some(ExtTable({ v: { ..v, rows: v.rows.map(map_row) }, meta }))
    }
    // ext => (self.block_ext_default)(self, ext)
  }
}

///|
pub fn Mapper::map_doc(self : Mapper, d : Doc) -> Doc {
  let map_block = fn(b) { self.map_block(b).or(Block::empty()) }
  let map_def = fn(b : LabelDef) {
    guard b is FootnoteDef({ v, meta }) else { b }
    let block = map_block(v.block)
    FootnoteDef({ v: { ..v, block, }, meta })
  }
  let block = map_block(d.block)
  let defs = Map::new()
  for k, d in d.defs {
    defs[k] = map_def(d)
  }
  { ..d, block, defs }
}

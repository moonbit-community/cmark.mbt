///| Block lines.
///
/// In CommonMark blocks, a "line" does not necessarily correspond to
/// a line in the source plain text. For example the lines of a
/// paragraph in a block quote are the lines stripped from the block
/// quote markers.  We call the line resulting from stripping the
/// block structure preceeding a given block a {e block line}.
pub(all) type BlockLine Node[String]

///|
pub typealias Node[Blanks] as BlockLineBlank

///|
pub fn BlockLine::to_string(self : BlockLine) -> String {
  self._.v
}

///|
pub fn BlockLine::list_text_loc(ls : Seq[BlockLine]) -> TextLoc {
  match ls._ {
    [] => TextLoc::none()
    [head] => head.meta.loc
    [head, .., last] => head.meta.loc.reloc(last.meta.loc)
  }
}

///| Tight block lines: a block line with its initial blanks trimmed but kept for layout. 
pub(all) struct Tight {
  blanks : Blanks
  node : StringNode
} derive(Eq, ToJson)

///|
pub fn Tight::empty(meta~ : Meta = Meta::none()) -> Tight {
  { blanks: "", node: StringNode::empty(meta~) }
}

///|
pub impl Show for Tight with output(self, logger) {
  logger.write_object(self.node.v)
}

///|
pub fn Tight::to_string(self : Tight) -> String {
  self.node.v
}

///|
pub fn Tight::list_text_loc(ls : Seq[Tight]) -> TextLoc {
  match ls._ {
    [] => TextLoc::none()
    [head] => head.node.meta.loc
    [head, .., last] => head.node.meta.loc.reloc(last.node.meta.loc)
  }
}

// fn BlockLine::flush(
//   meta~ : Meta = Meta::none(),
//   s : String,
//   start : Int,
//   last : Int,
//   acc : Array[StringNode]
// ) -> Unit {
//   acc.push({ meta, v: s.substring(start~, end=last + 1) })
// }

///|
fn BlockLine::flush_tight(
  meta~ : Meta = Meta::none(),
  s : String,
  start : Int,
  last : Int,
  acc : Array[Tight]
) -> Unit {
  // If [s] has newlines, blanks after newlines are layout
  if start > last {
    acc.push(Tight::empty(meta~))
    return
  }
  // On the first line the blanks are legit 
  if acc.is_empty() {
    acc.push({
      blanks: "",
      node: { meta, v: s.substring(start~, end=last + 1) },
    })
    return
  }
  let nb = @cmark_base.first_non_blank(s, last~, start~)
  acc.push({
    blanks: s.substring(start~, end=nb),
    node: { meta, v: s.substring(start=nb, end=last + 1) },
  })
}

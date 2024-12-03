///|
pub fn layout_of_string(meta~ : Meta = Meta::none(), s : String) -> StringNode {
  { meta, v: s }
}

///|
pub let layout_empty : StringNode = layout_of_string("")

///|
pub(all) typealias Blanks = String

///|
pub(all) typealias Count = Int

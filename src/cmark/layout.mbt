///|
pub fn layout_of_string(meta? : Meta = Meta::none(), s : String) -> StringNode {
  { meta, v: s }
}

///|
pub let layout_empty : StringNode = layout_of_string("")

///|
pub typealias String as Blanks

///|
pub typealias Int as Count

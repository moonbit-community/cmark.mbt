///|
pub(all) struct Node[A] {
  v : A
  meta : Meta
} derive(Eq, Debug)

///|
pub fn[A] Node::new(v : A, meta? : Meta = Meta::none()) -> Node[A] {
  { v, meta }
}

///|
pub fn[A, B] Node::map(self : Node[A], f : (A) -> B) -> Node[B] {
  { v: f(self.v), meta: self.meta }
}

///|
pub type StringNode = Node[String]

///|
pub type BlanksNode = Node[Blanks]

///|
pub fn StringNode::empty(meta? : Meta = Meta::none()) -> StringNode {
  { v: "", meta }
}

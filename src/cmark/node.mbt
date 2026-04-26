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
pub impl[A : ToJson] ToJson for Node[A] with to_json(self) {
  let jsons = [self.v.to_json()]
  if !self.meta.is_none() {
    jsons.push(self.meta.to_json())
  }
  Json::array(jsons)
}

///|
pub type StringNode = Node[String]

///|
pub type BlanksNode = Node[Blanks]

///|
pub fn StringNode::empty(meta? : Meta = Meta::none()) -> StringNode {
  { v: "", meta }
}

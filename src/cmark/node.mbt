///|
pub(all) struct Node[A] {
  v : A
  meta : Meta
} derive(Eq)

///|
pub fn Node::new[A](v : A, meta~ : Meta = Meta::none()) -> Node[A] {
  { v, meta }
}

///|
pub fn Node::map[A, B](self : Node[A], f : (A) -> B) -> Node[B] {
  { v: f(self.v), meta: self.meta }
}

///|
pub impl[A : Show] Show for Node[A] with output(self, logger) {
  logger.write_string("Node::new(")
  logger.write_object(self.v)
  if not(self.meta.is_none()) {
    logger.write_string(", meta=")
    logger.write_object(self.meta)
  }
  logger.write_char(')')
}

///|
pub impl[A : ToJson] ToJson for Node[A] with to_json(self) {
  let jsons = [self.v.to_json()]
  if not(self.meta.is_none()) {
    jsons.push(self.meta.to_json())
  }
  Array(jsons)
}

///|
pub(all) typealias StringNode = Node[String]

///|
pub(all) typealias BlanksNode = Node[Blanks]

///|
pub fn StringNode::empty(meta~ : Meta = Meta::none()) -> StringNode {
  { v: "", meta }
}

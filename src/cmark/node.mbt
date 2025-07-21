///|
pub(all) struct Node[A] {
  v : A
  meta : Meta
} derive(Eq)

///|
pub fn[A] Node::new(v : A, meta~ : Meta = Meta::none()) -> Node[A] {
  { v, meta }
}

///|
pub fn[A, B] Node::map(self : Node[A], f : (A) -> B) -> Node[B] {
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
  let jsons = [self.v.to_json(]]
  if not(self.meta.is_none()) {
    jsons.push(self.meta.to_json())
  }
  Json::array(jsons)
}

///|
pub typealias Node[String] as StringNode

///|
pub typealias Node[Blanks] as BlanksNode

///|
pub fn StringNode::empty(meta~ : Meta = Meta::none()) -> StringNode {
  { v: "", meta }
}

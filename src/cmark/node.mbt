pub(all) struct Node[A] {
  v : A
  meta : Meta
} derive(Eq)

pub fn Node::new[A](v : A, meta~ : Meta = Meta::none()) -> Node[A] {
  { v, meta }
}

pub fn Node::map[A, B](self : Node[A], f : (A) -> B) -> Node[B] {
  { v: f(self.v), meta: self.meta }
}

pub impl[A : Show] Show for Node[A] with output(self, logger) {
  logger.write_string("Node::new(")
  logger.write_object(self.v)
  if self.meta.is_none().not() {
    logger.write_string(", meta=")
    logger.write_object(self.meta)
  }
  logger.write_char(')')
}

pub impl[A : ToJson] ToJson for Node[A] with to_json(self) {
  let jsons = [self.v.to_json()]
  if self.meta.is_none().not() {
    jsons.push(self.meta.to_json())
  }
  Array(jsons)
}

pub impl[A : @json.FromJson] @json.FromJson for Node[A] with from_json(
  json,
  path
) {
  match json {
    Array([v]) => Node::new(@json.from_json!(v, path~))
    Array([v, meta]) =>
      Node::new(@json.from_json!(v, path~), meta=@json.from_json!(meta, path~))
    _ => raise @json.JsonDecodeError((path, "expected array of length 1 or 2"))
  }
}

pub(all) typealias StringNode = Node[String]

pub(all) typealias BlanksNode = Node[Blanks]

pub fn StringNode::empty(meta~ : Meta = Meta::none()) -> StringNode {
  { v: "", meta }
}

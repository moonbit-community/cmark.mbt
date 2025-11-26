///|
using @cmark_base {type Indent}

///|
using @cmark_base {type Meta}

///|
using @cmark_base {type TextLoc}

///|
using @cmark_base {type LinePos}

///|
using @cmark_base {type CharCodePos}

///|
using @cmark_base {type FilePath}

///|
let file_path_none = @cmark_base.file_path_none

///|
using @cmark_base {type Span}

///|
using @cmark_base {type LineSpan}

///|
priv struct Tokens(@deque.Deque[Token])

///|
impl Show for Tokens with output(self, logger) {
  logger.write_object(self.0)
}

///|
impl ToJson for Tokens with to_json(self) {
  Json::array(Array::from_iter(self.0.iter().map(ToJson::to_json)))
}

///|
test {
  // Prevent warning about unused Show and ToJson
  (fn(t : Tokens) { t.to_string() }) |> ignore()
  (fn(t : Tokens) { t.to_json() }) |> ignore()
}

///|
fn Tokens::push(self : Tokens, t : Token) -> Unit {
  self.0.push_back(t)
}

// fn Tokens::pop(self : Tokens) -> Token? {
//   self._.pop_back()
// }

///|
priv struct RevTokens(@deque.Deque[Token])

///|
impl Show for RevTokens with output(self, logger) {
  logger.write_object(self.0)
}

///|
impl ToJson for RevTokens with to_json(self) {
  Json::array(Array::from_iter(self.0.iter().map(ToJson::to_json)))
}

///|
test {
  // Prevent warning about unused Show and ToJson
  (fn(t : RevTokens) { t.to_string() }) |> ignore()
  (fn(t : RevTokens) { t.to_json() }) |> ignore()
}

///|
fn RevTokens::push(self : RevTokens, t : Token) -> Unit {
  self.0.push_front(t)
}

///|
fn RevTokens::pop(self : RevTokens) -> Token? {
  self.0.pop_front()
}

///|
using @cmark_base {type HeadingLevel}

///|
using @cmark_base {type NextLineFn}

///|
using @cmark_base {type HtmlBlockEndCond}

///|
using @cmark_base {type ListType}

///|
using @cmark_base {type LineType}

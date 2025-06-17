///|
typealias StringBuilder as Buffer

///|
typealias @cmark_base.Indent

///|
typealias @cmark_base.Meta

///|
typealias @cmark_base.TextLoc

///|
typealias @cmark_base.LinePos

///|
typealias @cmark_base.CharCodePos

///|
typealias @cmark_base.FilePath

///|
let file_path_none = @cmark_base.file_path_none

///|
typealias @cmark_base.Span

///|
typealias @cmark_base.LineSpan

///|
priv type Tokens @deque.T[Token]

///|
impl Show for Tokens with output(self, logger) {
  logger.write_object(self.inner())
}

///|
impl ToJson for Tokens with to_json(self) {
  Json::array(Array::from_iter(self.inner().iter().map(ToJson::to_json)))
}

///|
fn Tokens::push(self : Tokens, t : Token) -> Unit {
  self.inner().push_back(t)
}

// fn Tokens::pop(self : Tokens) -> Token? {
//   self._.pop_back()
// }

///|
priv type RevTokens @deque.T[Token]

///|
impl Show for RevTokens with output(self, logger) {
  logger.write_object(self.inner())
}

///|
impl ToJson for RevTokens with to_json(self) {
  Json::array(Array::from_iter(self.inner().iter().map(ToJson::to_json)))
}

///|
fn RevTokens::push(self : RevTokens, t : Token) -> Unit {
  self.inner().push_front(t)
}

///|
fn RevTokens::pop(self : RevTokens) -> Token? {
  self.inner().pop_front()
}

///|
typealias @cmark_base.HeadingLevel

///|
typealias @cmark_base.NextLineFn

///|
typealias @cmark_base.HtmlBlockEndCond

///|
typealias @cmark_base.ListType

///|
typealias @cmark_base.LineType

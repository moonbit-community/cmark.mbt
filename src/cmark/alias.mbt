///|
typealias Buffer = StringBuilder

///|
typealias Indent = @cmark_base.Indent

///|
typealias Meta = @cmark_base.Meta

///|
typealias TextLoc = @cmark_base.TextLoc

///|
typealias LinePos = @cmark_base.LinePos

///|
typealias CharCodePos = @cmark_base.CharCodePos

///|
typealias FilePath = @cmark_base.FilePath

///|
let file_path_none = @cmark_base.file_path_none

///|
typealias Span = @cmark_base.Span

///|
typealias LineSpan = @cmark_base.LineSpan

///|
priv type Tokens @deque.T[Token]

///|
impl Show for Tokens with output(self, logger) {
  logger.write_object(self._)
}

///|
impl ToJson for Tokens with to_json(self) {
  Json::array(Array::from_iter(self._.iter().map(ToJson::to_json)))
}

///|
fn Tokens::push(self : Tokens, t : Token) -> Unit {
  self._.push_back(t)
}

///|
fn Tokens::pop(self : Tokens) -> Token? {
  self._.pop_back()
}

///|
priv type RevTokens @deque.T[Token]

///|
impl Show for RevTokens with output(self, logger) {
  logger.write_object(self._)
}

///|
impl ToJson for RevTokens with to_json(self) {
  Json::array(Array::from_iter(self._.iter().map(ToJson::to_json)))
}

///|
fn RevTokens::push(self : RevTokens, t : Token) -> Unit {
  self._.push_front(t)
}

///|
fn RevTokens::pop(self : RevTokens) -> Token? {
  self._.pop_front()
}

///|
typealias HeadingLevel = @cmark_base.HeadingLevel

///|
typealias NextLineFn[A] = @cmark_base.NextLineFn[A]

///|
typealias HtmlBlockEndCond = @cmark_base.HtmlBlockEndCond

///|
typealias ListType = @cmark_base.ListType

///|
typealias LineType = @cmark_base.LineType

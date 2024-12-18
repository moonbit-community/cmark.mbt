///|
typealias List[A] = @immut/list.T[A]

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
typealias BytePos = @cmark_base.BytePos

///|
typealias FilePath = @cmark_base.FilePath

///|
let file_path_none = @cmark_base.file_path_none

///|
typealias Span = @cmark_base.Span

///|
typealias LineSpan = @cmark_base.LineSpan

///|
pub(all) typealias RevTokens = Array[Token]

///|
pub(all) typealias RevTokensView = ArrayView[Token]

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

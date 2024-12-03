///|
pub(all) struct TextLoc {
  file : FilePath
  first_byte : BytePos
  last_byte : BytePos
  first_line : LinePos
  last_line : LinePos
} derive(Eq, Compare, Show, FromJson, ToJson)

///|
let text_loc_none : TextLoc = {
  file: file_path_none,
  first_byte: byte_pos_none,
  last_byte: byte_pos_none,
  first_line: line_pos_none,
  last_line: line_pos_none,
}

///|
pub fn TextLoc::none() -> TextLoc {
  text_loc_none
}

///|
pub fn TextLoc::is_none(self : TextLoc) -> Bool {
  self.first_byte < 0
}

///|
pub fn TextLoc::is_empty(self : TextLoc) -> Bool {
  self.first_byte > self.last_byte
}

///|
pub fn TextLoc::to_first(self : TextLoc) -> TextLoc {
  { ..self, last_byte: self.first_byte, last_line: self.first_line }
}

///|
pub fn TextLoc::to_last(self : TextLoc) -> TextLoc {
  { ..self, first_byte: self.last_byte, first_line: self.last_line }
}

///|
pub fn TextLoc::after(self : TextLoc) -> TextLoc {
  {
    ..self,
    first_byte: self.first_byte + 1,
    last_byte: byte_pos_none,
    first_line: self.last_line,
    last_line: line_pos_none,
  }
}

///|
pub fn TextLoc::span(self : TextLoc, other : TextLoc) -> TextLoc {
  let { first_byte, first_line, .. } = min_by_key(
    self,
    other,
    fn(it) { it.first_byte },
  )
  let { file, last_byte, last_line, .. } = max_by_key(
    self,
    other,
    fn(it) { it.last_byte },
  )
  { file, first_byte, last_byte, first_line, last_line }
}

///|
pub fn TextLoc::reloc(self : TextLoc, other : TextLoc) -> TextLoc {
  let { first_byte, first_line, .. } = self
  let { file, last_byte, last_line, .. } = other
  { file, first_byte, last_byte, first_line, last_line }
}

// TODO: Formatters unimplemented

///|
pub(all) typealias FilePath = String

///|
pub let file_path_none = "-"

///|
pub(all) typealias BytePos = Int // 0-based

///|
pub let byte_pos_none : BytePos = -1

///|
pub(all) typealias LineNum = Int // 1-based

///|
pub let line_num_none = -1

///|
pub(all) typealias LinePos = (LineNum, BytePos)

///|
pub let line_pos_none : LinePos = (line_num_none, byte_pos_none)

///|
pub(all) struct LineSpan {
  pos : LinePos
  first : BytePos
  last : BytePos
} derive(Show, ToJson, Eq, Compare)

// A line span with the byte position on where the line starts (inside a CommonMark container).  The [line_start] is the start of line in the container, the [line_span] has the actual data. The characters in the \[[line_start];[line_span.first - 1]\] are blanks.
///|
pub(all) struct Span {
  start : BytePos
  span : LineSpan
} derive(Show, ToJson, Eq, Compare)

///|
pub(all) typealias NextLineFn[A] = (A) -> (A, LineSpan)?

///|
pub(all) enum NextLineResult[A] {
  ThisLine(BytePos)
  NextLine(A, LineSpan, BytePos)
} derive(Show, ToJson)

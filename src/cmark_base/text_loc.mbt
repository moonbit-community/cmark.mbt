///|
pub(all) struct TextLoc {
  file : FilePath
  first_ccode : CharCodePos
  last_ccode : CharCodePos
  first_line : LinePos
  last_line : LinePos
} derive(Eq, Compare, Show, FromJson, ToJson)

///|
let text_loc_none : TextLoc = {
  file: file_path_none,
  first_ccode: char_code_pos_none,
  last_ccode: char_code_pos_none,
  first_line: line_pos_none,
  last_line: line_pos_none,
}

///|
pub fn TextLoc::none() -> TextLoc {
  text_loc_none
}

///|
pub fn TextLoc::is_none(self : TextLoc) -> Bool {
  self.first_ccode < 0
}

///|
pub fn TextLoc::is_empty(self : TextLoc) -> Bool {
  self.first_ccode > self.last_ccode
}

///|
pub fn TextLoc::to_first(self : TextLoc) -> TextLoc {
  { ..self, last_ccode: self.first_ccode, last_line: self.first_line }
}

///|
pub fn TextLoc::to_last(self : TextLoc) -> TextLoc {
  { ..self, first_ccode: self.last_ccode, first_line: self.last_line }
}

///|
pub fn TextLoc::after(self : TextLoc) -> TextLoc {
  {
    ..self,
    first_ccode: self.first_ccode + 1,
    last_ccode: char_code_pos_none,
    first_line: self.last_line,
    last_line: line_pos_none,
  }
}

///|
pub fn TextLoc::span(self : TextLoc, other : TextLoc) -> TextLoc {
  let { first_ccode, first_line, .. } = @cmp.minimum_by_key(self, other, fn(
    it,
  ) {
    it.first_ccode
  })
  let { file, last_ccode, last_line, .. } = @cmp.maximum_by_key(self, other, fn(
    it,
  ) {
    it.last_ccode
  })
  { file, first_ccode, last_ccode, first_line, last_line }
}

///|
pub fn TextLoc::reloc(self : TextLoc, other : TextLoc) -> TextLoc {
  let { first_ccode, first_line, .. } = self
  let { file, last_ccode, last_line, .. } = other
  { file, first_ccode, last_ccode, first_line, last_line }
}

// TODO: Formatters unimplemented

///|
pub typealias String as FilePath

///|
pub let file_path_none = "-"

///|
pub typealias Int as CharCodePos // 0-based

///|
pub let char_code_pos_none : CharCodePos = -1

///|
pub typealias Int as LineNum // 1-based

///|
pub let line_num_none = -1

///|
pub(all) struct LinePos(LineNum, CharCodePos) derive (
  Show,
  Eq,
  Compare,
  FromJson,
  ToJson,
)

///|
pub let line_pos_none : LinePos = LinePos(line_num_none, char_code_pos_none)

///|
pub(all) struct LineSpan {
  pos : LinePos
  first : CharCodePos
  last : CharCodePos
} derive(Show, ToJson, Eq, Compare)

///|
///  A line span with the byte position on where the line starts (inside a CommonMark container).  The [line_start] is the start of line in the container, the [line_span] has the actual data. The characters in the \[[line_start];[line_span.first - 1]\] are blanks.
pub(all) struct Span {
  start : CharCodePos
  span : LineSpan
} derive(Show, ToJson, Eq, Compare)

///|
pub(all) struct NextLineFn[A]((A) -> LineSpan?)

///|
pub(all) enum NextLineResult {
  ThisLine(CharCodePos)
  NextLine(LineSpan, CharCodePos)
} derive(Show, ToJson(style="flat"))

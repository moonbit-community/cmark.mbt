///|
/// The type for indentation magnitude.
pub type Indent = Int

///|
/// The type for the first first byte position of a parsed construct.
pub type First = CharCodePos

///|
/// The type for the last byte position of a parsed construct.
pub type Last = CharCodePos

///|
/// The type for a byte position after a parsed construct. The byte position
/// may be invalid (end of input range) or on the newline.
pub type Next = CharCodePos

///|
/// The type for heading levels.
pub type HeadingLevel = Int

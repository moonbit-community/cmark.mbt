// The type for indentation magnitude. 
///|
pub(all) typealias Indent = Int

// The type for the first first byte position of a parsed construct.
///|
pub(all) typealias First = CharCodePos

// The type for the last byte position of a parsed construct.
///|
pub(all) typealias Last = CharCodePos

// The type for a byte position after a parsed construct. The byte position
// may be invalid (end of input range) or on the newline.
///|
pub(all) typealias Next = CharCodePos

// The type for heading levels.
///|
pub(all) typealias HeadingLevel = Int

// The type for indentation magnitude. 
pub typealias Indent = Int

// The type for the first first byte position of a parsed construct.
pub typealias First = BytePos

// The type for the last byte position of a parsed construct.
pub typealias Last = BytePos

// The type for a byte position after a parsed construct. The byte position
// may be invalid (end of input range) or on the newline.
pub typealias Next = BytePos

// The type for heading levels.
pub typealias HeadingLevel = Int

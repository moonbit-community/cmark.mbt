test "from_int_checked with value >= 0x110000" {
  inspect!(@char.from_int_checked(0x110000), content="None")
}

test "from_int_checked with surrogate pair range" {
  inspect!(@char.from_int_checked(0xD800), content="None")
  inspect!(@char.from_int_checked(0xD900), content="None")
  inspect!(@char.from_int_checked(0xDFFF), content="None")
}

test "length_utf8 for 2 bytes UTF-8 character" {
  // Test character between 0x80 and 0x800
  // e.g., '¢' (0x00A2)
  inspect!(@char.length_utf8('¢'), content="2")
}

test "length_utf8 for 3 bytes UTF-8 character" {
  // Test character between 0x800 and 0x10000
  // e.g., '€' (0x20AC)
  inspect!(@char.length_utf8('€'), content="3")
}

test "length_utf8 for 4 bytes UTF-8 character" {
  // Test character between 0x10000 and 0x110000
  // e.g., '𐍈' (0x10348)
  inspect!(@char.length_utf8('𐍈'), content="4")
}

test "length_utf32 returns 1 for any character" {
  inspect!(@char.length_utf32('A'), content="1")
  inspect!(@char.length_utf32('世'), content="1")
  inspect!(@char.length_utf32('🌟'), content="1")
}

test "panic length_utf8_invalid_rune" {
  // Create a char with value larger than 0x110000
  let invalid_char = Char::from_int(0x110000)
  inspect!(@char.length_utf8(invalid_char))
}

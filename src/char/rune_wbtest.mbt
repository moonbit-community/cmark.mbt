test "from_int_checked with value >= 0x110000" {
  inspect!(from_int_checked(0x110000), content="None")
}

test "from_int_checked with surrogate range value" {
  inspect!(from_int_checked(0xD800), content="None")
  inspect!(from_int_checked(0xD900), content="None")
  inspect!(from_int_checked(0xDFFF), content="None")
}

test "length_utf8_3_bytes" {
  // Test characters that require 3 bytes in UTF-8 (0x800 to 0xFFFF)
  inspect!(length_utf8('€'), content="3") // U+20AC
  inspect!(length_utf8('㊗'), content="3") // U+3297
}

test "length_utf8_4_bytes" {
  // Test characters that require 4 bytes in UTF-8 (0x10000 to 0x10FFFF)
  inspect!(length_utf8('🌍'), content="4") // U+1F30D
  inspect!(length_utf8('𐐷'), content="4") // U+10437
}

test "panic length_utf8_invalid" {
  // Test invalid character (above 0x110000)
  inspect!(length_utf8(Char::from_int(0x110000)))
}

test "length_utf32 returns 1" {
  inspect!(length_utf32('a'), content="1")
  inspect!(length_utf32('字'), content="1")
  inspect!(length_utf32('🌞'), content="1")
}

test "length_utf8 for 2-byte UTF-8 characters" {
  // Test characters in the range 0x80 to 0x800 (requiring 2 bytes in UTF-8)
  // '¢' (cent sign) has code point 0xA2
  // 'π' (pi) has code point 0x3C0
  // 'Ω' (omega) has code point 0x3A9
  inspect!(length_utf8('¢'), content="2")
  inspect!(length_utf8('π'), content="2")
  inspect!(length_utf8('Ω'), content="2")
}

///|
test "length_utf8 with multibyte char 1" {
  inspect(@char.length_utf8('¢'), content="2")
}

///|
test "length_utf8 with multibyte char 2" {
  inspect(@char.length_utf8('€'), content="3")
}

///|
test "length_utf8 with multibyte char 3" {
  inspect(@char.length_utf8('🌍'), content="4")
}

///|
test "panic length_utf8 with invalid char" {
  let invalid = 0x110000
  ignore(@char.length_utf8(invalid))
}

///|
test "length_utf32 returns 1" {
  inspect(@char.length_utf32('A'), content="1")
}

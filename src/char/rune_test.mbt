///|
test "from_int_checked invalid surrogates" {
  inspect!(from_int_checked(0xD800), content="None")
  inspect!(from_int_checked(0xD900), content="None")
  inspect!(from_int_checked(0xDFFF), content="None")
}

///|
test "from_int_checked too large" {
  inspect!(from_int_checked(0x110000), content="None")
  inspect!(from_int_checked(0x200000), content="None")
}

///|
test "length_utf8 with multibyte char 1" {
  inspect!(length_utf8('¢'), content="2")
}

///|
test "length_utf8 with multibyte char 2" {
  inspect!(length_utf8('€'), content="3")
}

///|
test "length_utf8 with multibyte char 3" {
  inspect!(length_utf8('🌍'), content="4")
}

///|
test "panic length_utf8 with invalid char" {
  let invalid_char = Char::from_int(0x110000)
  ignore(length_utf8(invalid_char))
}

///|
test "length_utf32 returns 1" {
  inspect!(length_utf32('A'), content="1")
}

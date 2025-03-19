///|
test "to_ascii_lower uppercase to lowercase" {
  inspect!(to_ascii_lower('A'), content="a")
  inspect!(to_ascii_lower('Z'), content="z")
  inspect!(to_ascii_lower('M'), content="m")
}

///|
test "to_ascii_upper: convert lowercase to uppercase" {
  inspect!(to_ascii_upper('a'), content="A")
  inspect!(to_ascii_upper('z'), content="Z")
}

///|
test "to_ascii_upper: keep uppercase unchanged" {
  inspect!(to_ascii_upper('A'), content="A")
}

///|
test "to_ascii_upper: keep non-letters unchanged" {
  inspect!(to_ascii_upper('1'), content="1")
  inspect!(to_ascii_upper('@'), content="@")
}

///|
test "is_ascii_graphic with graphic chars" {
  // Test with exclamation mark (first graphic char)
  inspect!(is_ascii_graphic('!'), content="true")
  // Test with tilde (last graphic char)
  inspect!(is_ascii_graphic('~'), content="true")
  // Test with some middle graphic chars
  inspect!(is_ascii_graphic('A'), content="true")
  inspect!(is_ascii_graphic('5'), content="true")
}

///|
test "is_ascii_graphic with non-graphic chars" {
  // Test with chars before '!'
  inspect!(is_ascii_graphic(' '), content="false")
  // Test with chars after '~'
  inspect!(is_ascii_graphic('\x7F'), content="false")
}

///|
test "ascii_octdigit_to_int normal cases" {
  inspect!(ascii_octdigit_to_int('0'), content="0")
  inspect!(ascii_octdigit_to_int('3'), content="3")
  inspect!(ascii_octdigit_to_int('7'), content="7")
}

///|
test "panic ascii_octdigit_to_int invalid input" {
  ignore(ascii_octdigit_to_int('8'))
}

///|
test "panic ascii_hexdigit_to_int non hex char" {
  ignore(ascii_hexdigit_to_int('g'))
}

///|
test "panic ascii_digit_to_int with non-digit" {
  ignore(ascii_digit_to_int('a'))
}

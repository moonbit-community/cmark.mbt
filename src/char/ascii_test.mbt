test "to_ascii_lower with uppercase letter" {
  inspect!(@char.to_ascii_lower('A'), content="'a'")
  inspect!(@char.to_ascii_lower('Z'), content="'z'")
  inspect!(@char.to_ascii_lower('M'), content="'m'")
}

test "to_ascii_upper with lowercase letter" {
  inspect!(@char.to_ascii_upper('a'), content="'A'")
  inspect!(@char.to_ascii_upper('z'), content="'Z'")
}

test "to_ascii_upper with non-lowercase character" {
  inspect!(@char.to_ascii_upper('A'), content="'A'")
  inspect!(@char.to_ascii_upper('!'), content="'!'")
  inspect!(@char.to_ascii_upper('5'), content="'5'")
}

test "is_ascii_graphic true cases" {
  inspect!(@char.is_ascii_graphic('!'), content="true") // first graphic char
  inspect!(@char.is_ascii_graphic('~'), content="true") // last graphic char
  inspect!(@char.is_ascii_graphic('A'), content="true") // middle graphic char
}

test "is_ascii_graphic false cases" {
  inspect!(@char.is_ascii_graphic(' '), content="false") // before '!'
  inspect!(@char.is_ascii_graphic('\x7F'), content="false") // after '~'
}

test "panic ascii_digit_to_int with non-digit" {
  inspect!(@char.ascii_digit_to_int('a'))
}

test "is_ascii_octdigit with valid octal digits" {
  inspect!(@char.is_ascii_octdigit('0'), content="true")
  inspect!(@char.is_ascii_octdigit('3'), content="true")
  inspect!(@char.is_ascii_octdigit('7'), content="true")
}

test "is_ascii_octdigit with invalid octal digits" {
  inspect!(@char.is_ascii_octdigit('8'), content="false")
  inspect!(@char.is_ascii_octdigit('a'), content="false")
  inspect!(@char.is_ascii_octdigit('/'), content="false")
}

test "ascii_octdigit_to_int with valid octal digits" {
  inspect!(@char.ascii_octdigit_to_int('0'), content="0")
  inspect!(@char.ascii_octdigit_to_int('3'), content="3")
  inspect!(@char.ascii_octdigit_to_int('7'), content="7")
}

test "panic ascii_octdigit_to_int with invalid input" {
  inspect!(@char.ascii_octdigit_to_int('8'))
}

test "panic ascii_hexdigit_to_int with invalid hex character" {
  inspect!(@char.ascii_hexdigit_to_int('g'))
}

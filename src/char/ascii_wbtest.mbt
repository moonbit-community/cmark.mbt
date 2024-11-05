test "is_ascii_graphic basic cases" {
  // Test boundary cases ('!' and '~')
  inspect!(is_ascii_graphic('!'), content="true")
  inspect!(is_ascii_graphic('~'), content="true")

  // Test middle cases
  inspect!(is_ascii_graphic('A'), content="true")
  inspect!(is_ascii_graphic('5'), content="true")

  // Test non-graphic characters
  inspect!(is_ascii_graphic(' '), content="false")
  inspect!(is_ascii_graphic('\x7F'), content="false")
}

test "panic ascii_digit_to_int with non-digit" {
  inspect!(ascii_digit_to_int('a'))
}

test "is_ascii_octdigit negative cases" {
  inspect!(is_ascii_octdigit('8'), content="false")
  inspect!(is_ascii_octdigit('a'), content="false")
}

test "is_ascii_hexdigit with digits" {
  inspect!(is_ascii_hexdigit('0'), content="true")
  inspect!(is_ascii_hexdigit('5'), content="true")
  inspect!(is_ascii_hexdigit('9'), content="true")
}

test "is_ascii_hexdigit with uppercase letters" {
  inspect!(is_ascii_hexdigit('A'), content="true")
  inspect!(is_ascii_hexdigit('C'), content="true")
  inspect!(is_ascii_hexdigit('F'), content="true")
}

test "is_ascii_hexdigit with lowercase letters" {
  inspect!(is_ascii_hexdigit('a'), content="true")
  inspect!(is_ascii_hexdigit('d'), content="true")
  inspect!(is_ascii_hexdigit('f'), content="true")
}

test "ascii_hexdigit_to_int with decimal digits" {
  inspect!(ascii_hexdigit_to_int('0'), content="0")
  inspect!(ascii_hexdigit_to_int('5'), content="5")
  inspect!(ascii_hexdigit_to_int('9'), content="9")
}

test "ascii_hexdigit_to_int with uppercase hex digits" {
  inspect!(ascii_hexdigit_to_int('A'), content="10")
  inspect!(ascii_hexdigit_to_int('F'), content="15")
}

test "ascii_hexdigit_to_int with lowercase hex digits" {
  inspect!(ascii_hexdigit_to_int('a'), content="10")
  inspect!(ascii_hexdigit_to_int('f'), content="15")
}

test "panic ascii_hexdigit_to_int with invalid char" {
  inspect!(ascii_hexdigit_to_int('g'))
}

test "to_ascii_upper with lowercase letter" {
  // Converting lowercase to uppercase
  inspect!(to_ascii_upper('a'), content="'A'")
  inspect!(to_ascii_upper('z'), content="'Z'")
}

test "to_ascii_upper with non-lowercase char" {
  // Returning non-lowercase chars as-is
  inspect!(to_ascii_upper('A'), content="'A'")
  inspect!(to_ascii_upper('1'), content="'1'")
  inspect!(to_ascii_upper('!'), content="'!'")
}

test "panic ascii_octdigit_to_int with invalid input" {
  inspect!(ascii_octdigit_to_int('8'))
}

test "ascii_octdigit_to_int basic conversion" {
  inspect!(ascii_octdigit_to_int('0'), content="0")
  inspect!(ascii_octdigit_to_int('3'), content="3")
  inspect!(ascii_octdigit_to_int('7'), content="7")
}

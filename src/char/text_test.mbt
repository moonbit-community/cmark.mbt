///|
test "utf_16_clean_raw with padding" {
  let buf = StringBuilder::new()
  let s = "hello"
  inspect(
    @char.utf_16_clean_raw(pad=2, buf, s, first=0, last=4),
    content="  hello",
  )
}

///|
test "utf_16_clean_raw without padding" {
  let buf = StringBuilder::new()
  let s = "hello"
  inspect(
    @char.utf_16_clean_raw(pad=0, buf, s, first=0, last=4),
    content="hello",
  )
}

///|
test "utf_16_clean_raw with empty string" {
  let buf = StringBuilder::new()
  let s = ""
  inspect(@char.utf_16_clean_raw(pad=2, buf, s, first=0, last=0), content="  ")
  inspect(@char.utf_16_clean_raw(pad=0, buf, s, first=0, last=0), content="")
}

///|
test "utf_16_clean_raw with invalid range" {
  let buf = StringBuilder::new()
  let s = "hello"
  inspect(@char.utf_16_clean_raw(pad=0, buf, s, first=5, last=2), content="")
  inspect(@char.utf_16_clean_raw(pad=2, buf, s, first=5, last=2), content="  ")
}

///|
test "utf_16_clean_raw with null character" {
  let buf = StringBuilder::new()
  let s = "hel\u{0}lo"
  inspect(
    @char.utf_16_clean_raw(pad=0, buf, s, first=0, last=5),
    content="hel�lo",
  )
}

///|
test "utf_16_clean_unref vs utf_16_clean_unesc_unref" {
  // Test the difference between the two functions
  let buf = StringBuilder::new()
  let s = "a\\*b"
  // utf_16_clean_unref should not unescape
  inspect(@char.utf_16_clean_unref(buf, s, first=0, last=3), content="a\\*b")
  // utf_16_clean_unesc_unref should unescape
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="a*b",
  )
}

///|
test "try_entity_hex invalid" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "&#xqq;", first=0, last=5),
    content="&#xqq;",
  )
}

///|
test "try_entity_named empty" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "&;", first=0, last=1),
    content="&;",
  )
}

///|
test "resolve empty" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(@char.utf_16_clean_unesc_unref(buf, "", first=1, last=0), content="")
}

///|
test "resolve escaped chars" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "\\", first=0, last=0),
    content="\\",
  )
}

///|
test "try_entity_named with incomplete entity" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "&abc"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="&abc",
  )
}

///|
test "handling null character and non-ascii chars" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\u{0}\u{FF}"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=1),
    content="�ÿ",
  )
}

///|
test "handling escape with non-punctuation" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\\a"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=1),
    content="\\a",
  )
}

///|
test "hex entity with invalid length" {
  let buf = StringBuilder::new()
  let s = "&#x123456789;" // Too long hex entity
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=11),
    content="&#x123456789",
  )
}

///|
test "hex entity with null char" {
  let buf = StringBuilder::new()
  let s = "&#x0;" // Represents null character
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=4),
    content="�",
  )
}

///|
test "non-ASCII valid UTF-16 sequence" {
  let buf = StringBuilder::new()
  // Valid UTF-16 sequence for a non-ASCII character
  let s = "a😀b"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="a😀b",
  )
}

///|
test "decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#65;" // Decimal for 'A'
  inspect(@char.utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="A")
}

///|
test "invalid decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#a;" // Not a valid decimal
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="&#a;",
  )
}

///|
test "empty decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#;" // Empty decimal reference
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=2),
    content="&#;",
  )
}

///|
test "decimal entity reference too long" {
  let buf = StringBuilder::new()
  let s = "&#12345678;" // Too long decimal entity
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=10),
    content="&#12345678;",
  )
}

///|
test "try_entity_named with valid entity" {
  let buf = StringBuilder::new()
  let s = "&amp;" // HTML entity for '&'
  inspect(@char.utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="&")
}

///|
test "try_entity_named with non-alphabetic character" {
  let buf = StringBuilder::new()
  let s = "&123;"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=4),
    content="&123;",
  )
}

///|
test "at_checked valid character" {
  let s = "hello"
  match @char.at_checked(s, 0) {
    Ok(c) => inspect(c.to_string(), content="h")
    Err(_) => inspect("Should not reach here", content="")
  }
}

///|
test "at_checked with boundary" {
  let s = "hello"
  // Check if it handles index at the boundary correctly
  match @char.at_checked(s, 4) {
    Ok(c) => inspect(c.to_string(), content="o")
    Err(_) => inspect("Should not reach here", content="")
  }
}

///|
test "at_checked with invalid utf16 surrogate" {
  let s = "👋"
  debug_inspect(@char.at_checked(s, 1), content="Err(56395)")
}

///|
test "entity_decimal with invalid continuation" {
  let buf = StringBuilder::new()
  // Test a decimal entity that has a non-digit character after '&#'
  let s = "&#a123;"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=6),
    content="&#a123;",
  )
}

///|
test "entity_decimal with empty reference" {
  let buf = StringBuilder::new()
  // Test an empty decimal entity reference
  let s = "&#;"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=2),
    content="&#;",
  )
}

///|
test "clean_unesc_unref with invalid utf16 sequence" {
  // We need to simulate an invalid UTF-16 sequence that would trigger the Err branch
  let buf = StringBuilder::new()

  // Instead of trying to create an invalid UTF-16 character directly,
  // let's test the handling of the replacement character
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "a\u{fffd}b", first=0, last=2),
    content="a\u{fffd}b",
  )
}

///|
test "sub_includes with matching at end" {
  inspect(
    @char.sub_includes(affix="abc", "xxxabc", first=3, last=5),
    content="true",
  )
}

///|
test "empty decimal entity reference (2)" {
  let buf = StringBuilder::new()
  let s = "&#;"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=2),
    content="&#;",
  )
}

///|
test "non-digit in decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#A;"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="&#A;",
  )
}

///|
test "at_checked valid character (2)" {
  let s = "hello"
  match @char.at_checked(s, 0) {
    Ok(c) => inspect(c.to_string(), content="h")
    Err(_) => inspect("Should not reach here", content="")
  }
}

///|
test "at_checked invalid character" {
  let s = "🌞"
  debug_inspect(@char.at_checked(s, 0), content="Ok('🌞')")
  debug_inspect(@char.at_checked(s, 1), content="Err(57118)")
}

///|
test "utf_16_clean_unref vs utf_16_clean_unesc_unref (2)" {
  // Test the difference between the two functions
  let buf = StringBuilder::new()
  let s = "a\\*b"
  // utf_16_clean_unref should not unescape
  inspect(@char.utf_16_clean_unref(buf, s, first=0, last=3), content="a\\*b")
  // utf_16_clean_unesc_unref should unescape
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="a*b",
  )
}

///|
test "decimal entity reference (2)" {
  let buf = StringBuilder::new()
  let s = "&#65;" // Decimal for 'A'
  inspect(@char.utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="A")
}

///|
test "invalid decimal entity reference (2)" {
  let buf = StringBuilder::new()
  let s = "&#a;" // Not a valid decimal
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="&#a;",
  )
}

///|
test "empty decimal entity reference (3)" {
  let buf = StringBuilder::new()
  let s = "&#;" // Empty decimal reference
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=2),
    content="&#;",
  )
}

///|
test "decimal entity reference too long (2)" {
  let buf = StringBuilder::new()
  let s = "&#12345678;" // Too long decimal entity
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=10),
    content="&#12345678;",
  )
}

///|
test "try_entity_hex invalid (2)" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "&#xqq;", first=0, last=5),
    content="&#xqq;",
  )
}

///|
test "try_entity_named empty (2)" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "&;", first=0, last=1),
    content="&;",
  )
}

///|
test "resolve empty (2)" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(@char.utf_16_clean_unesc_unref(buf, "", first=1, last=0), content="")
}

///|
test "resolve escaped chars (2)" {
  let buf = StringBuilder::new(size_hint=0)
  inspect(
    @char.utf_16_clean_unesc_unref(buf, "\\", first=0, last=0),
    content="\\",
  )
}

///|
test "try_entity_named with incomplete entity (2)" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "&abc"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="&abc",
  )
}

///|
test "handling null character and non-ascii chars (2)" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\u0000\u00FF"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=1),
    content="�ÿ",
  )
}

///|
test "handling escape with non-punctuation (2)" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\\a"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=1),
    content="\\a",
  )
}

///|
test "hex entity with invalid length (2)" {
  let buf = StringBuilder::new()
  let s = "&#x123456789;" // Too long hex entity
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=11),
    content="&#x123456789",
  )
}

///|
test "hex entity with null char (2)" {
  let buf = StringBuilder::new()
  let s = "&#x0;" // Represents null character
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=4),
    content="�",
  )
}

///|
test "non-ASCII valid UTF-16 sequence (2)" {
  let buf = StringBuilder::new()
  // Valid UTF-16 sequence for a non-ASCII character
  let s = "a😀b"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=3),
    content="a😀b",
  )
}

///|
test "try_entity_named with valid entity (2)" {
  let buf = StringBuilder::new()
  let s = "&amp;" // HTML entity for '&'
  inspect(@char.utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="&")
}

///|
test "try_entity_named with non-alphabetic character (2)" {
  let buf = StringBuilder::new()
  let s = "&123;"
  inspect(
    @char.utf_16_clean_unesc_unref(buf, s, first=0, last=4),
    content="&123;",
  )
}

///|
test "sub_includes empty string returns false" {
  inspect(@char.sub_includes(affix="abc", "", first=0, last=0), content="false")
}

///|
test "sub_includes longer affix returns false" {
  inspect(
    @char.sub_includes(affix="abcdef", "abc", first=0, last=2),
    content="false",
  )
}

///|
test "sub_includes full match" {
  inspect(
    @char.sub_includes(affix="abc", "zabc", first=1, last=4),
    content="true",
  )
}

///|
test "sub_includes partial match" {
  inspect(
    @char.sub_includes(affix="abc", "zabxc", first=1, last=5),
    content="false",
  )
}

///|
test "sub_includes no match" {
  inspect(
    @char.sub_includes(affix="abc", "xyz", first=0, last=2),
    content="false",
  )
}

///|
test "sub_includes repeated pattern match" {
  // Test the case where a partial match is found and then restarting from next position
  inspect(
    @char.sub_includes(affix="abc", "abababc", first=0, last=6),
    content="true",
  )
}

///|
fn string_of_code_units(units : Array[Int]) -> String {
  let b = StringBuilder::new()
  for u in units {
    b.write_char(u.unsafe_to_char())
  }
  b.to_string()
}

///|
test "prev_char returns the immediately preceding char" {
  // BMP chars are single UTF-16 units: the old implementation scanned
  // backwards for UTF-8 lead bytes and returned the wrong char.
  inspect(@char.prev_char("aж*", first=0, before=2), content="ж")
  inspect(@char.prev_char("a😀*", first=0, before=3), content="😀")
  inspect(@char.prev_char("ab", first=0, before=1), content="a")
  inspect(@char.prev_char("ab", first=1, before=1), content=" ")
}

///|
test "prev_char and next_char on unpaired surrogates" {
  let lone_trail = string_of_code_units(['a'.to_int(), 0xDC00, '*'.to_int()])
  inspect(@char.prev_char(lone_trail, first=0, before=2), content="�")
  inspect(@char.next_char(lone_trail, last=2, after=0), content="�")
  let lone_lead = string_of_code_units(['a'.to_int(), 0xD800, '*'.to_int()])
  inspect(@char.prev_char(lone_lead, first=0, before=2), content="�")
  inspect(@char.next_char(lone_lead, last=2, after=0), content="�")
}

///|
test "prev_char and next_char out-of-range arguments" {
  inspect(@char.prev_char("ab", first=0, before=99), content=" ")
  inspect(@char.prev_char("ab", first=-5, before=0), content=" ")
  inspect(@char.next_char("ab", last=99, after=10), content=" ")
}

///|
test "at_checked out of bounds and unpaired surrogates" {
  debug_inspect(@char.at_checked("a", 5), content="Err(0)")
  debug_inspect(@char.at_checked("a", -1), content="Err(0)")
  // A leading surrogate must be followed by a trailing surrogate.
  let lead_then_ascii = string_of_code_units([0xD800, 'a'.to_int()])
  debug_inspect(@char.at_checked(lead_then_ascii, 0), content="Err(55296)")
}

///|
test "utf_16_sanitize" {
  // Well-formed strings are returned as-is.
  inspect(@char.utf_16_sanitize("hello 😀 world"), content="hello 😀 world")
  inspect(@char.utf_16_sanitize(""), content="")
  // Unpaired surrogates are replaced unit-for-unit.
  let dirty = string_of_code_units(['a'.to_int(), 0xDC00, 0xD800, 'b'.to_int()])
  inspect(@char.utf_16_sanitize(dirty), content="a��b")
  inspect(@char.utf_16_sanitize(dirty).length(), content="4")
  // A valid pair straddling unpaired units survives.
  let mixed = string_of_code_units([0xDC00, 0xD83D, 0xDE00, 0xD800])
  inspect(@char.utf_16_sanitize(mixed), content="�😀�")
}

///|
test "utf_16_clean_raw with unpaired surrogates" {
  let buf = StringBuilder::new()
  let lone = string_of_code_units([0xDC00])
  inspect(@char.utf_16_clean_raw(buf, lone, first=0, last=0), content="�")
  let mixed = string_of_code_units(['a'.to_int(), 0xDC00, 'b'.to_int()])
  inspect(@char.utf_16_clean_raw(buf, mixed, first=0, last=2), content="a�b")
  // A span that cuts a surrogate pair in half.
  let emoji = "😀"
  inspect(@char.utf_16_clean_raw(buf, emoji, first=0, last=0), content="�")
  // A clean span followed by an unpaired trailing surrogate: the span
  // boundary must not abort.
  let clean_then_trail = string_of_code_units(['a'.to_int(), 0xDC00])
  inspect(
    @char.utf_16_clean_raw(buf, clean_then_trail, first=0, last=0),
    content="a",
  )
}

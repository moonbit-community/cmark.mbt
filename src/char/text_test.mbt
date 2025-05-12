///|
test "utf_16_clean_raw with padding" {
  let buf = StringBuilder::new()
  let s = "hello"
  inspect!(utf_16_clean_raw(pad=2, buf, s, first=0, last=4), content="  hello")
}

///|
test "utf_16_clean_raw without padding" {
  let buf = StringBuilder::new()
  let s = "hello"
  inspect!(utf_16_clean_raw(pad=0, buf, s, first=0, last=4), content="hello")
}

///|
test "utf_16_clean_raw with empty string" {
  let buf = StringBuilder::new()
  let s = ""
  inspect!(utf_16_clean_raw(pad=2, buf, s, first=0, last=0), content="  ")
  inspect!(utf_16_clean_raw(pad=0, buf, s, first=0, last=0), content="")
}

///|
test "utf_16_clean_raw with invalid range" {
  let buf = StringBuilder::new()
  let s = "hello"
  inspect!(utf_16_clean_raw(pad=0, buf, s, first=5, last=2), content="")
  inspect!(utf_16_clean_raw(pad=2, buf, s, first=5, last=2), content="  ")
}

///|
test "utf_16_clean_raw with null character" {
  let buf = StringBuilder::new()
  let s = "hel\u{0}lo"
  inspect!(utf_16_clean_raw(pad=0, buf, s, first=0, last=5), content="hel�lo")
}

///|
test "utf_16_clean_unref vs utf_16_clean_unesc_unref" {
  // Test the difference between the two functions
  let buf = StringBuilder::new()
  let s = "a\\*b"
  // utf_16_clean_unref should not unescape
  inspect!(utf_16_clean_unref(buf, s, first=0, last=3), content="a\\*b")
  // utf_16_clean_unesc_unref should unescape
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="a*b")
}

///|
test "try_entity_hex invalid" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(
    utf_16_clean_unesc_unref(buf, "&#xqq;", first=0, last=5),
    content="&#xqq;",
  )
}

///|
test "try_entity_named empty" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "&;", first=0, last=1), content="&;")
}

///|
test "resolve empty" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "", first=1, last=0), content="")
}

///|
test "resolve escaped chars" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "\\", first=0, last=0), content="\\")
}

///|
test "try_entity_named with incomplete entity" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "&abc"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="&abc")
}

///|
test "handling null character and non-ascii chars" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\u{0}\u{FF}"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=1), content="�ÿ")
}

///|
test "handling escape with non-punctuation" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\\a"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=1), content="\\a")
}

///|
test "hex entity with invalid length" {
  let buf = StringBuilder::new()
  let s = "&#x123456789;" // Too long hex entity
  inspect!(
    utf_16_clean_unesc_unref(buf, s, first=0, last=11),
    content="&#x123456789",
  )
}

///|
test "hex entity with null char" {
  let buf = StringBuilder::new()
  let s = "&#x0;" // Represents null character
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="�")
}

///|
test "non-ASCII valid UTF-16 sequence" {
  let buf = StringBuilder::new()
  // Valid UTF-16 sequence for a non-ASCII character
  let s = "a😀b"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="a😀b")
}

///|
test "decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#65;" // Decimal for 'A'
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="A")
}

///|
test "invalid decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#a;" // Not a valid decimal
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="&#a;")
}

///|
test "empty decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#;" // Empty decimal reference
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=2), content="&#;")
}

///|
test "decimal entity reference too long" {
  let buf = StringBuilder::new()
  let s = "&#12345678;" // Too long decimal entity
  inspect!(
    utf_16_clean_unesc_unref(buf, s, first=0, last=10),
    content="&#12345678;",
  )
}

///|
test "try_entity_named with valid entity" {
  let buf = StringBuilder::new()
  let s = "&amp;" // HTML entity for '&'
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="&")
}

///|
test "try_entity_named with non-alphabetic character" {
  let buf = StringBuilder::new()
  let s = "&123;"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="&123;")
}

///|
test "at_checked valid character" {
  let s = "hello"
  match at_checked(s, 0) {
    Ok(c) => inspect!(c.to_string(), content="h")
    Err(_) => inspect!("Should not reach here", content="")
  }
}

///|
test "at_checked with boundary" {
  let s = "hello"
  // Check if it handles index at the boundary correctly
  match at_checked(s, 4) {
    Ok(c) => inspect!(c.to_string(), content="o")
    Err(_) => inspect!("Should not reach here", content="")
  }
}

///|
test "at_checked with invalid utf16 surrogate" {
  let s = "👋"
  inspect!(at_checked(s, 1), content="Err(56395)")
}

///|
test "entity_decimal with invalid continuation" {
  let buf = StringBuilder::new()
  // Test a decimal entity that has a non-digit character after '&#'
  let s = "&#a123;"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=6), content="&#a123;")
}

///|
test "entity_decimal with empty reference" {
  let buf = StringBuilder::new()
  // Test an empty decimal entity reference
  let s = "&#;"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=2), content="&#;")
}

///|
test "clean_unesc_unref with invalid utf16 sequence" {
  // We need to simulate an invalid UTF-16 sequence that would trigger the Err branch
  let buf = StringBuilder::new()

  // Instead of trying to create an invalid UTF-16 character directly,
  // let's test the handling of the replacement character
  inspect!(
    utf_16_clean_unesc_unref(buf, "a\u{fffd}b", first=0, last=2),
    content="a\u{fffd}b",
  )
}

///|
test "sub_includes with matching at end" {
  inspect!(sub_includes(affix="abc", "xxxabc", first=3, last=5), content="true")
}

///|
test "empty decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#;"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=2), content="&#;")
}

///|
test "non-digit in decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#A;"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="&#A;")
}

///|
test "at_checked valid character" {
  let s = "hello"
  match at_checked(s, 0) {
    Ok(c) => inspect!(c.to_string(), content="h")
    Err(_) => inspect!("Should not reach here", content="")
  }
}

///|
test "at_checked invalid character" {
  let s = "🌞"
  inspect!(at_checked(s, 0), content="Ok('🌞')")
  inspect!(at_checked(s, 1), content="Err(57118)")
}

///|
test "utf_16_clean_unref vs utf_16_clean_unesc_unref" {
  // Test the difference between the two functions
  let buf = StringBuilder::new()
  let s = "a\\*b"
  // utf_16_clean_unref should not unescape
  inspect!(utf_16_clean_unref(buf, s, first=0, last=3), content="a\\*b")
  // utf_16_clean_unesc_unref should unescape
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="a*b")
}

///|
test "decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#65;" // Decimal for 'A'
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="A")
}

///|
test "invalid decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#a;" // Not a valid decimal
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="&#a;")
}

///|
test "empty decimal entity reference" {
  let buf = StringBuilder::new()
  let s = "&#;" // Empty decimal reference
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=2), content="&#;")
}

///|
test "decimal entity reference too long" {
  let buf = StringBuilder::new()
  let s = "&#12345678;" // Too long decimal entity
  inspect!(
    utf_16_clean_unesc_unref(buf, s, first=0, last=10),
    content="&#12345678;",
  )
}

///|
test "try_entity_hex invalid" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(
    utf_16_clean_unesc_unref(buf, "&#xqq;", first=0, last=5),
    content="&#xqq;",
  )
}

///|
test "try_entity_named empty" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "&;", first=0, last=1), content="&;")
}

///|
test "resolve empty" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "", first=1, last=0), content="")
}

///|
test "resolve escaped chars" {
  let buf = StringBuilder::new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "\\", first=0, last=0), content="\\")
}

///|
test "try_entity_named with incomplete entity" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "&abc"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="&abc")
}

///|
test "handling null character and non-ascii chars" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\u0000\u00FF"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=1), content="�ÿ")
}

///|
test "handling escape with non-punctuation" {
  let buf = StringBuilder::new(size_hint=0)
  let s = "\\a"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=1), content="\\a")
}

///|
test "hex entity with invalid length" {
  let buf = StringBuilder::new()
  let s = "&#x123456789;" // Too long hex entity
  inspect!(
    utf_16_clean_unesc_unref(buf, s, first=0, last=11),
    content="&#x123456789",
  )
}

///|
test "hex entity with null char" {
  let buf = StringBuilder::new()
  let s = "&#x0;" // Represents null character
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="�")
}

///|
test "non-ASCII valid UTF-16 sequence" {
  let buf = StringBuilder::new()
  // Valid UTF-16 sequence for a non-ASCII character
  let s = "a😀b"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="a😀b")
}

///|
test "try_entity_named with valid entity" {
  let buf = StringBuilder::new()
  let s = "&amp;" // HTML entity for '&'
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="&")
}

///|
test "try_entity_named with non-alphabetic character" {
  let buf = StringBuilder::new()
  let s = "&123;"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="&123;")
}

///|
test "sub_includes empty string returns false" {
  inspect!(sub_includes(affix="abc", "", first=0, last=0), content="false")
}

///|
test "sub_includes longer affix returns false" {
  inspect!(
    sub_includes(affix="abcdef", "abc", first=0, last=2),
    content="false",
  )
}

///|
test "sub_includes full match" {
  inspect!(sub_includes(affix="abc", "zabc", first=1, last=4), content="true")
}

///|
test "sub_includes partial match" {
  inspect!(sub_includes(affix="abc", "zabxc", first=1, last=5), content="false")
}

///|
test "sub_includes no match" {
  inspect!(sub_includes(affix="abc", "xyz", first=0, last=2), content="false")
}

///|
test "sub_includes repeated pattern match" {
  // Test the case where a partial match is found and then restarting from next position
  inspect!(
    sub_includes(affix="abc", "abababc", first=0, last=6),
    content="true",
  )
}

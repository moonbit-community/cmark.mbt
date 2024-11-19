test "utf_16_clean_raw with padding" {
  let buf = @buffer.new()
  let s = "hello"
  inspect!(utf_16_clean_raw(pad=2, buf, s, first=0, last=4), content="  hello")
}

test "try_entity_hex invalid" {
  let buf = @buffer.new(size_hint=0)
  inspect!(
    utf_16_clean_unesc_unref(buf, "&#xqq;", first=0, last=5),
    content="&#xqq;",
  )
}

test "try_entity_named empty" {
  let buf = @buffer.new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "&;", first=0, last=1), content="&;")
}

test "resolve empty" {
  let buf = @buffer.new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "", first=1, last=0), content="")
}

test "resolve escaped chars" {
  let buf = @buffer.new(size_hint=0)
  inspect!(utf_16_clean_unesc_unref(buf, "\\", first=0, last=0), content="\\")
}

test "try_entity_named with incomplete entity" {
  let buf = @buffer.new(size_hint=0)
  let s = "&abc"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="&abc")
}

test "handling null character and non-ascii chars" {
  let buf = @buffer.new(size_hint=0)
  let s = "\x00\xFF"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=1), content="�\xFF")
}

test "handling escape with non-punctuation" {
  let buf = @buffer.new(size_hint=0)
  let s = "\\a"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=1), content="\\a")
}

test "hex entity with invalid length" {
  let buf = @buffer.new()
  let s = "&#x123456789;" // Too long hex entity
  inspect!(
    utf_16_clean_unesc_unref(buf, s, first=0, last=11),
    content="&#x123456789",
  )
}

test "hex entity with null char" {
  let buf = @buffer.new()
  let s = "&#x0;" // Represents null character
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=4), content="�")
}

test "non-ASCII valid UTF-16 sequence" {
  let buf = @buffer.new()
  // Valid UTF-16 sequence for a non-ASCII character
  let s = "a😀b"
  inspect!(utf_16_clean_unesc_unref(buf, s, first=0, last=3), content="a😀b")
}

test "sub_includes empty string returns false" {
  inspect!(sub_includes(affix="abc", "", first=0, last=0), content="false")
}

test "sub_includes longer affix returns false" {
  inspect!(
    sub_includes(affix="abcdef", "abc", first=0, last=2),
    content="false",
  )
}

test "sub_includes full match" {
  inspect!(sub_includes(affix="abc", "zabc", first=1, last=4), content="true")
}

test "sub_includes partial match" {
  inspect!(sub_includes(affix="abc", "zabxc", first=1, last=5), content="false")
}

test "sub_includes no match" {
  inspect!(sub_includes(affix="abc", "xyz", first=0, last=2), content="false")
}

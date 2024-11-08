test "sub_includes with affix longer than string" {
  inspect!(
    @char.sub_includes("abc", affix="abcd", first=0, last=2),
    content="false",
  )
}

test "sub_includes with no match" {
  inspect!(
    @char.sub_includes("abcd", affix="xyz", first=0, last=3),
    content="false",
  )
}

test "sub_includes with full match" {
  inspect!(
    @char.sub_includes("abc", affix="abc", first=0, last=2),
    content="true",
  )
}

test "sub_includes with partial match" {
  inspect!(
    @char.sub_includes("abc", affix="bc", first=0, last=2),
    content="true",
  )
}

test "sub_includes with multi-character match" {
  inspect!(
    @char.sub_includes("abcdefg", affix="def", first=0, last=6),
    content="true",
  )
}

test "utf_16_clean_raw with padding" {
  let buf = @buffer.new(size_hint=0)
  inspect!(
    @char.utf_16_clean_raw(pad=3, buf, "abc", first=0, last=2),
    content="   abc",
  )
}

test "utf_16_clean_raw with null char" {
  let buf = @buffer.new(size_hint=0)
  inspect!(
    @char.utf_16_clean_raw(buf, "a\x00b", first=0, last=2),
    content="a�b",
  )
}

test "utf_16_clean_raw with valid UTF-16" {
  let buf = @buffer.new(size_hint=0)
  inspect!(
    @char.utf_16_clean_raw(buf, "hello 世界", first=0, last=7),
    content="hello 世界",
  )
}

test "sub_includes mismatch after partial match" {
  // Test case where there's a partial match but then a mismatch
  // "abc" should not be found in "abdc" when looking at chars from index 0 to 3
  let result = @char.sub_includes(affix="abc", "abdc", first=0, last=3)
  inspect!(result, content="false")
}

test "utf_16_clean_unesc_handles_hexadecimal_entities" {
  let buf = @buffer.new()
  // Test invalid hex entity (k > last)
  inspect!(
    @char.utf_16_clean_unesc_unref(buf, "&#x123", first=0, last=5),
    content="&#x123",
  )
  // Test invalid hex digit
  inspect!(
    @char.utf_16_clean_unesc_unref(buf, "&#xG;", first=0, last=4),
    content="&#xG;",
  )
  // Test null character hex entity
  inspect!(
    @char.utf_16_clean_unesc_unref(buf, "&#x0;", first=0, last=4),
    content="�",
  )
}

test "utf_16_clean_unesc_unref handles named entities and escapes" {
  let buf = @buffer.new()
  // Test incomplete entity
  inspect!(
    @char.utf_16_clean_unesc_unref(buf, "&abc", first=0, last=3),
    content="&abc",
  )
  // Test backslash at end
  inspect!(
    @char.utf_16_clean_unesc_unref(buf, "\\", first=0, last=0),
    content="\\",
  )
  // Test non-punctuation after backslash
  inspect!(
    @char.utf_16_clean_unesc_unref(buf, "\\a", first=0, last=1),
    content="\\a",
  )
}

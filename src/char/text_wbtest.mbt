test "utf_16_clean_raw with padding" {
  let buf = Buffer::new()
  let s = "hello"
  inspect!(utf_16_clean_raw(pad=2, buf, s, first=0, last=4), content="  hello")
}

test "utf_16_clean_raw with null characters" {
  let buf = Buffer::new()
  let s = "he\x00llo"
  inspect!(utf_16_clean_raw(buf, s, first=0, last=5), content="he�llo")
}

test "sub_includes first match" {
  inspect!(sub_includes("hello", affix="he", first=0, last=4), content="true")
}

test "sub_includes no match" {
  inspect!(sub_includes("hello", affix="xyz", first=0, last=4), content="false")
}

test "sub_includes partial match" {
  inspect!(sub_includes("help", affix="hel", first=0, last=3), content="true")
}

test "hex entity reference with large number" {
  let buf = Buffer::new(size_hint=0)
  inspect!(
    _utf_16_clean_unesc_unref(
      buf,
      "&#x1234567;",
      do_unesc=true,
      first=0,
      last=10,
    ),
    content="&#x1234567;",
  )
}

test "decimal entity with invalid digits" {
  let buf = Buffer::new()
  let s = "&#;"
  inspect!(
    _utf_16_clean_unesc_unref(buf, s, do_unesc=true, first=0, last=2),
    content="&#;",
  )
}

test "sub_includes when partial match then mismatch" {
  inspect!(sub_includes("abxabc", affix="abc", first=0, last=5), content="true")
}

test "sub_includes with affix longer than string" {
  // Tests line 22 where affix length > string length
  inspect!(
    sub_includes("hello", affix="hello world", first=0, last=4),
    content="false",
  )
}

test "named entity tests" {
  let buf = Buffer::new()
  let s = "&amp;test"
  inspect!(
    _utf_16_clean_unesc_unref(buf, s, do_unesc=false, first=0, last=8),
    content="&amp;test",
  )
}

test "utf_16_clean_raw with clean function handling valid unicode" {
  let buf : Buffer = Buffer::new(size_hint=10)
  let s = "你好" // Valid UTF-16 CJK string
  let result = utf_16_clean_raw(buf, s, first=0, last=1)
  inspect!(result, content="你好")
}

test "utf_16_clean_raw with check function handling valid unicode" {
  let buf = Buffer::new(size_hint=10)
  let s = "안녕" // Valid UTF-16 Korean characters  
  let result = utf_16_clean_raw(buf, s, first=0, last=1)
  inspect!(result, content="안녕")
}

test "hex entity with semicolon" {
  let buf = Buffer::new()
  let s = "&#x41;"
  inspect!(
    _utf_16_clean_unesc_unref(do_unesc=true, buf, s, first=0, last=5),
    content="A",
  )
}

test "invalid entity" {
  let buf = Buffer::new()
  let s = "&xyz"
  inspect!(
    _utf_16_clean_unesc_unref(do_unesc=true, buf, s, first=0, last=3),
    content="&xyz",
  )
}

test "empty input" {
  let buf = Buffer::new()
  inspect!(
    _utf_16_clean_unesc_unref(do_unesc=true, buf, "", first=1, last=0),
    content="",
  )
}

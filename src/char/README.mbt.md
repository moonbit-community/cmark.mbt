# `char`

A package providing helper functions for working with Chars, with a focus on ASCII and Unicode operations.

## ASCII Character Classification

Test if a character belongs to certain ASCII categories:

```moonbit
test "ascii classification" {
  inspect!(@char.is_ascii_whitespace(' '), content="true")
  inspect!(@char.is_ascii_punctuation('.'), content="true")
  inspect!(@char.is_ascii_control('\u{0}'), content="true")
}
```

## ASCII Character Conversion

Convert between ASCII cases and get numeric values from ASCII digits:

```moonbit
test "ascii conversion" {
  // Case conversion
  inspect!(@char.to_ascii_upper('a'), content="A")
  inspect!(@char.to_ascii_lower('Z'), content="z")

  // Numeric conversion
  inspect!(@char.ascii_digit_to_int('5'), content="5")
  inspect!(@char.ascii_hexdigit_to_int('A'), content="10")
  inspect!(@char.ascii_octdigit_to_int('7'), content="7")
}
```

## String Character Access

Safe and checked ways to access characters in a string:

```moonbit
test "string char access" {
  let s = "Hello, 🐰"

  // Safe checked access
  inspect!(@char.at_checked(s, 0), content="Ok('H')")
  inspect!(@char.at_checked(s, 7), content="Ok('🐰')")
}
```

## String Navigation

Navigate through characters in a string:

```moonbit
test "string navigation" {
  let s = "Hello, 世界"

  // Navigate to next character
  inspect!(@char.next_char(s, last=0, after=7), content=" ")

  // Navigate to previous character
  inspect!(@char.prev_char(s, first=7, before=9), content="世")
}
```

## Unicode Properties

Query Unicode properties of characters:

```moonbit
test "unicode properties" {
  // UTF encoding lengths
  let c = '🐰'.to_int()
  inspect!(@char.length_utf8(c), content="4")
  inspect!(@char.length_utf16(c), content="2")
  inspect!(@char.length_utf32(c), content="1")
}
```

## String Processing

Utilities for string manipulation and character handling:

```moonbit
test "string processing" {
  // Substring inclusion check
  let text = "Hello, World!"
  inspect!(
    @char.sub_includes(affix="World", text, first=0, last=13),
    content="true",
  )

  // UTF-16 cleaning (handles invalid sequences)
  let s = "&#xcab;&#XD800;"
  let buf = StringBuilder::new()
  let cleaned = @char.utf_16_clean_unref(
    buf,
    s,
    first=0,
    last=6,
  )
  inspect!(
    cleaned,
    content=
      "ಫ"
    ,
  )
  let cleaned = @char.utf_16_clean_unref(
    buf,
    s,
    first=7,
    last=14,
  )
  inspect!(
    cleaned,
    content=
      "�"
    ,
  )
}
```

## Character Conversion

Converting between integers and characters:

```moonbit
test "char conversion" {
  // Converting integer to character safely
  inspect!(@char.from_int_checked(65), content="Some('A')")
  inspect!(@char.from_int_checked(-1), content="None")
}
```

Note: This package provides essential functionality for character handling in text processing applications, especially those dealing with ASCII and Unicode text. It offers safe ways to inspect and manipulate characters while handling edge cases appropriately.

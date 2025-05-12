///|
pub let rep : Char = '\u{fffd}'

// https://github.com/lynzrand/aestus/blob/3ab6ecf64fc34914277129e8429d0a7c003cc80f/encoding/rune.mbt#L1-L27

///|
pub fn length_utf8(ch : Int) -> Int {
  if ch < 0x80 {
    1
  } else if ch < 0x800 {
    2
  } else if ch < 0x10000 {
    3
  } else if ch < 0x110000 {
    4
  } else {
    abort("invalid rune")
  }
}

///|
pub fn length_utf16(ch : Int) -> Int {
  if ch < 0x10000 {
    1
  } else {
    2
  }
}

///|
pub fn length_utf32(_ch : Int) -> Int {
  1
}

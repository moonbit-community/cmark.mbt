///|
fn min_by_key[T, K : Compare](a : T, b : T, key : (T) -> K) -> T {
  if key(a) <= key(b) {
    a
  } else {
    b
  }
}

///|
fn max_by_key[T, K : Compare](a : T, b : T, key : (T) -> K) -> T {
  if key(a) > key(b) {
    a
  } else {
    b
  }
}

///|
fn char_is_atext_plus_dot(c : Char) -> Bool {
  @char.is_ascii_alphanum(c) || "!#$%&\\*+-/=?^_`{|}~.".contains_char(c)
}

// /// @alert deprecated "`dbg()` should not be used in production"
// fn dbg[T : Show](t : T, prefix~ : String = "", loc~ : SourceLoc = _) -> T {
//   println("DBG: \{loc}: \{prefix}\{t}")
//   t
// }

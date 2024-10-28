/// @alert deprecated "`dbg()` should not be used in production"
fn dbg[T : Show](t : T, ~prefix : String = "", ~loc : SourceLoc = _) -> T {
  println("DBG: \{loc}: \{prefix}\{t}")
  t
}

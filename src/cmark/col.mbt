///|
typealias Int as Col

///|
#coverage.skip
fn next_tab_stop(col : Col) -> Col {
  (col + 4) & (3).lnot()
}

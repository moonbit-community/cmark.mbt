///| Closer indexes.
///
/// They map closing delimiters to the position where they
/// start. Shortcuts forward searches in inline parsing. See
/// `inline_struct`
enum Closer {
  /// Run length of backticks.
  Backticks(Int)
  RightBrack
  RightParen
  EmphasisMarks(Char)
  StrikethroughMarks
  MathSpanMarks(Int)
} derive(Eq, Compare, Hash, Show, ToJson)

///|
typealias PosSet = @immut/sorted_set.T[Int]

///|
type CloserIndex @immut/sorted_map.T[Closer, PosSet] derive(Show, ToJson)

///|
fn CloserIndex::new() -> CloserIndex {
  @immut/sorted_map.empty()
}

///|
fn CloserIndex::add(self : CloserIndex, key : Closer, pos : Int) -> CloserIndex {
  let value = self._[key].map_or_else(fn() { PosSet::new().add(pos) }, fn(
    occs
  ) {
    occs.add(pos)
  })
  self._.add(key, value)
}

///|
fn CloserIndex::pos(self : CloserIndex, key : Closer, after~ : Int) -> Int? {
  self._[key].bind(fn(s) { s.iter().find_first(fn(pos) { pos > after }) })
}

///|
fn CloserIndex::exists(self : CloserIndex, key : Closer, after~ : Int) -> Bool {
  self.pos(key, after~).is_empty().not()
}

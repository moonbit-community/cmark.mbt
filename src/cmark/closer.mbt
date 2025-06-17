///| Closer indexes.
///
/// They map closing delimiters to the position where they
/// start. Shortcuts forward searches in inline parsing. See
/// `inline_struct`
priv enum Closer {
  /// Run length of backticks.
  Backticks(Int)
  RightBrack
  RightParen
  EmphasisMarks(Char)
  StrikethroughMarks
  MathSpanMarks(Int)
} derive(Eq, Compare, Hash, Show, ToJson)

///|
typealias Set[Int] as PosSet

///|
priv type CloserIndex Map[Closer, PosSet] derive(Show, ToJson)

///|
fn CloserIndex::new() -> CloserIndex {
  Map::new()
}

///|
fn CloserIndex::add(self : CloserIndex, key : Closer, pos : Int) -> Unit {
  (match self.inner().get(key) {
    Some(ps) => ps
    None => {
      let ps = PosSet::new()
      self.inner()[key] = ps
      ps
    }
  }).add(pos)
}

///|
fn CloserIndex::pos(self : CloserIndex, key : Closer, after~ : Int) -> Int? {
  self
  .inner()
  .get(key)
  .bind(fn(s) { s.iter().find_first(fn(pos) { pos > after }) })
}

///|
fn CloserIndex::exists(self : CloserIndex, key : Closer, after~ : Int) -> Bool {
  not(self.pos(key, after~).is_empty())
}

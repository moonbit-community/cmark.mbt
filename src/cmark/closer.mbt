///|
/// Closer indexes.
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
} derive(Eq, Hash, Debug)

///|
type PosSet = Set[Int]

///|
priv struct CloserIndex(Map[Closer, PosSet]) derive(Debug)

///|
test {
  // Prevent warning about unused Debug.
  (fn(c : CloserIndex) { @debug.to_string(c) }) |> ignore()
}

///|
fn CloserIndex::new() -> CloserIndex {
  Map::new()
}

///|
fn CloserIndex::add(self : CloserIndex, key : Closer, pos : Int) -> Unit {
  (match self.0.get(key) {
    Some(ps) => ps
    None => {
      let ps = PosSet::new()
      self.0[key] = ps
      ps
    }
  }).add(pos)
}

///|
fn CloserIndex::pos(self : CloserIndex, key : Closer, after~ : Int) -> Int? {
  self.0.get(key).bind(fn(s) { s.iter().find_first(fn(pos) { pos > after }) })
}

///|
fn CloserIndex::exists(self : CloserIndex, key : Closer, after~ : Int) -> Bool {
  !(self.pos(key, after~) is None)
}

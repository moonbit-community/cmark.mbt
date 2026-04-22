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
} derive(Eq, Hash, ToJson)

///|
impl Show for Closer with output(self, logger) {
  match self {
    Backticks(n) => {
      logger.write_string("Backticks(")
      logger.write_object(n)
      logger.write_string(")")
    }
    RightBrack => logger.write_string("RightBrack")
    RightParen => logger.write_string("RightParen")
    EmphasisMarks(c) => {
      logger.write_string("EmphasisMarks(")
      logger.write_object(c)
      logger.write_string(")")
    }
    StrikethroughMarks => logger.write_string("StrikethroughMarks")
    MathSpanMarks(n) => {
      logger.write_string("MathSpanMarks(")
      logger.write_object(n)
      logger.write_string(")")
    }
  }
}

///|
test {
  // Prevent warning about unused Show and ToJson
  (fn(c : Closer) { c.to_string() }) |> ignore()
  (fn(c : Closer) { c.to_json() }) |> ignore()
}

///|
type PosSet = Set[Int]

///|
priv struct CloserIndex(Map[Closer, PosSet]) derive(ToJson)

///|
test {
  // Prevent warning about unused ToJson
  (fn(c : CloserIndex) { c.to_json() }) |> ignore()
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

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
} derive(Eq, Hash, Debug, ToJson)

///|
// Manual Show impl bridges Closer's Debug output through Map's ToJson,
// which requires Show on the key type.
impl Show for Closer with output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
test {
  // Prevent warning about unused Debug and ToJson
  (fn(c : Closer) { @debug.to_string(c) }) |> ignore()
  (fn(c : Closer) { c.to_json() }) |> ignore()
}

///|
type PosSet = Set[Int]

///|
priv struct CloserIndex(Map[Closer, PosSet]) derive(ToJson)

///|
// Set[Int] does not implement Debug yet; manually walk the Map.
impl @debug.Debug for CloserIndex with to_repr(self) {
  let entries = self.0
    .iter()
    .map(fn(kv) {
      let (k, v) = kv
      (@debug.to_repr(k), @debug.to_repr(v.iter().to_array()))
    })
    .to_array()
  @debug.Repr::map(entries)
}

///|
test {
  // Prevent warning about unused Debug and ToJson
  (fn(c : CloserIndex) { @debug.to_string(c) }) |> ignore()
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

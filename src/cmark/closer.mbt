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
type Positions = Array[Int]

///|
priv struct CloserIndex(Map[Closer, Positions]) derive(Debug)

///|
test {
  // Prevent warning about unused Debug.
  (fn(c : CloserIndex) { @debug.to_string(c) }) |> ignore()
}

///|
fn CloserIndex::new() -> CloserIndex {
  Map([])
}

///|
fn CloserIndex::add(self : CloserIndex, key : Closer, pos : Int) -> Unit {
  (match self.0.get(key) {
    Some(ps) => ps
    None => {
      let ps = []
      self.0[key] = ps
      ps
    }
  }).push(pos)
}

///|
fn CloserIndex::pos(self : CloserIndex, key : Closer, after~ : Int) -> Int? {
  guard self.0.get(key) is Some(positions) else { return None }
  let len = positions.length()
  let first = for lo = 0, hi = len {
    if lo >= hi {
      break lo
    }
    let mid = (lo + hi) / 2
    if positions[mid] <= after {
      continue mid + 1, hi
    }
    continue lo, mid
  }
  if first < len {
    Some(positions[first])
  } else {
    None
  }
}

///|
fn CloserIndex::exists(self : CloserIndex, key : Closer, after~ : Int) -> Bool {
  !(self.pos(key, after~) is None)
}

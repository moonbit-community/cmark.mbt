///|
type Seq[A] Array[A] derive(Eq, Show)

///|
pub impl[A : ToJson] ToJson for Seq[A] with to_json(self) -> Json {
  self.inner().to_json()
}

///|
/// @coverage.skip
pub fn[A] Seq::empty() -> Seq[A] {
  []
}

///|
/// @coverage.skip
pub fn[A] Seq::from_iter(iter : Iter[A]) -> Seq[A] {
  Array::from_iter(iter)
}

///|
/// @coverage.skip
pub fn[A] Seq::from_array(arr : Array[A]) -> Seq[A] {
  arr
}

///|
/// @coverage.skip
pub fn[A] Seq::to_array(self : Seq[A]) -> Array[A] {
  self.inner()
}

///|
/// @coverage.skip
pub fn[A] Seq::iter(self : Seq[A]) -> Iter[A] {
  self.inner().iter()
}

///|
/// @coverage.skip
pub fn[A] Seq::length(self : Seq[A]) -> Int {
  self.inner().length()
}

///|
/// @coverage.skip
pub fn[A, B] Seq::map(self : Seq[A], f : (A) -> B) -> Seq[B] {
  self.inner().map(f)
}

///|
/// @coverage.skip
pub fn[A, B] Seq::fold(self : Seq[A], init~ : B, f : (B, A) -> B) -> B {
  self.inner().fold(init~, f)
}

///|
/// @coverage.skip
pub fn[A, B] Seq::rev_fold(self : Seq[A], init~ : B, f : (B, A) -> B) -> B {
  self.inner().rev_fold(init~, f)
}

///|
/// @coverage.skip
pub fn[A] Seq::get(self : Seq[A], idx : Int) -> A? {
  self.inner().get(idx)
}

///|
/// @coverage.skip
pub fn[A] Seq::op_get(self : Seq[A], idx : Int) -> A {
  self.inner()[idx]
}

///|
/// @coverage.skip
pub fn[A] Seq::op_set(self : Seq[A], idx : Int, val : A) -> Unit {
  self.inner()[idx] = val
}

///|
/// @coverage.skip
pub fn[A] Seq::is_empty(self : Seq[A]) -> Bool {
  self.inner().is_empty()
}

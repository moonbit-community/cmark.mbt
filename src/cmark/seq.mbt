///|
type Seq[A] Array[A] derive(Eq, Show)

///|
pub impl[A : ToJson] ToJson for Seq[A] with to_json(self) -> Json {
  self._.to_json()
}

///|
/// @coverage.skip
pub fn Seq::empty[A]() -> Seq[A] {
  []
}

///|
/// @coverage.skip
pub fn Seq::from_iter[A](iter : Iter[A]) -> Seq[A] {
  Array::from_iter(iter)
}

///|
/// @coverage.skip
pub fn Seq::from_array[A](arr : Array[A]) -> Seq[A] {
  arr
}

///|
/// @coverage.skip
pub fn Seq::to_array[A](self : Seq[A]) -> Array[A] {
  self._
}

///|
/// @coverage.skip
pub fn Seq::iter[A](self : Seq[A]) -> Iter[A] {
  self._.iter()
}

///|
/// @coverage.skip
pub fn Seq::length[A](self : Seq[A]) -> Int {
  self._.length()
}

///|
/// @coverage.skip
pub fn Seq::map[A, B](self : Seq[A], f : (A) -> B) -> Seq[B] {
  self._.map(f)
}

///|
/// @coverage.skip
pub fn Seq::fold[A, B](self : Seq[A], init~ : B, f : (B, A) -> B) -> B {
  self._.fold(init~, f)
}

///|
/// @coverage.skip
pub fn Seq::rev_fold[A, B](self : Seq[A], init~ : B, f : (B, A) -> B) -> B {
  self._.rev_fold(init~, f)
}

///|
/// @coverage.skip
pub fn Seq::get[A](self : Seq[A], idx : Int) -> A? {
  self._.get(idx)
}

///|
/// @coverage.skip
pub fn Seq::op_get[A](self : Seq[A], idx : Int) -> A {
  self._[idx]
}

///|
/// @coverage.skip
pub fn Seq::op_set[A](self : Seq[A], idx : Int, val : A) -> Unit {
  self._[idx] = val
}

///|
/// @coverage.skip
pub fn Seq::is_empty[A](self : Seq[A]) -> Bool {
  self._.is_empty()
}

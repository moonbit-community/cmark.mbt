///|
pub(all) struct Meta {
  id : MetaId
  loc : TextLoc
  extra : Error?
}

///|
type MetaId = Int

///|
let curr_id : Ref[MetaId] = Ref::new(0)

///|
pub fn Meta::new(loc? : TextLoc = text_loc_none) -> Meta {
  let res = { loc, id: curr_id.val, extra: None }
  curr_id.val += 1
  res
}

///|
let meta_none : Meta = Meta::new()

///|
pub fn Meta::none() -> Meta {
  meta_none
}

///|
pub impl Eq for Meta with equal(self, other) {
  self.id == other.id
}

///|
pub fn Meta::compare(self : Meta, other : Meta) -> Int {
  self.id.compare(other.id)
}

///|
pub fn Meta::is_none(self : Meta) -> Bool {
  self == meta_none
}

///|
pub impl @debug.Debug for Meta with to_repr(self) {
  if self.is_none() {
    @debug.Repr::ctor("Meta::none", [])
  } else {
    @debug.Repr::ctor("Meta::new", [
      (Some("id"), @debug.to_repr(self.id)),
      (Some("loc"), @debug.to_repr(self.loc)),
      (Some("dict"), @debug.to_repr(self.extra.map(fn(e) { e.to_string() }))),
    ])
  }
}

///|
pub impl ToJson for Meta with to_json(self) {
  if self.is_none() {
    return {}
  }
  let extra = match self.extra {
    None => "None"
    Some(e) => "Some(\{e})"
  }
  {
    "id": self.id.to_json(),
    "loc": self.loc.to_json(),
    "dict": extra.to_json(),
  }
}

///|
pub fn Meta::to_json(self : Meta) -> Json {
  ToJson::to_json(self)
}

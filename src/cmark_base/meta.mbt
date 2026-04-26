///|
pub(all) struct Meta {
  id : MetaId
  loc : TextLoc
  extra : Error?
} derive(Debug)

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

///|
pub(all) struct Meta {
  id : MetaId
  loc : TextLoc
  extra : Error?
}

///|
typealias MetaId = Int

///|
let curr_id : Ref[MetaId] = Ref::new(0)

///|
pub fn Meta::new(loc~ : TextLoc = text_loc_none) -> Meta {
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
pub impl Eq for Meta with op_equal(self, other) {
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
pub impl Show for Meta with output(self, logger) {
  if self.is_none() {
    logger.write_string("Meta::none()")
  } else {
    logger.write_string("Meta::new(id=")
    logger.write_object(self.id)
    logger.write_string(", loc=")
    logger.write_object(self.loc)
    logger.write_string(", dict=")
    logger.write_object(self.extra)
    logger.write_string(")")
  }
}

///|
pub impl ToJson for Meta with to_json(self) {
  if self.is_none() {
    return Object({})
  }
  Object({
    "id": self.id.to_json(),
    "loc": self.loc.to_json(),
    "dict": self.extra.to_string().to_json(),
  })
}

///|
pub fn Meta::to_json(self : Meta) -> Json {
  ToJson::to_json(self)
}

pub(all) struct Meta {
  id : MetaId
  loc : TextLoc
  dict : Dict
}

pub(all) typealias Dict = Map[String, Json]

typealias MetaId = Int

let curr_id : Ref[MetaId] = Ref::new(0)

pub fn Meta::new(loc~ : TextLoc = text_loc_none) -> Meta {
  let res = { loc, id: curr_id.val, dict: Map::new() }
  curr_id.val += 1
  res
}

let meta_none : Meta = Meta::new()

pub fn Meta::none() -> Meta {
  meta_none
}

pub fn Meta::op_equal(self : Meta, other : Meta) -> Bool {
  self.id == other.id
}

pub fn Meta::compare(self : Meta, other : Meta) -> Int {
  self.id.compare(other.id)
}

pub fn Meta::is_none(self : Meta) -> Bool {
  self == meta_none
}

pub impl Show for Meta with output(self, logger) {
  if self.is_none() {
    logger.write_string("Meta::none()")
  } else {
    logger.write_string("Meta::new(id=")
    logger.write_object(self.id)
    logger.write_string(", loc=")
    logger.write_object(self.loc)
    logger.write_string(", dict=")
    logger.write_object(self.dict)
    logger.write_string(")")
  }
}

pub impl ToJson for Meta with to_json(self) {
  if self.is_none() {
    return Object({})
  }
  Object(
    {
      "id": self.id.to_json(),
      "loc": self.loc.to_json(),
      "dict": self.dict.to_json(),
    },
  )
}

pub fn Meta::to_json(self : Meta) -> Json {
  ToJson::to_json(self)
}

pub impl @json.FromJson for Meta with from_json(json, path) {
  match json {
    Object(obj) => {
      if obj.is_empty() {
        return Meta::none()
      }
      guard let { "id": id, "loc": loc, "dict": dict } = obj else {
        _ =>
          raise @json.JsonDecodeError(
            (path, "expected object with id, loc, dict"),
          )
      }
      let id = @json.from_json!(id, path~)
      let loc = @json.from_json!(loc, path~)
      let dict = @json.from_json!(dict, path~)
      { id, loc, dict }
    }
    _ => raise @json.JsonDecodeError((path, "expected object"))
  }
}

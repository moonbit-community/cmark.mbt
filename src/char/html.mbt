///|
fn html_named_entity(name : String) -> String? {
  match html_named_entities {
    Object(obj) =>
      obj.get(name).bind(fn(value) {
        if value is String(text) { Some(text) } else { None }
      })
    _ => None
  }
}

///|
fn html_named_entity(name : String) -> String? {
  if html_named_entities is Object(m) && m.get(name) is Some(String(v)) {
    Some(v)
  } else {
    None
  }
}

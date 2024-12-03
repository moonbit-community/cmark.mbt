///|
fn html_named_entity(name : String) -> String? {
  html_named_entities.value(name).bind(Json::as_string)
}

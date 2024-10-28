fn html_named_entity(name : String) -> String? {
  // TODO: Replace this with the real stuff.
  let html_named_entities : Json = { "AElig": "\u00C6", "AElig;": "\u00C6" }
  html_named_entities.value(name).bind(Json::as_string)
}

///|
/// Additional attributes for the HTML element that owns a parsed source node.
/// The callback receives the node's metadata and the lowercase HTML tag name.
/// Use `Doc::from_string(..., locs=true)` to retain source locations and IDs.
pub(all) struct NodeAttributesFn(
  (@cmark_base.Meta, String) -> Array[(String, String)] raise
)

///|
fn attribute_name_is_valid(name : String) -> Bool {
  guard !name.is_empty() else { return false }
  for index, unit in name {
    if unit is ('A'..='Z' | 'a'..='z' | '_' | ':') {
      continue
    }
    if index > 0 && unit is ('0'..='9' | '-' | '.') {
      continue
    }
    return false
  }
  true
}

///|
fn write_node_attributes(
  c : Context,
  meta : @cmark_base.Meta,
  tag : String,
  reserved? : Array[String] = [],
) -> Unit raise {
  guard c.state is Some(EState({ node_attributes, .. })) else {
    raise @cmark_renderer.RenderError(
      "HTML renderer context is not initialized",
    )
  }
  guard node_attributes is Some(hook) else { return }
  let names : Set[String] = Set::from_array(reserved)
  for (name, value) in hook(meta, tag) {
    guard attribute_name_is_valid(name) else {
      raise @cmark_renderer.RenderError("invalid HTML attribute name: \{name}")
    }
    let canonical = name.to_lower()
    guard !names.contains(canonical) else {
      raise @cmark_renderer.RenderError("duplicate HTML attribute: \{name}")
    }
    names.add(canonical)
    c.b.write_char(' ')
    c.b.write_string(name)
    c.b.write_string("=\"")
    html_escaped_string(c, value)
    c.b.write_char('"')
  }
}

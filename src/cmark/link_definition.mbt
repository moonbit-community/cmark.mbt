///|
/// The type for representing
/// {{:https://spec.commonmark.org/0.30/#link-reference-definitions}
/// link references definitions} and
/// {{:https://spec.commonmark.org/0.30/#inline-link}inline links}.
pub(all) struct LinkDefinition {
  layout : LinkDefinitionLayout
  label : Label?
  defined_label : Label?
  dest : StringNode?
  title : Seq[Tight]?
} derive(Eq, Show, ToJson)

///|
pub fn LinkDefinition::new(
  layout~ : LinkDefinitionLayout = LinkDefinitionLayout::default(),
  label~ : Label? = None,
  defined_label~ : Label? = None,
  dest~ : StringNode? = None,
  title~ : Seq[Tight]? = None,
) -> LinkDefinition {
  { layout, label, defined_label, dest, title }
}

///|
pub(all) struct LinkDefinitionLayout {
  indent : Indent
  angled_dest : Bool
  before_dest : Seq[BlockLineBlank]
  after_dest : Seq[BlockLineBlank]
  title_open_delim : Char
  after_title : Seq[BlockLineBlank]
} derive(Eq, Show, ToJson)

///|
pub fn LinkDefinitionLayout::default() -> LinkDefinitionLayout {
  {
    indent: 0,
    angled_dest: false,
    before_dest: [],
    after_dest: [],
    title_open_delim: '"',
    after_title: [],
  }
}

///|
pub fn LinkDefinitionLayout::for_dest(dest : String) -> LinkDefinitionLayout {
  let needs_angles = fn(c) { c == ' ' || @char.is_ascii_control(c) }
  {
    ..LinkDefinitionLayout::default(),
    angled_dest: dest.iter().any(needs_angles),
  }
}

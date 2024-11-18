// The type for representing
// {{:https://spec.commonmark.org/0.30/#link-reference-definitions}
// link references definitions} and
// {{:https://spec.commonmark.org/0.30/#inline-link}inline links}.
pub struct LinkDefinition {
  layout : LinkDefinitionLayout
  label : Label?
  defined_label : Label?
  dest : StringNode?
  title : List[Tight]?
} derive(Eq, Show, FromJson, ToJson)

pub fn LinkDefinition::new(
  layout~ : LinkDefinitionLayout = LinkDefinitionLayout::default(),
  label~ : Label? = None,
  defined_label~ : Label? = None,
  dest~ : StringNode? = None,
  title~ : List[Tight]? = None
) -> LinkDefinition {
  { layout, label, defined_label, dest, title }
}

pub struct LinkDefinitionLayout {
  indent : Indent
  angled_dest : Bool
  before_dest : List[BlockLineBlank]
  after_dest : List[BlockLineBlank]
  title_open_delim : Char
  after_title : List[BlockLineBlank]
} derive(Eq, Show, FromJson, ToJson)

pub fn LinkDefinitionLayout::default() -> LinkDefinitionLayout {
  {
    indent: 0,
    angled_dest: false,
    before_dest: Nil,
    after_dest: Nil,
    title_open_delim: '"',
    after_title: Nil,
  }
}

pub fn LinkDefinitionLayout::for_dest(dest : String) -> LinkDefinitionLayout {
  let needs_angles = fn(c) { c == ' ' || @char.is_ascii_control(c) }
  {
    ..LinkDefinitionLayout::default(),
    angled_dest: dest.iter().any(needs_angles),
  }
}

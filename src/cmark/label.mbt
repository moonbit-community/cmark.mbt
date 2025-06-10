// Labels.

///| Labels are used by [reference links](https://spec.commonmark.org/0.30/#reference-link) to
/// refer to the [definitions](#definitions) of
/// [link reference definitions](https://spec.commonmark.org/0.30/#link-reference-definitions),
/// [footnote definitions](#footnote-definitions) and your own
/// [interpretations](#resolvers).
pub(all) struct Label {
  meta : Meta
  key : LabelKey
  text : Seq[Tight]
} derive(Show, ToJson)

///| The type for label keys. These are
/// [link labels](https://spec.commonmark.org/0.30/#link-label)
/// normalized for [matches](https://spec.commonmark.org/0.30/#matches).
pub typealias String as LabelKey

///|
pub fn Label::new(
  meta~ : Meta = Meta::none(),
  key~ : String,
  text : Seq[Tight]
) -> Label {
  { meta, key, text }
}

///|
pub fn Label::text_loc(self : Label) -> TextLoc {
  Tight::list_text_loc(self.text)
}

///|
pub impl Eq for Label with op_equal(self, other) {
  self.key == other.key
}

///|
pub fn Label::compare(self : Label, other : Label) -> Int {
  self.key.compare(other.key)
}

///|
pub(all) enum LabelDef {
  LinkDef(Node[LinkDefinition])
  FootnoteDef(Node[Footnote])
} derive(Show, ToJson)

///|
pub typealias LabelDefs = Map[LabelKey, LabelDef]

///| `context` is:
/// - `Def (prev, current)` when we just hit a
///   [link reference definition](https://spec.commonmark.org/0.30/#link-reference-definitions)
///   or footnote definition that defines the label `current`.
///   If there is already a definition for `current`'s key it is provided in `prev`
///   (whose `meta` has the location of the definition if you parse with locations).
///   If `None` is returned the `current` definition is ignored, and definition `prev`
///   (if any) is kept for the document.
///   If `Some l` is returned `l`'s key will be bound to the parsed definition for `current`
///   in `Doc.defs` at the end of parsing.
///   The result of the resolver is stored in the abstract syntax tree and
///   available via `LinkDefinition.defined_label` and `BlockFootnote.defined_label`.
/// - `Ref (kind, ref, def)` when we just hit a link or image
///   referencing label `ref`. `def` is the label defining `ref`'s key
///   in the document (if any). The result of the resolver is the label
///   stored for resolving the reference to its definition in the resulting
///   `InlineLink` node;
///   `None` means that `label` is undefined and the inline becomes
///   `InlineText` like in CommonMark.
pub(all) enum LabelContext {
  Def(Label?, Label)
  Ref(LinkKind, Label, Label?)
}

///|
pub(all) enum LinkKind {
  Link
  Image
}

///|
pub(all) type LabelResolverFn (LabelContext) -> Label?

///|
pub fn LabelContext::default_resolver(self : LabelContext) -> Label? {
  match self {
    Def(None, k) => Some(k)
    Def(Some(_), _) => None
    Ref(_, _, k) => k
  }
}

///|
/// Extensible enum for renderer context state.
///
/// Concrete renderers extend this type with their own state variants
/// (e.g. `extenum ContextState += { MyState(...) }`) so the generic
/// `@cmark_renderer.Context` can carry renderer-specific state without
/// relying on `Error?` as an untyped container.
pub extenum ContextState {}

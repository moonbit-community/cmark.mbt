///| Renderer abstraction.
///
/// Stateful renderer abstraction to render documents in memory.
pub(all) struct Renderer {
  init_context : InitContextFn
  inline : InlineFn
  block : BlockFn
  doc : DocFn
}

///|
pub fn Renderer::new(
  init_context~ : InitContextFn = fn(_c, _d) {  },
  inline~ : InlineFn = fn!(_c, _i) { false },
  block~ : BlockFn = fn!(_c, _b) { false },
  doc~ : DocFn = fn!(_c, _d) { false }
) -> Renderer {
  { init_context, inline, block, doc }
}

///|
pub fn Renderer::compose(self : Renderer, other : Renderer) -> Renderer {
  let init_context = fn(c, d) {
    (self.init_context)(c, d)
    (other.init_context)(c, d)
  }
  let block = fn!(c, b) { (other.block)!(c, b) || (self.block)!(c, b) }
  let inline = fn!(c, i) { (other.inline)!(c, i) || (self.inline)!(c, i) }
  let doc = fn!(c, d) { (other.doc)!(c, d) || (self.doc)!(c, d) }
  { init_context, inline, block, doc }
}

///|
pub(all) struct Context {
  renderer : Renderer
  mut state : Error?
  b : Buffer
  mut doc : Doc
}

///|
pub fn Context::new(renderer : Renderer, b : Buffer) -> Context {
  { renderer, state: None, b, doc: Doc::empty() }
}

///|
pub fn Context::init(self : Context, doc : Doc) -> Unit {
  (self.renderer.init_context)(self, doc)
}

///|
pub(all) typealias InitContextFn = (Context, Doc) -> Unit

///|
pub(all) typealias InlineFn = (Context, Inline) -> Bool!

///|
pub(all) typealias BlockFn = (Context, Block) -> Bool!

///|
pub(all) typealias DocFn = (Context, Doc) -> Bool!

///|
pub fn Context::char(self : Context, ch : Char) -> Unit {
  self.b.write_char(ch)
}

///|
pub fn Context::string(self : Context, str : String) -> Unit {
  self.b.write_string(str)
}

///|
pub fn Context::inline!(self : Context, inline : Inline) -> Unit {
  let _ = (self.renderer.inline)!(self, inline) ||
    {
      raise RenderError("unknown inline type")
    }

}

///|
pub fn Context::block!(self : Context, block : Block) -> Unit {
  let _ = (self.renderer.block)!(self, block) ||
    {
      raise RenderError("unknown block type")
    }

}

///|
pub fn Context::doc!(self : Context, doc : Doc) -> Unit {
  self.doc = doc
  self.init(doc)
  let _ = (self.renderer.doc)!(self, doc) ||
    {
      raise RenderError("unhandled doc")
    }
  self.doc = Doc::empty()
}

///|
pub fn Renderer::doc_to_string!(self : Renderer, doc : Doc) -> String {
  let buf = Buffer::new(size_hint=1024)
  self.buffer_add_doc!(buf, doc)
  buf.to_string()
}

///|
pub fn Renderer::buffer_add_doc!(
  self : Renderer,
  buf : Buffer,
  doc : Doc
) -> Unit {
  Context::new(self, buf).doc!(doc)
}

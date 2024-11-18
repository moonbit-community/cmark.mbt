pub struct Folder[A] {
  inline_ext_default : FoldFn[Inline, A]
  block_ext_default : FoldFn[Block, A]
  inline : FolderFn[Inline, A]
  block : FolderFn[Block, A]
}

pub typealias FoldFn[A, B] = (Folder[B], B, A) -> B!FolderError

pub typealias FolderFn[A, B] = (Folder[B], B, A) -> FolderResult[B]

/// The type for folder results.
/// `Default` means doing the default fold.
pub enum FolderResult[A] {
  Default
  Fold(A)
} derive(Eq, Show, ToJson)

pub impl[A] Default for FolderResult[A] with default() { Default }

pub fn Folder::ret[A](a : A) -> FolderResult[A] {
  Fold(a)
}

pub fn Folder::none[A, B](self : Folder[A], _a : A, _b : B) -> FolderResult[A] {
  let _ = self
  Default
}

pub fn Folder::inline_ext_none[A](
  self : Folder[A],
  _a : A,
  _b : Inline
) -> A!FolderError {
  let _ = self
  raise FolderError("unknown inline extension")
}

pub fn Folder::block_ext_none[A](
  self : Folder[A],
  _a : A,
  _b : Block
) -> A!FolderError {
  let _ = self
  raise FolderError("unknown block extension")
}

pub fn Folder::new[A](
  inline_ext_default~ : FoldFn[Inline, A] = Folder::inline_ext_none,
  block_ext_default~ : FoldFn[Block, A] = Folder::block_ext_none,
  inline~ : FolderFn[Inline, A] = Folder::none,
  block~ : FolderFn[Block, A] = Folder::none
) -> Folder[A] {
  { inline_ext_default, block_ext_default, inline, block }
}

pub fn Folder::fold_inline[A](
  self : Folder[A],
  acc : A,
  i : Inline
) -> A!FolderError {
  guard let Default = (self.inline)(self, acc, i) else { Fold(acc) => acc }
  match i {
    // ExtMathSpan(_) | 
    Autolink(_) | Break(_) | CodeSpan(_) | RawHtml(_) | Text(_) => acc
    Image({ v, .. }) | Link({ v, .. }) => self.fold_inline!(acc, v.text)
    Emphasis({ v, .. }) | StrongEmphasis({ v, .. }) =>
      self.fold_inline!(acc, v.inline)
    Inlines({ v: is_, .. }) => {
      let mut acc = acc
      for x in is_ {
        acc = self.fold_inline!(acc, x)
      }
      acc
    }
    ExtStrikethrough({ v, .. }) => self.fold_inline!(acc, v._)
    // ext => (self.inline_ext_default)!(self, acc, ext)
  }
}

pub fn Folder::fold_block[A](
  self : Folder[A],
  acc : A,
  b : Block
) -> A!FolderError {
  guard let Default = (self.block)(self, acc, b) else { Fold(acc) => acc }
  match b {
    // ExtMathBlock(_) | 
    BlankLine(_)
    | CodeBlock(_) | HtmlBlock(_) | LinkRefDefinition(_) | ThematicBreak(_) =>
      acc
    Heading({ v, .. }) => self.fold_inline!(acc, v.inline)
    BlockQuote({ v, .. }) => self.fold_block!(acc, v.block)
    Blocks({ v, .. }) => {
      let mut acc = acc
      for x in v {
        acc = self.fold_block!(acc, x)
      }
      acc
    }
    List({ v, .. }) => {
      let mut acc = acc
      for x in v.items {
        acc = self.fold_block!(acc, x.v.block)
      }
      acc
    }
    Paragraph({ v, .. }) => self.fold_inline!(acc, v.inline)
    ExtTable({ v, .. }) => {
      let mut acc = acc
      for x in v.rows {
        match x.0.v {
          Header(is_) | Data(is_) =>
            for y in is_ {
              acc = self.fold_inline!(acc, y.0)
            }
          Sep(_) => ()
        }
      }
      acc
    }
    ExtFootnoteDefinition({ v, .. }) => self.fold_block!(acc, v.block)
    // ext => (self.block_ext_default)!(self, acc, ext)
  }
}

pub fn Folder::fold_doc[A](
  self : Folder[A],
  acc : A,
  doc : Doc
) -> A!FolderError {
  self.fold_block!(acc, doc.block)
}

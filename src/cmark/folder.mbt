///|
pub(all) struct Folder[A] {
  inline_ext_default : FoldFn[Inline, A]
  block_ext_default : FoldFn[Block, A]
  inline : FolderFn[Inline, A]
  block : FolderFn[Block, A]
}

///|
pub(all) type FoldFn[A, B] (Folder[B], B, A) -> B raise FolderError

///|
pub(all) type FolderFn[A, B] (Folder[B], B, A) -> FolderResult[B]

///| The type for folder results.
/// `Default` means doing the default fold.
pub(all) enum FolderResult[A] {
  Default
  Fold(A)
} derive(Eq, Show, ToJson)

///|
pub impl[A] Default for FolderResult[A] with default() {
  Default
}

///|
pub fn[A] Folder::ret(a : A) -> FolderResult[A] {
  Fold(a)
}

///|
pub fn[A, B] Folder::none(self : Folder[A], _a : A, _b : B) -> FolderResult[A] {
  let _ = self
  Default
}

///|
pub fn[A] Folder::inline_ext_none(
  self : Folder[A],
  _a : A,
  _b : Inline,
) -> A raise FolderError {
  let _ = self
  raise FolderError("unknown inline extension")
}

///|
pub fn[A] Folder::block_ext_none(
  self : Folder[A],
  _a : A,
  _b : Block,
) -> A raise FolderError {
  let _ = self
  raise FolderError("unknown block extension")
}

///|
pub fn[A] Folder::new(
  inline_ext_default~ : FoldFn[Inline, A] = Folder::inline_ext_none,
  block_ext_default~ : FoldFn[Block, A] = Folder::block_ext_none,
  inline~ : FolderFn[Inline, A] = Folder::none,
  block~ : FolderFn[Block, A] = Folder::none,
) -> Folder[A] {
  { inline_ext_default, block_ext_default, inline, block }
}

///|
pub fn[A] Folder::fold_inline(
  self : Folder[A],
  acc : A,
  i : Inline,
) -> A raise FolderError {
  if (self.inline)(self, acc, i) is Fold(acc) {
    return acc
  }
  match i {
    Autolink(_)
    | Break(_)
    | CodeSpan(_)
    | RawHtml(_)
    | Text(_)
    | ExtMathSpan(_) => acc
    Image({ v, .. }) | Link({ v, .. }) => self.fold_inline(acc, v.text)
    Emphasis({ v, .. }) | StrongEmphasis({ v, .. }) =>
      self.fold_inline(acc, v.inline)
    Inlines({ v: is_, .. }) => {
      let mut acc = acc
      for x in is_ {
        acc = self.fold_inline(acc, x)
      }
      acc
    }
    ExtStrikethrough({ v, .. }) => self.fold_inline(acc, v.inner())
    // ext => (self.inline_ext_default)!(self, acc, ext)
  }
}

///|
pub fn[A] Folder::fold_block(
  self : Folder[A],
  acc : A,
  b : Block,
) -> A raise FolderError {
  if (self.block)(self, acc, b) is Fold(acc) {
    return acc
  }
  match b {
    BlankLine(_)
    | CodeBlock(_)
    | HtmlBlock(_)
    | LinkRefDefinition(_)
    | ThematicBreak(_)
    | ExtMathBlock(_) => acc
    Heading({ v, .. }) => self.fold_inline(acc, v.inline)
    BlockQuote({ v, .. }) => self.fold_block(acc, v.block)
    Blocks({ v, .. }) => {
      let mut acc = acc
      for x in v {
        acc = self.fold_block(acc, x)
      }
      acc
    }
    List({ v, .. }) => {
      let mut acc = acc
      for x in v.items {
        acc = self.fold_block(acc, x.v.block)
      }
      acc
    }
    Paragraph({ v, .. }) => self.fold_inline(acc, v.inline)
    ExtTable({ v, .. }) => {
      let mut acc = acc
      for x in v.rows {
        if x.0.v is (Header(is_) | Data(is_)) {
          for y in is_ {
            acc = self.fold_inline(acc, y.0)
          }
        }
      }
      acc
    }
    ExtFootnoteDefinition({ v, .. }) => self.fold_block(acc, v.block)
    // ext => (self.block_ext_default)!(self, acc, ext)
  }
}

///|
pub fn[A] Folder::fold_doc(
  self : Folder[A],
  acc : A,
  doc : Doc,
) -> A raise FolderError {
  self.fold_block(acc, doc.block)
}

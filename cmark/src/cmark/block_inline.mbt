///|
/// Inline atoms can hide math openers; only display math protects subsequent
/// lines from Markdown block parsing. Positions include the closing delimiter.
#derive(Debug)
priv enum ParagraphInline {
  Code(Int32)
  Math(Int32, display~ : Bool)
}

///|
fn ParagraphInline::last(self : ParagraphInline) -> Int32 {
  match self {
    Code(last) | Math(last, ..) => last
  }
}

///|
fn Parser::block_closers(self : Parser) -> CloserIndex {
  match self.block_cidx {
    Some(index) => index
    None => {
      // Reuse inline tokenization so escapes and delimiter runs have exactly
      // the same meaning in both parsing phases. No block interpretation is
      // needed to index potential closers.
      let line : LineSpan = {
        first: 0,
        last: self.i.length() - 1,
        pos: LinePos(1, 0),
      }
      let (index, _, _, _) = tokenize(self.i, [line], exts=true)
      self.block_cidx = Some(index)
      index
    }
  }
}

///|
fn Parser::paragraph_inline(
  self : Parser,
  line : LineSpan,
  previous : ParagraphInline?,
) -> ParagraphInline? {
  guard self.exts else { return None }
  let mut region = previous
  let (_, tokens, _, _) = tokenize(self.i, [line], exts=true)
  for token in tokens.0 {
    if region is Some(current) && token.start() <= current.last() {
      continue
    }
    region = None
    match token {
      Backticks({ start, count, escaped, }) => {
        let start = start + escaped.to_int()
        let count = count - escaped.to_int()
        if count > 0 &&
          self.block_closers().pos(Backticks(count), after=start) is Some(end) {
          region = Some(Code(end + count - 1))
        }
      }
      MathSpanMarks({ start, count, may_open: true, .. }) =>
        if self.block_closers().pos(MathSpanMarks(count), after=start)
          is Some(end) {
          region = Some(Math(end + count - 1, display=count == 2))
        }
      _ => ()
    }
  }
  match region {
    Some(current) if current.last() > line.last => region
    _ => None
  }
}

///|
fn Paragraph::in_display_math(self : Paragraph) -> Bool {
  self.inline_region is Some(Math(_, display=true))
}

///|
fn blocks_in_display_math(blocks : Array[BlockStruct]) -> Bool {
  match blocks.last() {
    Some(Paragraph(par)) => par.in_display_math()
    Some(BlockQuote(_, blocks) | ExtFootnote(_, _, blocks)) =>
      blocks_in_display_math(blocks)
    Some(List(list)) =>
      match list.items.last() {
        Some(item) => blocks_in_display_math(item.blocks)
        None => false
      }
    _ => false
  }
}

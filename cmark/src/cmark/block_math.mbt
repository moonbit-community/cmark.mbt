///|
/// These are the already-open outer containers, not Markdown inside math.
priv enum MathContainer {
  Quote
  Indent(Int32)
}

///|
/// Collect innermost first from the existing block tree. This does not change
/// container continuation rules or duplicate container dispatch at each call.
fn collect_math_containers(
  blocks : Array[BlockStruct],
  path : Array[MathContainer],
) -> Bool {
  match blocks.last() {
    Some(Paragraph(par)) => par.may_have_math
    Some(BlockQuote(_, blocks)) => {
      guard collect_math_containers(blocks, path) else { return false }
      path.push(Quote)
      true
    }
    Some(List(list)) => {
      guard list.items.last() is Some(item) &&
        collect_math_containers(item.blocks, path) else {
        return false
      }
      path.push(Indent(list.item_min_indent))
      true
    }
    Some(ExtFootnote(indent, _, blocks)) => {
      guard collect_math_containers(blocks, path) else { return false }
      path.push(Indent(indent + 1))
      true
    }
    _ => false
  }
}

///|
/// Look ahead using the same prefix consumers as block parsing. Math cannot
/// force a quote, list, or footnote to continue beyond its outer boundary.
fn Parser::next_math_line(self : Parser) -> LineSpan? {
  guard self.get_next_line() else { return None }
  for container in self.math_containers.rev_iter() {
    match container {
      Quote => {
        let indent = self.curr_indent()
        guard indent < 4 else { return None }
        self.accept_cols(count=indent)
        guard self.match_and_accept_block_quote() else { return None }
      }
      Indent(count) =>
        if self.curr_indent() >= count {
          self.accept_cols(count~)
        } else if !self.only_blanks() {
          return None
        }
    }
  }
  Some(self.curr_line_span(first=self.curr_char, last=self.curr_line_last_char))
}

///|
fn Parser::line_may_have_math(self : Parser, line : LineSpan) -> Bool {
  self.i.clamped_view(start=line.first, end=line.last + 1).contains("$$")
}

///|
fn Parser::math_marks(self : Parser, line : LineSpan) -> Array[Int32] {
  guard self.line_may_have_math(line) else { return [] }
  let (_, tokens, _, _) = tokenize(self.i, [line], exts=true)
  let marks = []
  for token in tokens.0 {
    if token is MathSpanMarks({ start, count: 2, .. }) {
      marks.push(start)
    }
  }
  marks
}

///|
/// Use the real paragraph/inline grammar, including leading reference
/// definitions. Text locations distinguish visible delimiters from dollars in
/// code, HTML, link destinations, titles, and already-parsed math.
fn Parser::math_context(
  self : Parser,
  lines : Array[LineSpan],
) -> (Array[TextLoc], Array[TextLoc]) {
  let lines = lines.copy()
  while !lines.is_empty() && self.parse_link_ref_definition(lines) is Some(_) {

  }
  guard !lines.is_empty() else { return ([], []) }
  let (_, inline) = self.parse_inline(lines)
  let folder : Folder[(Array[TextLoc], Array[TextLoc])] = Folder::new(inline=fn(
    _,
    context,
    inline,
  ) {
    match inline {
      Text({ meta, .. }) => context.0.push(meta.loc)
      ExtMathSpan({ v: { display: true, .. }, meta, }) =>
        context.1.push(meta.loc)
      _ => ()
    }
    Default
  })
  try! folder.fold_inline(([], []), inline)
}

///|
/// Called only when a line would interrupt a paragraph containing potential
/// math. Parse a bounded candidate paragraph, rather than inventing a second
/// inline grammar. Only an actual display math span can consume the extra lines.
fn Parser::extend_math_paragraph(
  self : Parser,
  lines : Array[LineSpan],
  reader : Parser,
) -> Bool {
  let context = Parser::new(
    self.i,
    strict=false,
    locs=true,
    defs=self.defs.copy(),
  )
  let (text, _) = context.math_context(lines)
  let openers = []
  for line in lines {
    for start in self.math_marks(line) {
      if text
        .iter()
        .any(loc => loc.first_ccode <= start && start + 1 <= loc.last_ccode) {
        openers.push(start)
      }
    }
  }
  guard !openers.is_empty() else { return false }
  let candidate = lines.copy()
  let mut next = reader.curr_line_span(
    first=reader.curr_char,
    last=reader.curr_line_last_char,
  )
  for ;; {
    candidate.push(next)
    if !reader.math_marks(next).is_empty() {
      let (text, math) = context.math_context(candidate)
      if math
        .iter()
        .any(loc => {
          openers.contains(loc.first_ccode) && loc.last_line == next.pos
        }) {
        lines.push_iter(candidate[lines.length():].iter())
        self.curr_line_pos = reader.curr_line_pos
        self.curr_line_last_char = reader.curr_line_last_char
        self.curr_char = reader.curr_char
        self.curr_char_col = reader.curr_char_col
        self.next_non_blank = reader.next_non_blank
        self.next_non_blank_col = reader.next_non_blank_col
        self.tab_consumed_cols = reader.tab_consumed_cols
        return true
      }
      if !openers
        .iter()
        .any(start => {
          text
          .iter()
          .any(loc => loc.first_ccode <= start && start + 1 <= loc.last_ccode)
        }) {
        return false
      }
    }
    guard reader.next_math_line() is Some(line) else { return false }
    next = line
  }
}

///| Block lines.
///
/// In CommonMark blocks, a "line" does not necessarily correspond to
/// a line in the source plain text. For example the lines of a
/// paragraph in a block quote are the lines stripped from the block
/// quote markers.  We call the line resulting from stripping the
/// block structure preceeding a given block a {e block line}.
pub(all) type BlockLine Node[String]

///|
pub(all) typealias BlockLineBlank = Node[Blanks]

///|
pub fn BlockLine::to_string(self : BlockLine) -> String {
  self._.v
}

///|
pub fn BlockLine::list_text_loc(ls : List[BlockLine]) -> TextLoc {
  match ls {
    Nil => TextLoc::none()
    Cons(head, Nil) => head.meta.loc
    Cons(head, tail) => {
      let last = tail.unsafe_last()
      head.meta.loc.reloc(last.meta.loc)
    }
  }
}

///| Tight block lines: a block line with its initial blanks trimmed but kept for layout. 
pub(all) struct Tight {
  blanks : Blanks
  node : StringNode
} derive(Eq, ToJson)

///|
pub fn Tight::empty(meta~ : Meta = Meta::none()) -> Tight {
  { blanks: "", node: StringNode::empty(meta~) }
}

///|
pub impl Show for Tight with output(self, logger) {
  logger.write_object(self.node.v)
}

///|
pub fn Tight::to_string(self : Tight) -> String {
  self.node.v
}

///|
pub fn Tight::list_text_loc(ls : List[Tight]) -> TextLoc {
  match ls {
    Nil => TextLoc::none()
    Cons(head, Nil) => head.node.meta.loc
    Cons(head, tail) => {
      let last = tail.unsafe_last()
      head.node.meta.loc.reloc(last.node.meta.loc)
    }
  }
}

///|
fn BlockLine::flush(
  meta~ : Meta = Meta::none(),
  s : String,
  start : Int,
  last : Int,
  acc : List[StringNode]
) -> List[StringNode] {
  acc.add({ meta, v: s.substring(start~, end=last + 1) })
}

///|
fn BlockLine::flush_tight(
  meta~ : Meta = Meta::none(),
  s : String,
  start : Int,
  last : Int,
  acc : List[Tight]
) -> List[Tight] {
  // If [s] has newlines, blanks after newlines are layout
  if start > last {
    return acc.add(Tight::empty(meta~))
  }
  // On the first line the blanks are legit 
  if acc.is_empty() {
    return acc.add({
      blanks: "",
      node: { meta, v: s.substring(start~, end=last + 1) },
    })
  }
  let nb = @cmark_base.first_non_blank(s, last~, start~)
  acc.add({
    blanks: s.substring(start~, end=nb),
    node: { meta, v: s.substring(start=nb, end=last + 1) },
  })
}

///|
typealias FlushFn[A] = (String, Int, Int, List[A]) -> List[A]

///|
fn _list_of_string[A](flush : FlushFn[A], s : String) -> List[A] {
  loop s, List::Nil, s.length() - 1, 0, 0 {
    s, acc, max, start, k => {
      if k > max {
        break flush(s, start, max, acc).rev()
      }
      if not(s[k] == '\n' || s[k] == '\r') {
        continue s, acc, max, start, k + 1
      }
      let acc = flush(s, start, k - 1, acc)
      let next = k + 1
      let start = if s[k] == '\r' && next <= max && s[next] == '\n' {
        next + 1
      } else {
        next
      }
      continue s, acc, max, start, start
    }
  }
}

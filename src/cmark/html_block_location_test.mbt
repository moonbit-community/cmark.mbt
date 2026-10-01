///|
test "HTML block location spans all its lines" {
  let doc = @cmark.Doc::from_string(locs=true, "a\n\n<div>\nb\n</div>\n")
  guard doc.block is Blocks({ v: blocks, .. }) &&
    blocks.to_array() is [_, _, HtmlBlock({ meta, .. }), ..] else {
    fail("expected an HTML block")
  }
  let loc = meta.loc
  debug_inspect(
    (loc.first_line, loc.last_line, loc.first_ccode, loc.last_ccode),
    content="(LinePos(3, 3), LinePos(5, 11), 3, 16)",
  )
}

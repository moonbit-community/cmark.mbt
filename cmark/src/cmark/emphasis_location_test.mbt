///|
test "multi-line emphasis location starts on the opener's line" {
  let doc = @cmark.Doc::from_string(locs=true, "x *a\nb* y\n")
  guard doc.block is Blocks({ v: blocks, .. }) &&
    blocks.to_array()
    is [Paragraph({ v: { inline: Inlines({ v: inlines, .. }), .. }, .. }), ..] &&
    inlines.to_array() is [_, Emphasis({ meta, .. }), ..] else {
    fail("expected emphasis in a paragraph")
  }
  let loc = meta.loc
  debug_inspect(
    (loc.first_line, loc.last_line, loc.first_ccode, loc.last_ccode),
    content="(LinePos(1, 0), LinePos(2, 5), 2, 6)",
  )
}

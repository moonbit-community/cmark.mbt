///|
test "TextLoc::is_none with none value" {
  let loc = @cmark_base.TextLoc::none()
  inspect(loc.is_none(), content="true")
}

///|
test "TextLoc::is_empty for non-empty location" {
  let loc = @cmark_base.TextLoc::none()
  let loc = { ..loc, first_ccode: 10, last_ccode: 5 }
  inspect(loc.is_empty(), content="true")
}

///|
test "TextLoc::is_empty for empty location" {
  let loc = @cmark_base.TextLoc::none()
  let loc = { ..loc, first_ccode: 5, last_ccode: 10 }
  inspect(loc.is_empty(), content="false")
}

///|
test "TextLoc::after basic functionality" {
  let loc = @cmark_base.TextLoc::none()
  let after_loc = loc.after()
  inspect(after_loc.first_ccode, content="0")
  inspect(after_loc.last_ccode, content="-1")
  inspect(after_loc.first_line, content="LinePos(-1, -1)")
  inspect(after_loc.last_line, content="LinePos(-1, -1)")
}

///|
test "test case TextLoc::reloc" {
  let loc1 = @cmark_base.TextLoc::none()
  let loc2 = @cmark_base.TextLoc::none()
  inspect(
    loc1.reloc(loc2),
    content=(
      #|{file: "-", first_ccode: -1, last_ccode: -1, first_line: LinePos(-1, -1), last_line: LinePos(-1, -1)}
    ),
  )
}

///|
test "TextLoc to_first method test" {
  let initial_loc : @cmark_base.TextLoc = {
    file: "dummy_file",
    first_ccode: 10,
    last_ccode: 20,
    first_line: @cmark_base.LinePos(1, 10),
    last_line: @cmark_base.LinePos(2, 20),
  }
  let modified_loc = initial_loc.to_first()
  inspect(modified_loc.last_ccode, content="10")
  inspect(modified_loc.last_line.0, content="1")
  inspect(modified_loc.last_line.1, content="10")
}

///|
test "TextLoc to_last method" {
  let loc_initial : @cmark_base.TextLoc = {
    file: "test_file",
    first_ccode: 10,
    last_ccode: 20,
    first_line: LinePos(1, 10),
    last_line: LinePos(1, 20),
  }
  let loc_transformed = loc_initial.to_last()
  inspect(loc_transformed.first_ccode, content="20")
  inspect(loc_transformed.first_line, content="LinePos(1, 20)")
}

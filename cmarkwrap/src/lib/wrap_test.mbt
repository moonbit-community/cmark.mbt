///|
test "render markdown heading" {
  let result = try? @lib.render("# Hello\n")
  debug_inspect(@lib.result_is_ok(result), content="true")
}

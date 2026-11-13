///|
test "command parses cmark style flags" {
  let matches = command().parse(
    argv=["--safe", "--relaxed", "-t", "xhtml", "-"],
    env={},
  ) catch {
    _ => panic()
  }
  let options = options_from_matches(matches)
  assert_true(options.safe)
  assert_false(options.strict)
  assert_eq(options.format, "xhtml")
  assert_true(input_paths(matches) == ["-"])
}

///|
test "render html by default" {
  let options : Options = {
    safe: false,
    strict: true,
    backend_blocks: false,
    format: "html",
  }
  inspect(render_input("# hello\n", options), content="<h1>hello</h1>\n")
}

///|
test "render xhtml format" {
  let options : Options = {
    safe: false,
    strict: true,
    backend_blocks: false,
    format: "xhtml",
  }
  inspect(
    render_input("line\\\nnext\n", options),
    content="<p>line<br />\nnext</p>\n",
  )
}

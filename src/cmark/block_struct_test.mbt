///|
test "get_first_line with CRLF" {
  let line = "hello\r\nworld"
  let doc = @cmark.Doc(line)
  debug_inspect(
    doc.nl,
    content=(
      #|"\r\n"
    ),
  )
}

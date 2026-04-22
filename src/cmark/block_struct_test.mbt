///|
test "get_first_line with CRLF" {
  let line = "hello\r\nworld"
  let doc = @cmark.Doc::from_string(line)
  inspect(doc.nl, content="\r\n")
}

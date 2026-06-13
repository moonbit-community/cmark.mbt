///|
test "render markdown heading" {
  let result = @lib.render("# Hello\n")
  inspect(result, content=(
    #|<h1>Hello</h1>
    #|
  ))
}

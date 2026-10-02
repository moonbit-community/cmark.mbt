///|
test "task item preserves continuation paragraphs and nested children" (
  it : @test.Test,
) {
  let input =
    #|- [x] parent
    #|  continuation
    #|
    #|  second paragraph
    #|  - [ ] child
  it.write(@cmark_html.render(safe=false, strict=false, input))
  it.snapshot(filename="task_continuation.html")
}

///|
test "task item owns fenced and indented code blocks" (it : @test.Test) {
  let input =
    #|- [x] fenced
    #|  ```moonbit
    #|  let x = 1
    #|  ```
    #|  - [ ] nested
    #|
    #|- [x] indented
    #|
    #|      code
    #|      more
    #|  - [ ] nested
  it.write(@cmark_html.render(safe=false, strict=false, input))
  it.snapshot(filename="task_code_blocks.html")
}

///|
test "task child inside blockquote" (it : @test.Test) {
  let input =
    #|> - [x] parent
    #|>   - [ ] child
  it.write(@cmark_html.render(safe=false, strict=false, input))
  it.snapshot(filename="task_blockquote.html")
}

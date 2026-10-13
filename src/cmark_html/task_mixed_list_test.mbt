///|
test "plain and task parents can both own task children" (it : @test.Test) {
  let input =
    #|- plain parent
    #|  - [ ] task child
    #|- [x] task parent
    #|  - plain child
    #|    - [X] grandchild
  it.write(@cmark_html.render(safe=false, strict=false, input))
  it.snapshot(filename="task_mixed_list.html")
}

///|
test "ordered task item owns an unordered child" (it : @test.Test) {
  let input =
    #|1. [x] parent
    #|   - [ ] child
  it.write(@cmark_html.render(safe=false, strict=false, input))
  it.snapshot(filename="task_ordered_parent.html")
}

///|
test "strict mode leaves task markers as text while preserving list nesting" (
  it : @test.Test,
) {
  let input =
    #|- [x] parent
    #|  - [ ] child
  it.write(@cmark_html.render(safe=false, strict=true, input))
  it.snapshot(filename="task_strict_mode.html")
}

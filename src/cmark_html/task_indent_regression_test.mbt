///|
test "two-space child task belongs to parent" {
  let input = "- [x] parent\n  - [ ] child\n"
  let expected = "<ul>\n<li><div class=\"task\"><input type=\"checkbox\" disabled checked><div>parent\n<ul>\n<li><div class=\"task\"><input type=\"checkbox\" disabled><div>child</div></div></li>\n</ul>\n</div></div></li>\n</ul>\n"
  assert_eq(@cmark_html.render(safe=false, strict=false, input), expected)
}

///|
test "four-space child task belongs to parent" {
  let input = "- [x] parent\n    - [ ] child\n"
  let expected = "<ul>\n<li><div class=\"task\"><input type=\"checkbox\" disabled checked><div>parent\n<ul>\n<li><div class=\"task\"><input type=\"checkbox\" disabled><div>child</div></div></li>\n</ul>\n</div></div></li>\n</ul>\n"
  assert_eq(@cmark_html.render(safe=false, strict=false, input), expected)
}

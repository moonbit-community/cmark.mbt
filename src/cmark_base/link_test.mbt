///|
test "link_destination start greater than last" {
  let s = "test"
  let last = 3
  let start = 4
  inspect(link_destination(s, last~, start~), content="None")
}

///|
test "link_destination with angle bracket and early termination" {
  let s = "<test\n>"
  let last = 6
  let start = 0
  inspect(link_destination(s, last~, start~), content="None")
}

///|
test "link_destination not delimited with unbalanced closing parenthesis" {
  let s = "(test(test)"
  let last = 10
  let start = 0
  inspect(link_destination(s, last~, start~), content="None")
}

///|
test "link_destination test with no end delimiter" {
  let input = "<some_url"
  let last = 8
  let start = 0
  inspect(link_destination(input, last~, start~), content="None")
}

///|
test "link_destination contains no space condition false" {
  let s = "   "
  let last = s.length() - 1
  let start = 0
  let result = link_destination(s, last~, start~)
  inspect(result, content="None")
}

///|
test "test link_destination with escaped backslashes" {
  let result = link_destination("<\\\\>", last=3, start=0)
  inspect(result, content="Some((true, 1, 2))")
}

///|
test "test link_destination with matched angle brackets" {
  let result = link_destination("<url>", last=4, start=0)
  inspect(result, content="Some((true, 1, 3))")
}

///|
test "test link_destination with backslash before closing angle bracket" {
  let result = link_destination("<url\\>", last=5, start=0)
  inspect(result, content="None")
}

///|
test "trigger uncovered line 28 and 29" {
  let input : String = "<test<text"
  let last : Int = 10
  let start : Int = 0
  inspect(link_destination(input, last~, start~), content="None")
}

///|
test "test escaped parenthesis in not delimited link destination" {
  let s = "Hello(\\)World"
  let last = s.length() - 1
  let start = 0
  inspect(link_destination(s, last~, start~), content="None")
}

///|
test "test double backslash before less-than" {
  let s = "<\\<"
  let last = 2
  let start = 0
  inspect(link_destination(s, last~, start~), content="None")
}

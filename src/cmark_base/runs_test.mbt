///|
test "rev_drop_spaces when start is less than first" {
  inspect(rev_drop_spaces("hello world", first=5, start=3), content="4")
}

///|
test "rev_drop_spaces with spaces" {
  inspect(rev_drop_spaces("hello   world", first=0, start=7), content="4")
}

///|
test "rev_drop_spaces with no spaces" {
  inspect(rev_drop_spaces("hello", first=0, start=4), content="4")
}

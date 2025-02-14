///|
test "autolink_email invalid label sequence with non-alphanumeric char" {
  inspect!(autolink_email("<a@#>"), content="None")
}

///|
test "autolink_email label sequence with invalid end char" {
  inspect!(autolink_email("<a@a#"), content="None")
}

///|
test "autolink_email invalid start" {
  inspect!(autolink_email("hello"), content="None")
}

///|
test "autolink_email label sequence ending with invalid char" {
  inspect!(autolink_email("<a@abc$>"), content="None")
}

///|
test "email autolink - premature end" {
  let email = "<a@b"
  inspect!(autolink_email(email), content="None")
}

///|
test "email autolink - non-alphanum ending" {
  let email = "<a@b->"
  inspect!(autolink_email(email), content="None")
}

///|
test "autolink_uri - incomplete uri at end of string" {
  inspect!(autolink_uri("<http://example.com"), content="None")
}

///|
test "autolink_uri - incomplete uri with empty content" {
  inspect!(autolink_uri("<http:"), content="None")
}

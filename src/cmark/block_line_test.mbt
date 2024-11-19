test "Show for Tight outputs the node content" {
  let tight = Tight::empty()
  inspect!(Show::to_string(tight), content="\"\"")
}

///|
/// The examples of the CommonMark spec (`src/data/test/spec.md`) as
/// `(number, markdown, expected_html)`.
fn spec_examples() -> Array[(Int, String, String)] {
  let fence = "````````````````````````````````"
  let examples = []
  let lines = test_spec_md_str.split("\n").map(l => l.to_owned()).to_array()
  let mut i = 0
  while i < lines.length() {
    if lines[i] == "\{fence} example" {
      let md = StringBuilder()
      let html = StringBuilder()
      i += 1
      while lines[i] != "." {
        md.write_string(lines[i])
        md.write_char('\n')
        i += 1
      }
      i += 1
      while lines[i] != fence {
        html.write_string(lines[i])
        html.write_char('\n')
        i += 1
      }
      let tabs = (s : String) => s.replace_all(old="→", new="\t")
      examples.push(
        (examples.length() + 1, tabs(md.to_string()), tabs(html.to_string())),
      )
    }
    i += 1
  }
  examples
}

///|
test "CommonMark spec examples" {
  let examples = spec_examples()
  let renderer = @cmark_html.xhtml_renderer(safe=false)
  let failed = []
  for example in examples {
    let (n, md, html) = example
    let rendered = renderer.doc_to_string(Doc::from_string(md))
    if rendered != html {
      failed.push(n)
    }
  }
  inspect(
    "\{examples.length() - failed.length()}/\{examples.length()}",
    content="652/652",
  )
  debug_inspect(failed, content="[]")
}

///|
priv enum SpecSection {
  Prose
  Markdown
  Html
}

///|
/// The examples of the CommonMark spec (`src/data/test/spec.md`) as
/// `(number, markdown, expected_html)`.
fn spec_examples() -> Array[(Int, String, String)] {
  let fence = "`".repeat(32)
  let tabs = (s : String) => s.replace_all(old="→", new="\t")
  let examples = []
  let md = StringBuilder()
  let html = StringBuilder()
  let mut section = Prose
  for line in test_spec_md_str.split("\n") {
    match section {
      Prose => if line == "\{fence} example" { section = Markdown }
      Markdown =>
        if line == "." {
          section = Html
        } else {
          md..write_view(line).write_char('\n')
        }
      Html =>
        if line == fence {
          let n = examples.length() + 1
          examples.push((n, tabs(md.to_string()), tabs(html.to_string())))
          md.reset()
          html.reset()
          section = Prose
        } else {
          html..write_view(line).write_char('\n')
        }
    }
  }
  examples
}

///|
test "CommonMark spec examples" {
  let examples = spec_examples()
  let renderer = @cmark_html.xhtml_renderer(safe=false)
  let failed = examples
    .filter(example => {
      let (_, md, html) = example
      renderer.doc_to_string(Doc::from_string(md)) != html
    })
    .map(example => example.0)
  // The numbers of the failing examples first, so that they are reported
  debug_inspect(failed, content="[]")
  inspect(
    "\{examples.length() - failed.length()}/\{examples.length()}",
    content="652/652",
  )
}

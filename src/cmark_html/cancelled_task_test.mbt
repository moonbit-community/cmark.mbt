///|
test "cancelled tasks close del before the following task" {
  for
    (source, expected) in [
      (
        "- [~] cancelled *item*\n- [ ] pending",
        (
          #|<ul>
          #|<li><div class="task"><input type="checkbox" disabled><del>cancelled <em>item</em></del></div></li>
          #|<li><div class="task"><input type="checkbox" disabled><div>pending</div></div></li>
          #|</ul>
          #|
        ),
      ),
      (
        "- [~] cancelled *item*\n\n- [ ] pending",
        (
          #|<ul>
          #|<li><div class="task"><input type="checkbox" disabled><del>
          #|<p>cancelled <em>item</em></p>
          #|</del></div></li>
          #|<li><div class="task"><input type="checkbox" disabled><div>
          #|<p>pending</p>
          #|</div></div></li>
          #|</ul>
          #|
        ),
      ),
    ] {
    let doc = @cmark.Doc::from_string(source, strict=false)
    for
      renderer in [
        @cmark_html.renderer(safe=true),
        @cmark_html.xhtml_renderer(safe=true),
      ] {
      assert_eq(renderer.doc_to_string(doc), expected)
    }
  }
}

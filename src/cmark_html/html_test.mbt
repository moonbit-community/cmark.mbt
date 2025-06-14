///|
typealias @cmark.Doc

///|
test "should render task list" (it : @test.T) {
  let doc =
    #|## List task items
    #|
    #|* [ ] Task open
    #|* [x] Task done
    #|* [X] Task done
    #|*  [✓] Task done (U+2713, CHECK MARK)
    #|*   [✔] Task done (U+2714, HEAVY CHECK MARK)
    #|        Indent
    #|* Of course this can all be nested
    #|  * [𐄂] Task done (U+10102, AEGEAN CHECK MARK)
    #|        It will be done for sure.
    #|
    #|            code block
    #|           Not a code block
    #|  * [x] Task done
    #|  * [~] Task cancelled
    #|        Paragraphy
    #|  * [x]Not a task
    #|  * \[x] Not a task
    #|
    #|* [ ]
    #|* [ ] a
    #|
    #|          Code
    #|         Not code
    #|
    #|* [ ]
    #|          Code
    #|         Not code
  let rendered = render(safe=false, strict=false, doc)
  it.write(rendered)
  it.snapshot(filename="task_list.html")
}

///|
test "should render strikethroughs" (it : @test.T) {
  let doc =
    #|## Strikethrough
    #|
    #|The stroken ~~*emph1*~~.
    #|
    #|Nesting the nest ~~*emph2* ~~stroke~~ *emph3 **emph4  ~~strikeagain~~***~~
    #|
    #|There must be no blanks after the opener and before the closer. This
    #|is ~~ not an opener and ~~this won't open ~~that does~~.
    #|
    #|* Here we have ~~stroken `code`~~.
    #|* Here we have ~~nested ~~stroken~~ ok~~
  let rendered = render(safe=false, strict=false, doc)
  it.write(rendered)
  it.snapshot(filename="strikethrough.html")
}

///|
test "should render footnotes" (it : @test.T) {
  let doc =
    #|## Footnotes
    #|
    #|This is a footnote in history[^1] with mutiple references[^1]
    #|and even [text references][^1]
    #|
    #| [^1]: And it can have
    #|lazy continuation lines and multiple paragraphs
    #|
    #|  If you indent one column after the footnote label start.
    #|
    #|      cb
    #|  * list item
    #|ablc
    #|  * another item
    #|
    #|
    #| This is no longer the footnote.
    #|
    #|Can we make footnotes in footnotes[^2] ?
    #|
    #|[^2]: This gets tricky but I guess we could have a footnote[^tricky] in
    #|  a footnote. Also footnote[^1] in footnotes[^2] is[^3] tricky for getting
    #|  all back references rendered correctly.
    #|
    #|  [^tricky]: The foot of the footnote. But that's not going to link back[^2]
    #|
    #|  Second footnote
    #|
    #|Not the footnote
    #|
    #|[^3]:
    #|
    #|Not the footnote but a reference to an empty footnote[^3]
    #|
    #|Not a footnote [^]
    #|
    #|[^]: not a footnote.
  let rendered = render(safe=false, strict=false, doc)
  it.write(rendered)
  it.snapshot(filename="footnote.html")
}

///|
test "should render math" (it : @test.T) {
  let doc =
    #|## Math
    #|
    #|The inline $\sqrt{x^2-1}$ equation.
    #|
    #|There must be no blanks after the opener and before the closer. This
    #|makes so you can donate $5 or $10 dollars here and there without problem.
    #|
    #|There is no such think as nesting $\sqrt{x^2-1}$+3$+3$. As usual
    #|delimiters can be \$escaped\$ $\sqrt{16\$}$
    #|
    #|Amazing, this is [hyperlinked math $3x^2$](https://example.org)
    #|
    #|The HTML renderer should be careful with $a < b$ escapes.
    #|
    #|Display math can be in `math` code blocks.
    #|
    #|```math
    #|\left( \sum_{k=1}^n a_k b_k \right)^2 < \Phi
    #|```
    #|
    #|But it can also be in $$ \left( \sum_{k=1}^n
    #|   a_k b_k \right)^2 < \Phi $$
  let rendered = render(safe=false, strict=false, doc)
  it.write(rendered)
  it.snapshot(filename="math.html")
}

///|
test "should render tables" (it : @test.T) {
  let doc =
    #|## Tables
    #|
    #|A sample table:
    #|
    #|| Id | Name  | Description            | Link                |
    #||:--:|------:|:-----------------------|--------------------:|
    #|| 1  | OCaml | The OCaml website      | <https://ocaml.org> |
    #|| 2  | Haskell | The Haskell website | <https://haskell.org> |
    #|| 3 | MDN Web docs | Web dev docs | <https://developer.mozilla.org/> |
    #|| 4 | Wikipedia | The Free Encyclopedia | <https://wikipedia.org> |
    #|
    #|Testing these non separator pipes.
    #|
    #|| Fancy | maybe | hu\|glu |
    #||-------|-------|-------|
    #|| *a | b* | `code |` | [bl|a] |
    #|| not \| two cols | $\sqrt(x^2 - 1)$ |
    // #|| not \| two cols | **sorry, NO mAtH YeT** |
    #|
    #|[bl|a]: https://example.org
    #|
    #|
    #|A table with changing labels and alignement:
    #|
    #| | h1  |  h2 |
    #| |-----|:---:|
    #| | 1   | 2   |
    #| | h3  | h4  |
    #| |:----|----:|
    #| | 3   | 4   |
    #|
    #|A simple header less table with left and right aligned columns
    #|
    #| |:--|--:|
    #| | 1 | 2 |
    #|
    #|The simplest table:
    #|
    #| | 1 | 2 |
    #|
    #|A header only table:
    #|
    #|| h1 | h2 |
    #||:--:|:--:|
    #|
    #|Maximal number of columns all rows defines number of colums:
    #|
    #|   | h1 | h2 | h3 |
    #|   |:---|:--:|---:|
    #|  |left | center | right |
    #|   | ha!  | four | columns | in fact |
    #|   |||||
    #|   ||||a|
    #|
    #|Header less table:
    #|
    #|  |header|less|
    #|  |this | is |
    #|
    #|Another quoted header less table with aligement
    #|
    #|> |----:|----:|
    #|> | header | less |
    #|> | again | aligned |
    #|
    #|This is an empty table with three columns:
    #|
    #| | |||
  let rendered = render(safe=false, strict=false, doc)
  it.write(rendered)
  it.snapshot(filename="table.html")
}

///|
test "basic" (it : @test.T) {
  let rendered = from_doc(safe=false, Doc::from_string(test_basic_md_str))
  it.write(rendered)
  it.snapshot(filename="basic.html")
}

///|
test "spec" (it : @test.T) {
  let rendered = from_doc(safe=false, Doc::from_string(test_spec_md_str))
  it.write(rendered)
  it.snapshot(filename="spec.html")
}

///| Test for raw HTML handling in safe mode
test "raw html in safe mode" (it : @test.T) {
  let doc =
    #|## Raw HTML in safe mode
    #|
    #|<div>This is raw HTML</div>
    #|
    #|<script>alert('hello');</script>
    #|
    #|Inline <span>HTML</span> elements.

  // Render with safe=true to test HTML omission
  let rendered = from_doc(safe=true, Doc::from_string(doc))
  it.write(rendered)
  it.snapshot(filename="raw_html_safe_mode.html")
}

///| Test for comments
test "html with comments" (it : @test.T) {
  let doc =
    #|## HTML with comments
    #|
    #|<!-- This is a comment -->
    #|
    #|Regular text.
    #|
    #|<!-- 
    #|  Multi-line comment
    #|-->
  let rendered = from_doc(safe=false, Doc::from_string(doc))
  it.write(rendered)
  it.snapshot(filename="html_comments.html")
}

///| Test for strict mode HTML
test "strict mode html" (it : @test.T) {
  let doc =
    #|<p>This paragraph is valid HTML.</p>
    #|
    #|<p>This paragraph is missing a closing tag.
    #|
    #|<div>
    #|  <p>Nested elements</p>
    #|</div>
  let rendered = from_doc(safe=false, Doc::from_string(doc, strict=true))
  it.write(rendered)
  it.snapshot(filename="strict_mode_html.html")
}

///| Test XHTML rendering
test "xhtml rendering" (it : @test.T) {
  let doc =
    #|## Thematic breaks
    #|
    #|---
    #|
    #|***
    #|
    #|___

  // Test xhtml rendering
  let rendered = xhtml_renderer(safe=true).doc_to_string(Doc::from_string(doc))
  it.write(rendered)
  it.snapshot(filename="xhtml_rendering.html")
}

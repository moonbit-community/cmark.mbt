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
  let rendered = from_doc!(safe=false, Doc::from_string(strict=false, doc))
  it.write(rendered)
  it.snapshot!(filename="task_list.html")
}

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
  let rendered = from_doc!(safe=false, Doc::from_string(strict=false, doc))
  it.write(rendered)
  it.snapshot!(filename="strikethrough.html")
}

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
  let rendered = from_doc!(safe=false, Doc::from_string(strict=false, doc))
  it.write(rendered)
  it.snapshot!(filename="footnote.html")
}

test "basic" (it : @test.T) {
  let rendered = from_doc!(safe=false, Doc::from_string(test_base_md_str))
  it.write(rendered)
  it.snapshot!(filename="basic.html")
}

///|
test "folder_none" {
  let folder = @cmark.Folder::new()
  inspect(@cmark.Folder::none(folder, 1, "test"), content="Default")
}

///|
test "fold_block with blank line" {
  let folder = @cmark.Folder::new()
  let block = @cmark.Block::BlankLine(@cmark.Node::new(""))
  inspect(folder.fold_block(0, block), content="0")
}

///|
test "fold_block with paragraph" {
  let folder = @cmark.Folder::new()
  let block = @cmark.Block::Paragraph(
    @cmark.Node::new({
      leading_indent: 0,
      inline: @cmark.Inline::Text(@cmark.Node::new("test")),
      trailing_blanks: "",
    }),
  )
  inspect(folder.fold_block(0, block), content="0")
}

///|
test "fold_block with heading" {
  let folder = @cmark.Folder::new()
  let heading = @cmark.Block::Heading(
    @cmark.Node::new({
      inline: @cmark.Inline::Text(@cmark.Node::new("test")),
      level: 1,
      layout: @cmark.BlockHeadingLayout::Atx(
        @cmark.BlockHeadingAtxLayout::default(),
      ),
      id: None,
    }),
  )
  inspect(folder.fold_block(0, heading), content="0")
}

///|
test "fold_block with blockquote" {
  let folder = @cmark.Folder::new()
  let quote = @cmark.Block::BlockQuote(
    @cmark.Node::new({
      indent: 0,
      block: @cmark.Block::Paragraph(
        @cmark.Node::new({
          leading_indent: 0,
          inline: @cmark.Inline::Text(@cmark.Node::new("test")),
          trailing_blanks: "",
        }),
      ),
    }),
  )
  inspect(folder.fold_block(0, quote), content="0")
}

///|
test "fold_block with blocks" {
  let folder = @cmark.Folder::new()
  let blocks = @cmark.Block::Blocks(
    @cmark.Node::new(
      @cmark.Seq::from_array([
        @cmark.Block::Paragraph(
          @cmark.Node::new({
            leading_indent: 0,
            inline: @cmark.Inline::Text(@cmark.Node::new("test1")),
            trailing_blanks: "",
          }),
        ),
        @cmark.Block::Paragraph(
          @cmark.Node::new({
            leading_indent: 0,
            inline: @cmark.Inline::Text(@cmark.Node::new("test2")),
            trailing_blanks: "",
          }),
        ),
      ]),
    ),
  )
  inspect(folder.fold_block(0, blocks), content="0")
}

///|
test "fold_doc with empty block" {
  let folder = @cmark.Folder::new()
  let empty_doc = @cmark.Doc::empty()
  let _ = folder.fold_doc((), empty_doc)

}

///|
test "fold_doc with simple paragraph" {
  let folder = @cmark.Folder::new()
  let doc = @cmark.Doc::from_string("Hello world")
  let _ = folder.fold_doc((), doc)

}

///|
test "folder block with table" {
  let folder = @cmark.Folder::new()
  let table = @cmark.Block::ExtTable(
    @cmark.Node::new({
      indent: 0,
      col_count: 2,
      rows: @cmark.Seq::from_array([
        (
          @cmark.Node::new(
            @cmark.Header(
              @cmark.Seq::from_array([
                (
                  @cmark.Inline::Text(@cmark.Node::new("Header")),
                  @cmark.TableCellLayout(("", "")),
                ),
              ]),
            ),
          ),
          "",
        ),
        (
          @cmark.Node::new(
            @cmark.Sep(
              @cmark.Seq::from_array([
                @cmark.Node::new((Some(@cmark.TableAlign::Left), 3)),
              ]),
            ),
          ),
          "",
        ),
        (
          @cmark.Node::new(
            @cmark.Data(
              @cmark.Seq::from_array([
                (
                  @cmark.Inline::Text(@cmark.Node::new("Data")),
                  @cmark.TableCellLayout(("", "")),
                ),
              ]),
            ),
          ),
          "",
        ),
      ]),
    }),
  )
  let result = folder.fold_block(0, table)
  inspect(result, content="0")
}

///|
test "folder block with footnote definition" {
  let folder = @cmark.Folder::new()
  let footnote = @cmark.Block::ExtFootnoteDefinition(
    @cmark.Node::new({
      indent: 0,
      label: {
        meta: @cmark_base.Meta::none(),
        key: "1",
        text: @cmark.Seq::empty(),
      },
      defined_label: None,
      block: @cmark.Block::empty(),
    }),
  )
  let result = folder.fold_block(0, footnote)
  inspect(result, content="0")
}

///|
test "folder fold_block with default block handler" {
  let folder = @cmark.Folder::new(block=fn(_self, acc, _b) {
    @cmark.Folder::ret(acc)
  })
  let block = @cmark.Block::empty()
  inspect(folder.fold_block(0, block), content="0")
}

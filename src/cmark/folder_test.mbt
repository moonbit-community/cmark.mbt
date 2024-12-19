test "folder_none" {
  let folder = Folder::new()
  inspect!(Folder::none(folder, 1, "test"), content="Default")
}

test "fold_block with blank line" {
  let folder = Folder::new()
  let block = Block::BlankLine(Node::new(""))
  inspect!(folder.fold_block!(0, block), content="0")
}

test "fold_block with paragraph" {
  let folder = Folder::new()
  let block = Block::Paragraph(
    Node::new({
      leading_indent: 0,
      inline: Inline::Text(Node::new("test")),
      trailing_blanks: "",
    }),
  )
  inspect!(folder.fold_block!(0, block), content="0")
}

test "fold_block with heading" {
  let folder = Folder::new()
  let heading = Block::Heading(
    Node::new({
      inline: Inline::Text(Node::new("test")),
      level: 1,
      layout: BlockHeadingLayout::Atx(BlockHeadingAtxLayout::default()),
      id: None,
    }),
  )
  inspect!(folder.fold_block!(0, heading), content="0")
}

test "fold_block with blockquote" {
  let folder = Folder::new()
  let quote = Block::BlockQuote(
    Node::new({
      indent: 0,
      block: Block::Paragraph(
        Node::new({
          leading_indent: 0,
          inline: Inline::Text(Node::new("test")),
          trailing_blanks: "",
        }),
      ),
    }),
  )
  inspect!(folder.fold_block!(0, quote), content="0")
}

test "fold_block with blocks" {
  let folder = Folder::new()
  let blocks = Block::Blocks(
    Node::new([
      Block::Paragraph(
        Node::new({
          leading_indent: 0,
          inline: Inline::Text(Node::new("test1")),
          trailing_blanks: "",
        }),
      ),
      Block::Paragraph(
        Node::new({
          leading_indent: 0,
          inline: Inline::Text(Node::new("test2")),
          trailing_blanks: "",
        }),
      ),
    ]),
  )
  inspect!(folder.fold_block!(0, blocks), content="0")
}

test "fold_doc with empty block" {
  let folder = Folder::new()
  let empty_doc = Doc::empty()
  let _ = folder.fold_doc!((), empty_doc)

}

test "fold_doc with simple paragraph" {
  let folder = Folder::new()
  let doc = Doc::from_string("Hello world")
  let _ = folder.fold_doc!((), doc)

}

test "folder block with table" {
  let folder = Folder::new()
  let table = Block::ExtTable(
    Node::new({
      indent: 0,
      col_count: 2,
      rows: [
        (
          Node::new(
            TableRow::Header([(Inline::Text(Node::new("Header")), ("", ""))]),
          ),
          "",
        ),
        (Node::new(TableRow::Sep([Node::new((Some(TableAlign::Left), 3))])), ""),
        (
          Node::new(
            TableRow::Data([(Inline::Text(Node::new("Data")), ("", ""))]),
          ),
          "",
        ),
      ],
    }),
  )
  let result = folder.fold_block!(0, table)
  inspect!(result, content="0")
}

test "folder block with footnote definition" {
  let folder = Folder::new()
  let footnote = Block::ExtFootnoteDefinition(
    Node::new({
      indent: 0,
      label: { meta: @rami3l/cmark/cmark_base.Meta::none(), key: "1", text: [] },
      defined_label: None,
      block: Block::empty(),
    }),
  )
  let result = folder.fold_block!(0, footnote)
  inspect!(result, content="0")
}

test "folder fold_block with default block handler" {
  let folder = Folder::new(block=fn(_self, acc, _b) { Folder::ret(acc) })
  let block = Block::empty()
  inspect!(folder.fold_block!(0, block), content="0")
}

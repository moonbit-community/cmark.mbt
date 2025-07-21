///|
test "mapper ret function" {
  // Test ret function by passing in different types of values
  let int_result = Mapper::ret(42)
  inspect(int_result, content="Map(Some(42))")
  let str_result = Mapper::ret("hello")
  inspect(str_result, content="Map(Some(\"hello\"))")
  let bool_result = Mapper::ret(true)
  inspect(bool_result, content="Map(Some(true))")
}

///|
test "mapper delete function" {
  // Test delete function to ensure it returns None
  let delete_result : MapperResult[Unit] = Mapper::delete()
  inspect(delete_result, content="Map(None)")
}

///|
test "Default for MapperResult" {
  // Test Default impl
  let default_result : MapperResult[Int] = MapperResult::default()
  inspect(default_result, content="Default")
}

///|
test "mapper_none" {
  // Create a new Mapper with default parameters
  let mapper = Mapper::new()
  // Call none with any value to trigger line 44
  inspect(mapper.none(42), content="Default")
}

///|
test "map_inline with Link returns None when text is None" {
  // Create a mapper that returns None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let text = Inline::Text(Node::new("link text"))
  let link_def = LinkDefinition::new()
  let reference = ReferenceKind::Inline(Node::new(link_def))
  let link = Inline::Link(Node::new(InlineLink::new(text, reference)))
  let result = mapper.map_inline(link)
  inspect(result, content="None")
}

///|
test "map_inline with StrongEmphasis" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("strongly emphasized text"))
  let strong = Inline::StrongEmphasis(Node::new({ delim: '*', inline: text }))
  let result = mapper.map_inline(strong)
  inspect(
    result,
    content=(
      #|Some(StrongEmphasis(Node::new({delim: '*', inline: Text(Node::new("strongly emphasized text"))})))
    ),
  )
}

///|
test "map_inline with StrongEmphasis returns None when inner inline is None" {
  // Create a mapper that returns None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let text = Inline::Text(Node::new("strongly emphasized text"))
  let strong = Inline::StrongEmphasis(Node::new({ delim: '*', inline: text }))
  let result = mapper.map_inline(strong)
  inspect(result, content="None")
}

///|
test "map_inline with Emphasis" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("emphasized text"))
  // Create Emphasis with the correct structure
  let emphasis = Inline::Emphasis(Node::new({ delim: '*', inline: text }))
  let result = mapper.map_inline(emphasis)
  inspect(
    result,
    content=(
      #|Some(Emphasis(Node::new({delim: '*', inline: Text(Node::new("emphasized text"))})))
    ),
  )
}

///|
test "map_inline with Emphasis returns None when inner text is None" {
  // Create a mapper that returns None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let text = Inline::Text(Node::new("emphasized text"))
  let emphasis = Inline::Emphasis(Node::new({ delim: '*', inline: text }))
  let result = mapper.map_inline(emphasis)
  inspect(result, content="None")
}

///|
test "panic block_ext_none raises error" {
  let mapper = Mapper::new()
  let block = Block::empty()
  let _ = mapper.block_ext_none(block)

}

///|
test "panic inline_ext_none raises error" {
  let mapper = Mapper::new()
  let inline = Inline::empty()
  let _ = mapper.inline_ext_none(inline)

}

///|
test "map_inline default case" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("hello"))
  inspect(mapper.map_inline(text), content="Some(Text(Node::new(\"hello\")))")
}

///|
test "map_doc with empty document" {
  let mapper = Mapper::new()
  let doc = Doc::empty()
  let result = mapper.map_doc(doc)
  inspect(result.block, content="Blocks(Node::new(Seq[[]]))")
}

///|
test "map_block blocks" {
  // Test blocks mapping
  let mapper = Mapper::new()
  let blocks = Block::Blocks(Node::new(Seq::empty()))
  inspect(mapper.map_block(blocks), content="None")
}

///|
test "map_block with default case" {
  let mapper = Mapper::new()
  let block = Block::BlankLine(Node::new(""))
  let result = mapper.map_block(block)
  inspect(result, content="Some(BlankLine(Node::new(\"\")))")
}

///|
test "map_block with blocks" {
  let mapper = Mapper::new()
  let block = Block::Blocks(
    Node::new(Seq::from_array([Block::BlankLine(Node::new(""])])),
  )
  let result = mapper.map_block(block)
  inspect(
    result,
    content=(
      #|Some(Blocks(Node::new(Seq[[BlankLine(Node::new(""]]]))))
    ),
  )
}

///|
test "map_block with paragraph" {
  let mapper = Mapper::new()
  let paragraph = Block::Paragraph(
    Node::new({
      leading_indent: 0,
      inline: Inline::Text(Node::new("paragraph")),
      trailing_blanks: "",
    }),
  )
  let result = mapper.map_block(paragraph)
  @json.inspect(result, content=[
    {
      "$tag": "Paragraph",
      "0": [
        {
          "leading_indent": 0,
          "inline": { "$tag": "Text", "0": ["paragraph"] },
          "trailing_blanks": "",
        },
      ],
    },
  ])
}

///|
test "map_block with paragraph with empty inline" {
  let paragraph = Block::Paragraph(
    Node::new({
      leading_indent: 0,
      inline: Inline::empty(),
      trailing_blanks: "",
    }),
  )

  // Create a mapper that will return None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let result = mapper.map_block(paragraph)
  inspect(result, content="None")
}

///|
test "mapper map_inline identity" {
  let text = Inline::Text(Node::new("text"))
  let mapper = Mapper::new()
  inspect(
    mapper.map_inline(text),
    content=(
      #|Some(Text(Node::new("text")))
    ),
  )
}

///|
test "mapper map_block identity" {
  let block = Block::BlankLine(Node::new(""))
  let mapper = Mapper::new()
  inspect(
    mapper.map_block(block),
    content=(
      #|Some(BlankLine(Node::new("")))
    ),
  )
}

///|
test "map_inline with Image" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("alt text"))
  // Create the link definition with the proper type for the dest parameter
  let link_def = LinkDefinition::new()
  let reference = ReferenceKind::Inline(Node::new(link_def))
  let image = Inline::Image(Node::new(InlineLink::new(text, reference)))
  let result = mapper.map_inline(image)
  inspect(
    result,
    content=(
      #|Some(Image(Node::new({text: Text(Node::new("alt text")), reference: Inline(Node::new({layout: {indent: 0, angled_dest: false, before_dest: Seq[[]], after_dest: Seq[[]], title_open_delim: '"', after_title: Seq[[]]}, label: None, defined_label: None, dest: None, title: None}))})))
    ),
  )
}

///|
test "map_inline with Link" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("link text"))
  let link_def = LinkDefinition::new()
  let reference = ReferenceKind::Inline(Node::new(link_def))
  let link = Inline::Link(Node::new(InlineLink::new(text, reference)))
  let result = mapper.map_inline(link)
  inspect(
    result,
    content=(
      #|Some(Link(Node::new({text: Text(Node::new("link text")), reference: Inline(Node::new({layout: {indent: 0, angled_dest: false, before_dest: Seq[[]], after_dest: Seq[[]], title_open_delim: '"', after_title: Seq[[]]}, label: None, defined_label: None, dest: None, title: None}))})))
    ),
  )
}

///|
test "map_inline with Emphasis" {
  let mapper = Mapper::new()
  let text = Inline::Text(Node::new("emphasized text"))
  // Create Emphasis with the correct structure
  let emphasis = Inline::Emphasis(Node::new({ delim: '*', inline: text }))
  let result = mapper.map_inline(emphasis)
  inspect(
    result,
    content=(
      #|Some(Emphasis(Node::new({delim: '*', inline: Text(Node::new("emphasized text"))})))
    ),
  )
}

///|
test "map_inline with StrongEmphasis with None inline result" {
  let strong = Inline::StrongEmphasis(
    Node::new({ delim: '*', inline: Inline::Text(Node::new("strong text")) }),
  )

  // Create a mapper that returns None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let result = mapper.map_inline(strong)
  inspect(result, content="None")
}

///|
test "map_inline with Inlines" {
  let mapper = Mapper::new()
  let seq = Seq::from_array([
    Inline::Text(Node::new("text 1")),
    Inline::Text(Node::new("text 2")),
  ])
  let inlines = Inline::Inlines(Node::new(seq))
  let result = mapper.map_inline(inlines)
  inspect(
    result,
    content="Some(Inlines(Node::new(Seq[[Text(Node::new(\"text 1\"]], Text(Node::new(\"text 2\"))]))))",
  )
}

///|
test "map_inline with Inlines that becomes empty" {
  let seq = Seq::from_array([
    Inline::Text(Node::new("text 1")),
    Inline::Text(Node::new("text 2")),
  ])
  let inlines = Inline::Inlines(Node::new(seq))

  // Create a mapper that returns None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let result = mapper.map_inline(inlines)
  inspect(result, content="None")
}

///|
test "map_inline with ExtStrikethrough" {
  let mapper = Mapper::new()
  let strikethrough = Inline::ExtStrikethrough(
    Node::new(Inline::Text(Node::new("strikethrough text"))),
  )
  let result = mapper.map_inline(strikethrough)
  inspect(
    result,
    content=(
      #|Some(ExtStrikethrough(Node::new(InlineStrikethrough(Text(Node::new("strikethrough text"))))))
    ),
  )
}

///|
test "map_inline with ExtStrikethrough with None inline result" {
  let strikethrough = Inline::ExtStrikethrough(
    Node::new(Inline::Text(Node::new("strikethrough text"))),
  )

  // Create a mapper that returns None for any inline
  let inline_fn = fn(_mapper : Mapper, _i : Inline) -> MapperResult[Inline] {
    Map(None)
  }
  let mapper = Mapper::new(inline=inline_fn)
  let result = mapper.map_inline(strikethrough)
  inspect(result, content="None")
}

///|
test "map_block with Heading" {
  let mapper = Mapper::new()
  let layout = BlockHeadingLayout::Atx({
    indent: 0,
    after_opening: "",
    closing: "",
  })
  let heading = Block::Heading(
    Node::new({
      level: 1,
      layout,
      inline: Inline::Text(Node::new("Heading")),
      id: None,
    }),
  )
  let result = mapper.map_block(heading)
  inspect(
    result,
    content=(
      #|Some(Heading(Node::new({layout: Atx({indent: 0, after_opening: "", closing: ""}), level: 1, inline: Text(Node::new("Heading")), id: None})))
    ),
  )
}

///|
test "map_block with BlockQuote" {
  let mapper = Mapper::new()
  let para = Block::Paragraph(
    Node::new({
      leading_indent: 0,
      inline: Inline::Text(Node::new("quoted text")),
      trailing_blanks: "",
    }),
  )
  let blockquote = Block::BlockQuote(Node::new({ indent: 0, block: para }))
  let result = mapper.map_block(blockquote)
  inspect(
    result,
    content="Some(BlockQuote(Node::new({indent: 0, block: Paragraph(Node::new({leading_indent: 0, inline: Text(Node::new(\"quoted text\")), trailing_blanks: \"\"}))})))",
  )
}

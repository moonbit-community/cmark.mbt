///|
test "mapper ret function" {
  // Test ret function by passing in different types of values
  let int_result = @cmark.Mapper::ret(42)
  inspect(int_result, content="Map(Some(42))")
  let str_result = @cmark.Mapper::ret("hello")
  inspect(str_result, content="Map(Some(\"hello\"))")
  let bool_result = @cmark.Mapper::ret(true)
  inspect(bool_result, content="Map(Some(true))")
}

///|
test "mapper delete function" {
  // Test delete function to ensure it returns None
  let delete_result : @cmark.MapperResult[Unit] = @cmark.Mapper::delete()
  inspect(delete_result, content="Map(None)")
}

///|
test "Default for MapperResult" {
  // Test Default impl
  let default_result : @cmark.MapperResult[Int] = @cmark.MapperResult::default()
  inspect(default_result, content="Default")
}

///|
test "mapper_none" {
  // Create a new Mapper with default parameters
  let mapper = @cmark.Mapper::new()
  // Call none with any value to trigger line 44
  inspect(mapper.none(42), content="Default")
}

///|
test "map_inline with Link returns None when text is None" {
  // Create a mapper that returns None for any inline
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    @cmark.Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let text = @cmark.Inline::Text(@cmark.Node::new("link text"))
  let link_def = @cmark.LinkDefinition::new()
  let reference = @cmark.ReferenceKind::Inline(@cmark.Node::new(link_def))
  let link = @cmark.Inline::Link(
    @cmark.Node::new(@cmark.InlineLink::new(text, reference)),
  )
  let result = mapper.map_inline(link)
  inspect(result, content="None")
}

///|
test "map_inline with StrongEmphasis" {
  let mapper = @cmark.Mapper::new()
  let text = @cmark.Inline::Text(@cmark.Node::new("strongly emphasized text"))
  let strong = @cmark.Inline::StrongEmphasis(
    @cmark.Node::new({ delim: '*', inline: text }),
  )
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
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let text = @cmark.Inline::Text(@cmark.Node::new("strongly emphasized text"))
  let strong = @cmark.Inline::StrongEmphasis(
    @cmark.Node::new({ delim: '*', inline: text }),
  )
  let result = mapper.map_inline(strong)
  inspect(result, content="None")
}

///|
test "map_inline with Emphasis" {
  let mapper = @cmark.Mapper::new()
  let text = @cmark.Inline::Text(@cmark.Node::new("emphasized text"))
  // Create Emphasis with the correct structure
  let emphasis = @cmark.Inline::Emphasis(
    @cmark.Node::new({ delim: '*', inline: text }),
  )
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
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let text = @cmark.Inline::Text(@cmark.Node::new("emphasized text"))
  let emphasis = @cmark.Inline::Emphasis(
    @cmark.Node::new({ delim: '*', inline: text }),
  )
  let result = mapper.map_inline(emphasis)
  inspect(result, content="None")
}

///|
test "panic block_ext_none raises error" {
  let mapper = @cmark.Mapper::new()
  let block = @cmark.Block::empty()
  let _ = mapper.block_ext_none(block)

}

///|
test "panic inline_ext_none raises error" {
  let mapper = @cmark.Mapper::new()
  let inline = @cmark.Inline::empty()
  let _ = mapper.inline_ext_none(inline)

}

///|
test "map_inline default case" {
  let mapper = @cmark.Mapper::new()
  let text = @cmark.Inline::Text(@cmark.Node::new("hello"))
  inspect(mapper.map_inline(text), content="Some(Text(Node::new(\"hello\")))")
}

///|
test "map_doc with empty document" {
  let mapper = @cmark.Mapper::new()
  let doc = @cmark.Doc::empty()
  let result = mapper.map_doc(doc)
  inspect(result.block, content="Blocks(Node::new(Seq([])))")
}

///|
test "map_block blocks" {
  // Test blocks mapping
  let mapper = @cmark.Mapper::new()
  let blocks = @cmark.Block::Blocks(@cmark.Node::new(@cmark.Seq::empty()))
  inspect(mapper.map_block(blocks), content="None")
}

///|
test "map_block with default case" {
  let mapper = @cmark.Mapper::new()
  let block = @cmark.Block::BlankLine(@cmark.Node::new(""))
  let result = mapper.map_block(block)
  inspect(result, content="Some(BlankLine(Node::new(\"\")))")
}

///|
test "map_block with blocks" {
  let mapper = @cmark.Mapper::new()
  let block = @cmark.Block::Blocks(
    @cmark.Node::new(
      @cmark.Seq::from_array([@cmark.Block::BlankLine(@cmark.Node::new(""))]),
    ),
  )
  let result = mapper.map_block(block)
  inspect(
    result,
    content=(
      #|Some(Blocks(Node::new(Seq([BlankLine(Node::new(""))]))))
    ),
  )
}

///|
test "map_block with paragraph" {
  let mapper = @cmark.Mapper::new()
  let paragraph = @cmark.Block::Paragraph(
    @cmark.Node::new({
      leading_indent: 0,
      inline: @cmark.Inline::Text(@cmark.Node::new("paragraph")),
      trailing_blanks: "",
    }),
  )
  let result = mapper.map_block(paragraph)
  @json.inspect(result, content=[
    [
      "Paragraph",
      [
        {
          "leading_indent": 0,
          "inline": ["Text", ["paragraph"]],
          "trailing_blanks": "",
        },
      ],
    ],
  ])
}

///|
test "map_block with paragraph with empty inline" {
  let paragraph = @cmark.Block::Paragraph(
    @cmark.Node::new({
      leading_indent: 0,
      inline: @cmark.Inline::empty(),
      trailing_blanks: "",
    }),
  )

  // Create a mapper that will return None for any inline
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let result = mapper.map_block(paragraph)
  inspect(result, content="None")
}

///|
test "mapper map_inline identity" {
  let text = @cmark.Inline::Text(@cmark.Node::new("text"))
  let mapper = @cmark.Mapper::new()
  inspect(
    mapper.map_inline(text),
    content=(
      #|Some(Text(Node::new("text")))
    ),
  )
}

///|
test "mapper map_block identity" {
  let block = @cmark.Block::BlankLine(@cmark.Node::new(""))
  let mapper = @cmark.Mapper::new()
  inspect(
    mapper.map_block(block),
    content=(
      #|Some(BlankLine(Node::new("")))
    ),
  )
}

///|
test "map_inline with Image" {
  let mapper = @cmark.Mapper::new()
  let text = @cmark.Inline::Text(@cmark.Node::new("alt text"))
  // Create the link definition with the proper type for the dest parameter
  let link_def = @cmark.LinkDefinition::new()
  let reference = @cmark.ReferenceKind::Inline(@cmark.Node::new(link_def))
  let image = @cmark.Inline::Image(
    @cmark.Node::new(@cmark.InlineLink::new(text, reference)),
  )
  let result = mapper.map_inline(image)
  inspect(
    result,
    content=(
      #|Some(Image(Node::new({text: Text(Node::new("alt text")), reference: Inline(Node::new({layout: {indent: 0, angled_dest: false, before_dest: Seq([]), after_dest: Seq([]), title_open_delim: '"', after_title: Seq([])}, label: None, defined_label: None, dest: None, title: None}))})))
    ),
  )
}

///|
test "map_inline with Link" {
  let mapper = @cmark.Mapper::new()
  let text = @cmark.Inline::Text(@cmark.Node::new("link text"))
  let link_def = @cmark.LinkDefinition::new()
  let reference = @cmark.ReferenceKind::Inline(@cmark.Node::new(link_def))
  let link = @cmark.Inline::Link(
    @cmark.Node::new(@cmark.InlineLink::new(text, reference)),
  )
  let result = mapper.map_inline(link)
  inspect(
    result,
    content=(
      #|Some(Link(Node::new({text: Text(Node::new("link text")), reference: Inline(Node::new({layout: {indent: 0, angled_dest: false, before_dest: Seq([]), after_dest: Seq([]), title_open_delim: '"', after_title: Seq([])}, label: None, defined_label: None, dest: None, title: None}))})))
    ),
  )
}

///|
test "map_inline with Emphasis" {
  let mapper = @cmark.Mapper::new()
  let text = @cmark.Inline::Text(@cmark.Node::new("emphasized text"))
  // Create Emphasis with the correct structure
  let emphasis = @cmark.Inline::Emphasis(
    @cmark.Node::new({ delim: '*', inline: text }),
  )
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
  let strong = @cmark.Inline::StrongEmphasis(
    @cmark.Node::new({
      delim: '*',
      inline: @cmark.Inline::Text(@cmark.Node::new("strong text")),
    }),
  )

  // Create a mapper that returns None for any inline
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let result = mapper.map_inline(strong)
  inspect(result, content="None")
}

///|
test "map_inline with Inlines" {
  let mapper = @cmark.Mapper::new()
  let seq = @cmark.Seq::from_array([
    @cmark.Inline::Text(@cmark.Node::new("text 1")),
    @cmark.Inline::Text(@cmark.Node::new("text 2")),
  ])
  let inlines = @cmark.Inline::Inlines(@cmark.Node::new(seq))
  let result = mapper.map_inline(inlines)
  inspect(
    result,
    content="Some(Inlines(Node::new(Seq([Text(Node::new(\"text 1\")), Text(Node::new(\"text 2\"))]))))",
  )
}

///|
test "map_inline with Inlines that becomes empty" {
  let seq = @cmark.Seq::from_array([
    @cmark.Inline::Text(@cmark.Node::new("text 1")),
    @cmark.Inline::Text(@cmark.Node::new("text 2")),
  ])
  let inlines = @cmark.Inline::Inlines(@cmark.Node::new(seq))

  // Create a mapper that returns None for any inline
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    @cmark.Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let result = mapper.map_inline(inlines)
  inspect(result, content="None")
}

///|
test "map_inline with ExtStrikethrough" {
  let mapper = @cmark.Mapper::new()
  let strikethrough = @cmark.Inline::ExtStrikethrough(
    @cmark.Node::new(
      @cmark.Inline::Text(@cmark.Node::new("strikethrough text")),
    ),
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
  let strikethrough = @cmark.Inline::ExtStrikethrough(
    @cmark.Node::new(
      @cmark.Inline::Text(@cmark.Node::new("strikethrough text")),
    ),
  )

  // Create a mapper that returns None for any inline
  let inline_fn = fn(
    _mapper : @cmark.Mapper,
    _i : @cmark.Inline,
  ) -> @cmark.MapperResult[@cmark.Inline] {
    Map(None)
  }
  let mapper = @cmark.Mapper::new(inline=inline_fn)
  let result = mapper.map_inline(strikethrough)
  inspect(result, content="None")
}

///|
test "map_block with Heading" {
  let mapper = @cmark.Mapper::new()
  let layout = @cmark.BlockHeadingLayout::Atx({
    indent: 0,
    after_opening: "",
    closing: "",
  })
  let heading = @cmark.Block::Heading(
    @cmark.Node::new({
      level: 1,
      layout,
      inline: @cmark.Inline::Text(@cmark.Node::new("Heading")),
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
  let mapper = @cmark.Mapper::new()
  let para = @cmark.Block::Paragraph(
    @cmark.Node::new({
      leading_indent: 0,
      inline: @cmark.Inline::Text(@cmark.Node::new("quoted text")),
      trailing_blanks: "",
    }),
  )
  let blockquote = @cmark.Block::BlockQuote(
    @cmark.Node::new({ indent: 0, block: para }),
  )
  let result = mapper.map_block(blockquote)
  inspect(
    result,
    content="Some(BlockQuote(Node::new({indent: 0, block: Paragraph(Node::new({leading_indent: 0, inline: Text(Node::new(\"quoted text\")), trailing_blanks: \"\"}))})))",
  )
}

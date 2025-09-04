///|
/// The type for CommonMark documents.
pub(all) struct Doc {
  nl : String
  block : Block
  defs : LabelDefs
} derive(Show, ToJson)

///|
pub fn Doc::new(
  nl? : String = "\n",
  defs? : LabelDefs = LabelDefs::new(),
  block : Block,
) -> Doc {
  { nl, block, defs }
}

///|
pub fn Doc::empty() -> Doc {
  Doc::new(Block::empty())
}

///|
pub fn Doc::from_string(
  defs? : LabelDefs = LabelDefs::new(),
  resolver? : LabelResolverFn = LabelContext::default_resolver,
  nested_links? : Bool = false,
  heading_auto_ids? : Bool = false,
  layout? : Bool = false,
  locs? : Bool = false,
  file? : FilePath = file_path_none,
  strict? : Bool = true,
  s : String,
) -> Doc {
  let p = Parser::new(
    defs~,
    resolver~,
    nested_links~,
    heading_auto_ids~,
    layout~,
    locs~,
    file~,
    strict~,
    s,
  )
  let (nl, doc) = p.parse_block()
  let block = p.block_struct_to_doc(doc)
  Doc::new(nl~, block, defs=p.defs)
}

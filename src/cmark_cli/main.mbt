///|
struct Options {
  safe : Bool
  strict : Bool
  backend_blocks : Bool
  format : String
}

///|
fn command() -> @argparse.Command {
  @argparse.Command(
    "cmark",
    about="Render CommonMark input as HTML.",
    version="0.4.4",
    flags=[
      FlagArg("safe", about="replace unsafe raw HTML and links with comments", conflicts_with=[
        "unsafe",
      ]),
      FlagArg("unsafe", about="allow raw HTML and unsafe links (default)", conflicts_with=[
        "safe",
      ]),
      FlagArg("relaxed", about="enable cmark.mbt syntax extensions"),
      FlagArg(
        "backend-blocks",
        about="render backend-specific fenced code blocks",
      ),
    ],
    options=[
      OptionArg("to", short='t', about="output format: html or xhtml", default_values=[
        "html",
      ]),
    ],
    positionals=[
      PositionArg(
        "file",
        about="file to read; use - or no file for stdin",
        num_args=@argparse.ValueRange(lower=0),
        allow_hyphen_values=true,
      ),
    ],
  )
}

///|
fn flag(matches : @argparse.Matches, name : String) -> Bool {
  match matches.flags.get(name) {
    Some(value) => value
    None => false
  }
}

///|
fn options_from_matches(matches : @argparse.Matches) -> Options {
  let format = match matches.values {
    { "to": [format], .. } => format
    _ => "html"
  }
  {
    safe: flag(matches, "safe"),
    strict: !flag(matches, "relaxed"),
    backend_blocks: flag(matches, "backend-blocks"),
    format,
  }
}

///|
fn input_paths(matches : @argparse.Matches) -> Array[String] {
  match matches.values {
    { "file": files, .. } if !files.is_empty() => files
    _ => ["-"]
  }
}

///|
async fn read_input(path : String) -> String {
  if path == "-" {
    @stdio.stdin.read_all().text()
  } else {
    @fs.read_file(path).text()
  }
}

///|
fn render_input(input : String, options : Options) -> String raise {
  match options.format {
    "html" =>
      @cmark_html.render(
        backend_blocks=options.backend_blocks,
        safe=options.safe,
        strict=options.strict,
        input,
      )
    "xhtml" =>
      @cmark_html.xhtml_renderer(
        backend_blocks=options.backend_blocks,
        safe=options.safe,
      ).doc_to_string(@cmark.Doc::from_string(input, strict=options.strict))
    format =>
      fail("unsupported output format: \{format}; expected html or xhtml")
  }
}

///|
async fn main {
  let matches = command().parse()
  let options = options_from_matches(matches)
  for path in input_paths(matches) {
    @stdio.stdout.write(render_input(read_input(path), options))
  }
}

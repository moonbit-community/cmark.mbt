# cmark

[![Build Status](https://github.com/moonbit-community/cmark/workflows/check/badge.svg)](https://github.com/moonbit-community/cmark/actions)
[![Coverage](https://img.shields.io/coveralls/github/moonbit-community/cmark?style=flat-square)](https://coveralls.io/github/moonbit-community/cmark)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue?style=flat-square)](LICENSE)
[![Package](https://img.shields.io/badge/moonbit-package-orange?style=flat-square)](https://mooncakes.io/docs/#/zh-cn/packages/rami3l/cmark)

A powerful [CommonMark][CommonMark specification] toolkit for the MoonBit programming language, 
originally inspired by and started as a MoonBit rewrite of the [`cmarkit`] library from the OCaml ecosystem.

## Features

`cmark` is a full-featured CommonMark parser and renderer that supports:

### Core CommonMark Features
- **Complete CommonMark syntax support** - All standard Markdown elements
- **Source-aware parsing** - Best-effort layout preservation for round-trip editing
- **Flexible rendering** - Extensible renderer API with built-in HTML output

### Extended Syntax Support
- ✅ **Strikethroughs** - `~~deleted text~~`
- ✅ **Task lists** - `- [x] completed task`
- ✅ **Footnotes** - `Text[^1]` with `[^1]: footnote content`
- ✅ **Tables** - GitHub-style table syntax
- ✅ **Inline math** - `$E = mc^2$`
- ✅ **Math blocks** - `$$\LaTeX{}$$` formula blocks

### Performance & Reliability
- **Multi-target support** - Runs on WASM, WASM-GC, JavaScript, and native targets
- **Comprehensive testing** - Extensive test suite with CommonMark specification compliance
- **Performance benchmarks** - Continuously monitored performance across targets

## Installation

Add `cmark` to your MoonBit project's `moon.mod.json`:

```json
{
  "deps": {
    "rami3l/cmark": "0.3.0"
  }
}
```

Or install it using the MoonBit CLI:

```bash
moon add rami3l/cmark
```

## Quick Start

### Basic Parsing

```moonbit
// Parse a CommonMark document
let doc = @cmark.Doc::from_string(
  #|# Hello World
  #|
  #|This is a **bold** paragraph with [a link](https://example.com).
  #|
  #|- List item 1
  #|- List item 2
)

// The doc now contains the parsed AST ready for processing
```

### HTML Rendering 

```moonbit
// Parse and render to HTML in one step
let html = @cmark_html.render(
  safe=false,
  strict=false,
  #|# Hello World
  #|
  #|This is a **bold** paragraph.
)

// Output: <h1>Hello World</h1>\n<p>This is a <strong>bold</strong> paragraph.</p>\n
```

### Advanced Usage with Extended Features

```moonbit
// Enable extended features by setting strict=false
let doc = @cmark.Doc::from_string(
  strict=false,  // Enables task lists, tables, footnotes, etc.
  #|# Project Tasks
  #|
  #|## Math Example
  #|The formula $E = mc^2$ shows mass-energy equivalence.
  #|
  #|## Todo List
  #|- [x] Parse CommonMark
  #|- [x] Add table support  
  #|- [ ] Add syntax highlighting
  #|
  #|| Feature    | Status |
  #||------------|--------|
  #|| Tables     | ✅      |
  #|| Footnotes  | ✅      |
  #|| Math       | ✅      |
)

let html = @cmark_html.from_doc(safe=false, doc)
// Generates HTML with tables, math, and task lists
```

### Document Transformation

```moonbit
// Transform documents using the Mapper API
let modified_doc = @cmark.Mapper::map_doc(doc, {
  // Custom transformation logic
  map_inline: fn(inline) { /* modify inline elements */ },
  map_block: fn(block) { /* modify block elements */ },
})
```

## API Overview

The `cmark` package is organized into several focused modules:

### Core Modules

- **`@cmark`** - Main parsing and AST manipulation
- **`@cmark_html`** - HTML rendering (see [HTML renderer docs](src/cmark_html/README.mbt.md))
- **`@cmark_renderer`** - Base renderer abstraction for creating custom outputs

### Utility Modules

- **`@cmark_base`** - Low-level parsing utilities
- **`@char`** - Character classification and HTML entity handling

## Building from Source

### Prerequisites

1. **MoonBit toolchain** - Install from [moonbitlang.com](https://www.moonbitlang.com/download)
2. **Python 3.x** - Required for build scripts ([download here](https://www.python.org/downloads/))

### Build Commands

```bash
# Install dependencies and build
moon update
moon build

# Run the complete test suite
moon test

# Run tests with coverage
moon test --enable-coverage
moon coverage report

# Format code
moon fmt

# Type checking with warnings as errors
moon check --deny-warn
```

### Benchmarking

The project includes comprehensive benchmarks across different targets:

```bash
cd cmarkwrap
moon run --target=wasm-gc --release
```

View [live benchmarks](https://moonbit-community.github.io/cmark/bench-pages/).

## Documentation

Detailed API documentation is available for each module:

- [Core parser documentation](src/cmark/README.mbt.md) - Comprehensive examples of parsing different Markdown elements
- [HTML renderer documentation](src/cmark_html/README.mbt.md) - HTML rendering examples and configuration
- [Base utilities documentation](src/cmark_base/README.mbt.md) - Low-level parsing utilities

## Contributing

We welcome contributions! To get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes (`moon test`)
4. **Format** your code (`moon fmt`)
5. **Commit** your changes (`git commit -m 'Add amazing feature'`)
6. **Push** and create a **Pull Request**

### Development Guidelines

- Follow the existing code style (enforced by `moon fmt`)
- Add tests for new features
- Update documentation for API changes
- Ensure all CI checks pass

## Performance

`cmark` is designed for high performance across multiple targets:

- **WASM/WASM-GC** - Excellent performance for web applications
- **JavaScript** - Native browser integration
- **Native** - Maximum performance for server applications

Continuous benchmarking ensures performance regressions are caught early.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

`cmark` builds upon the excellent work of these projects:

- **Daniel Bünzli** for the [`cmarkit`] project - Original OCaml implementation that inspired this work
- **John MacFarlane** for the [CommonMark specification] and the [`cmark`] reference implementation
- **Martin Mitáš** for the [`md4c`] project - High-performance C implementation

## Related Projects

- [`cmarkit`] - OCaml CommonMark implementation (original inspiration)
- [`cmark`] - Reference C implementation of CommonMark
- [`md4c`] - High-performance C Markdown parser

[CommonMark specification]: https://spec.commonmark.org/
[`cmark`]: https://github.com/commonmark/cmark
[`cmarkit`]: https://github.com/dbuenzli/cmarkit
[`md4c`]: https://github.com/mity/md4c

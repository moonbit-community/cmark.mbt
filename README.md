# 🚀 cmark

[![CI Status](https://github.com/moonbit-community/cmark/actions/workflows/check.yml/badge.svg)](https://github.com/moonbit-community/cmark/actions/workflows/check.yml)
[![Coverage](https://coveralls.io/repos/github/moonbit-community/cmark/badge.svg)](https://coveralls.io/github/moonbit-community/cmark)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-v0.3.0-blue)](https://moonbitlang.com)

A powerful and fast [CommonMark][CommonMark specification] parser and renderer toolkit for [MoonBit](https://moonbitlang.com), providing comprehensive markdown processing capabilities with excellent source preservation and extensibility.

Originally inspired by the [`cmarkit`] library from the OCaml ecosystem, this implementation offers high-performance markdown parsing and rendering with rich feature support.

## ✨ Features

### Core Capabilities
- **🔥 Fast CommonMark Parsing**: Efficient parsing of standard CommonMark syntax
- **🎯 Source-Aware Layout Preservation**: Maintains original formatting and layout information
- **🔄 Flexible Rendering**: Extensible renderer API with built-in HTML output
- **🧩 Extension Support**: Support for popular markdown extensions

### Supported Syntax

#### Standard CommonMark
- Headers (ATX and Setext)
- Paragraphs and line breaks
- Emphasis and strong emphasis
- Links and images
- Code spans and blocks
- Lists (ordered and unordered)
- Block quotes
- Thematic breaks
- Raw HTML

#### Extensions
- ✅ **Task lists** (`- [x] Completed task`)
- 📊 **Tables** (GitHub-style pipe tables)
- ~~**Strikethroughs**~~ (`~~text~~`)
- 📝 **Footnotes** (`[^1]: footnote content`)
- 🧮 **Math blocks** (`$$...$$`)
- ⚡ **Inline math** (`$...$`)

## 🚀 Quick Start

### Installation

Add to your `moon.mod.json`:

```json
{
  "deps": {
    "rami3l/cmark": "^0.3.0"
  }
}
```

### Basic Usage

#### Simple Parsing and Rendering

```moonbit
// Parse markdown and render to HTML
fn main {
  let markdown = #|
    # Hello World
    
    This is **bold** and *italic* text.
    
    - Item 1
    - Item 2
      - Nested item
  
  let doc = @cmark.Doc::from_string(markdown)
  let html = @cmark_html.from_doc(safe=true, doc)
  println(html)
}
```

Output:
```html
<h1>Hello World</h1>
<p>This is <strong>bold</strong> and <em>italic</em> text.</p>
<ul>
<li>Item 1</li>
<li>Item 2
<ul>
<li>Nested item</li>
</ul>
</li>
</ul>
```

#### Working with Extensions

```moonbit
fn parse_with_extensions {
  let markdown = #|
    # Math Example
    
    Inline math: $E = mc^2$
    
    Block math:
    $$
    \sum_{i=1}^{n} i = \frac{n(n+1)}{2}
    $$
    
    | Name | Age | City |
    |------|-----|------|
    | John | 30  | NYC  |
    | Jane | 25  | LA   |
    
    - [x] Completed task
    - [ ] Pending task
  
  // Parse with extensions enabled
  let doc = @cmark.Doc::from_string(markdown, strict=false)
  let html = @cmark_html.from_doc(safe=true, doc)
  println(html)
}
```

### Advanced Usage

#### Custom Document Processing

```moonbit
fn process_document {
  let markdown = "# Title\n\nSome content with [link](https://example.com)"
  let doc = @cmark.Doc::from_string(markdown)
  
  // Access the document structure
  match doc.block {
    Blocks(blocks) => {
      for block in blocks[0] {
        match block {
          Heading(heading) => println("Found heading: level \{heading[0].level}")
          Paragraph(para) => println("Found paragraph")
          _ => ()
        }
      }
    }
    _ => ()
  }
}
```

## 📦 Package Structure

This toolkit is organized into several focused packages:

- **`cmark`** - Core parser and document representation
- **`cmark_html`** - HTML renderer implementation  
- **`cmark_renderer`** - Base renderer interface for custom outputs
- **`cmark_base`** - Low-level parsing utilities
- **`char`** - Character and text processing utilities

## 🔧 Building from Source

### Prerequisites

1. **MoonBit Toolchain**: Install from [moonbitlang.com](https://www.moonbitlang.com/download)
2. **Python**: Required for pre-build scripts ([python.org](https://www.python.org/downloads/))

### Build Commands

```bash
# Install dependencies and build
moon update
moon build

# Run tests
moon test

# Check code formatting
moon fmt

# Run with coverage
moon test --enable-coverage
moon coverage report -f summary
```

### Development Workflow

```bash
# Check for warnings (CI uses --deny-warn)
moon check --deny-warn

# Test across multiple targets
moon test --target wasm
moon test --target wasm-gc
moon test --target native

# Format code
moon fmt
```

## 📊 Performance

The toolkit includes comprehensive benchmarks comparing performance across different compilation targets:

- **Native**: Optimal performance for server-side processing
- **WASM**: Fast web-based markdown processing
- **WASM-GC**: Enhanced garbage collection for memory efficiency
- **JavaScript**: Browser compatibility

Benchmark results are automatically tracked in CI and available on the [benchmark dashboard](https://moonbit-community.github.io/cmark/bench-pages/).

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow the existing code style (enforced by `moon fmt`)
- Add tests for new features
- Update documentation for API changes
- Ensure all CI checks pass

## 📚 Documentation

- **[API Documentation](src/)** - Detailed package documentation
- **[CommonMark Specification](https://spec.commonmark.org/)** - Reference standard
- **[MoonBit Language Guide](https://www.moonbitlang.com/docs/)** - Language documentation

## 🙏 Acknowledgements

This project builds upon excellent prior work:

- **[Daniel Bünzli](https://github.com/dbuenzli)** for the [`cmarkit`] OCaml library that inspired this implementation
- **[John MacFarlane](https://github.com/jgm)** for the [CommonMark specification] and the original [`cmark`] reference implementation
- **[Martin Mitáš](https://github.com/mity)** for the [`md4c`] high-performance C parser
- **The MoonBit team** for creating an excellent language and toolchain

## 📄 License

Licensed under the [Apache License, Version 2.0](LICENSE).

```
Copyright 2024 cmark contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[CommonMark specification]: https://spec.commonmark.org/
[`cmark`]: https://github.com/commonmark/cmark
[`cmarkit`]: https://github.com/dbuenzli/cmarkit
[`md4c`]: https://github.com/mity/md4c

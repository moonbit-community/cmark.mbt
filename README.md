# cmark

Cmark is a [CommonMark][CommonMark specification] toolkit for the MoonBit programming language,
started as a MoonBit rewrite of the [`cmarkit`] library from the OCaml ecosystem.

So far, it supports the following use cases:

- Parsing CommonMark documents with best-effort source-aware layout preservation:
- Rendering CommonMark documents via the `Renderer` API, along with a ready-to-use HTML renderer.

Supported CommonMark features include:

- Vanilla CommonMark syntax;
- Common syntax extensions, including:
  - Strikethroughs
  - Task lists
  - Footnotes
  - Tables
  - Inline math
  - Math blocks

## Workspace

The root workspace contains two parallel modules:

- [`cmark/`](cmark/): the `moonbit-community/cmark` library, without an async dependency.
- [`cmark-cli/`](cmark-cli/): the native `moonbit-community/cmark-cli` renderer.

[`cmarkwrap/`](cmarkwrap/) keeps a separate benchmark workspace using the local library.

## Building

To begin, you will need to install a recent MoonBit toolchain.
To do so, please refer to instructions at MoonBit's [official website](https://www.moonbitlang.com/download).

Also, a Python installation is required to run the pre-build scripts.
You can find relevant instructions from Python's [official website](https://www.python.org/downloads/).

Once you have the toolchain installed, you can build this project by running the following command:

```sh
moon build
```

## CLI

The repository includes a native command-line renderer that follows the basic
`cmark` input model: read Markdown from stdin, `-`, or one or more file paths and
write rendered HTML to stdout.

```sh
printf '# Hello\n' | moon run cmark-cli -- -
moon run cmark-cli -- README.md
moon run cmark-cli -- --safe --to xhtml README.md
```

For reference comparisons, install the upstream CommonMark CLI and compare
against the MoonBit executable:

```sh
brew install cmark
printf '# Hello\n' | cmark --unsafe
printf '# Hello\n' | moon run cmark-cli -- -
```

## Testing

Run the library tests on a selected backend (wasm, wasm-gc, js, or native):

```sh
moon test -p moonbit-community/cmark/ --target wasm
```

Run the CLI unit and command-line tests on native:

```sh
moon test cmark-cli --target native
moon cram test cmark-cli/cram
```

## Acknowledgements

`cmark` is built on top several pre-existing projects. Thanks go to:

- Daniel Bünzli for the [`cmarkit`] project;
- John MacFarlane for the [CommonMark specification] and the [`cmark`] project;
- Martin Mitáš for the [`md4c`] project.

[CommonMark specification]: https://spec.commonmark.org/
[`cmark`]: https://github.com/commonmark/cmark
[`cmarkit`]: https://github.com/dbuenzli/cmarkit
[`md4c`]: https://github.com/mity/md4c

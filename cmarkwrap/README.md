# cmark benchmarks

This internal benchmark module belongs to the repository's root workspace and
calls the local cmark HTML renderer directly. It embeds the CommonMark spec at
build time, so no file I/O dependency or runtime working directory is required.

Run from the repository root:

```sh
moon run cmarkwrap --target native --release
```

Other supported targets are `js`, `wasm`, and `wasm-gc`. Each run measures the
spec repeated 100 and 200 times, with five samples per case, and writes one
benchmark-action JSON record per line to stdout. The entry point converts core
bench's mean time in microseconds to `ops/sec`.

The workflow collects these records into a JSON array for GitHub's benchmark
history. Existing backend labels and case names are retained so earlier results
remain comparable.

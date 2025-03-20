import benchmark from "benchmark";
import fs from "node:fs";
import url from "node:url";
import path from "node:path";

async function main() {
  const suite = new benchmark.Suite();

  const { render: cmarkJSInner } = await import(
    "./cmarkwrap/target/js/release/build/lib/lib.js"
  );
  function cmarkJS(doc) {
    return cmarkJSInner(doc);
  }

  const cmarkwrapWASM = await (async () => {
    let url_ = "./cmarkwrap/target/wasm-gc/release/build/lib/libopt.wasm";
    url_ = url.pathToFileURL(path.resolve(url_));
    return await WebAssembly.instantiateStreaming(
      fetch(url_),
      {},
      {
        builtins: ["js-string"],
        importedStringConstants: "_",
      },
    );
  })();
  const cmarkWASMInner = cmarkwrapWASM.instance.exports.render;
  function cmarkWASM(doc) {
    return cmarkWASMInner(doc);
  }

  const doc = fs.readFileSync("./src/data/test/spec.md", "utf8");

  const testCases = [
    ["spec * 100", doc.repeat(100)],
    ["spec * 200", doc.repeat(200)],
  ];
  const candidates = [cmarkJS, cmarkWASM];

  for (const [name, doc] of testCases) {
    for (const candidate of candidates) {
      suite.add(`${candidate.name}(${name})`, () => {
        candidate(doc);
      });
    }
  }

  suite.on("cycle", (event) => console.log(String(event.target))).run();
}

await main();

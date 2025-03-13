import benchmark from "benchmark";
import fs from "node:fs";
import shell from "shelljs";

const suite = new benchmark.Suite();

shell.exec("moon -C=cmarkwrap build --release --no-strip --target=wasm-gc,js");
shell.pushd("cmarkwrap/target/wasm-gc/release/build/lib/");
shell.exec(
  "wasm-tools strip lib.wasm | wasm-opt --enable-reference-types --enable-gc --enable-multivalue -o libopt.wasm -g --converge --gufa --generate-global-effects -O4 --monomorphize -O4 --flatten --flatten --rereloop -Oz -Oz -tnh -O4",
);
shell.popd();

const { render: cmarkJS } = await import(
  "./cmarkwrap/target/js/release/build/lib/lib.js"
);

// TODO: Enable this. This is not possible on Node.js yet...
// const cmarkwrapWASM = await (async () => {
//   var url_ = "./cmarkwrap/target/wasm-gc/release/build/lib/libopt.wasm";
//   url_ = url.pathToFileURL(path.resolve(url_));
//   return await WebAssembly.instantiateStreaming(
//     fetch(url_),
//     {},
//     {
//       builtins: ["js-string"],
//       importedStringConstants: "_",
//     },
//   );
// })();
// const cmarkWASM = cmarkwrapWASM.instance.exports.render;

const doc = fs.readFileSync("./src/data/test/spec.md", "utf8");
const doc100 = doc.repeat(100);
const doc200 = doc.repeat(200);

suite
  .add("cmarkJS(spec * 100)", () => {
    cmarkJS(doc100);
  })
  .add("cmarkJS(spec * 200)", () => {
    cmarkJS(doc200);
  })
  .on("cycle", (event) => {
    console.log(String(event.target));
  })
  .run();

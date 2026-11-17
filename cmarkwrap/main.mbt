///|
#cfg(target="js")
let ident = "cmarkJS"

///|
#cfg(target="wasm")
let ident = "cmarkWASM1"

///|
#cfg(target="wasm-gc")
let ident = "cmarkWASM"

///|
#cfg(target="native")
let ident = "cmarkNative"

///|
fn main {
  let bench = @bench.Bench()
  for size in [100, 200] {
    let name = "\{ident}(spec * \{size})"
    let input = spec_md.repeat(size)
    let summary = @bench.single_bench(count=5U, () => {
      bench.keep(try! @cmark_html.render(input))
    })
    guard @json.to_json(summary)
      is {
        "mean": Number(mean, ..),
        "runs": Number(runs, ..),
        "std_dev_pct": Number(deviation, ..),
        ..
      } else {
      abort("unexpected core bench summary")
    }
    let result : Json = {
      "name": @json.to_json(name),
      "unit": "ops/sec",
      "value": @json.to_json(1_000_000.0 / mean),
      "extra": @json.to_json("\{runs.to_int()} samples; std dev \{deviation}%"),
    }
    println(result.stringify())
  }
}

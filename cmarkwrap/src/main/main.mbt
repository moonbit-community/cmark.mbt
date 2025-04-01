///|
fn main {
  let doc : String = @fs.read_file_to_string?("./src/data/test/spec.md").unwrap()
  let doc100 = doc.repeat(100)
  let doc200 = doc.repeat(200)
  let count = 5
  let res = @benchmark.Criterion::new()
    ..add(
      @benchmark.Task::new(
        "\{ident}(spec * 100)",
        fn() { @lib.render?(doc100) |> ignore },
        count~,
      ),
    )
    ..add(
      @benchmark.Task::new(
        "\{ident}(spec * 200)",
        fn() { @lib.render?(doc200) |> ignore },
        count~,
      ),
    )
    .run()
  for k, v in res {
    let max = 1.0 / v.min
    let min = 1.0 / v.max
    let avg = 1.0 / v.average
    let moe_estm = {
      let sigma_estm = (max - min) / 4.0
      let z_estm = 1.96
      let se_estm = sigma_estm / count.to_double().sqrt()
      z_estm * se_estm
    }
    println(
      "\{k} x \{round_2(avg)} ops/sec ±\{round_2(moe_estm * 100)}% (\{count} runs sampled)",
    )
  }
}

///|
fn round_2(d : Double) -> String {
  let raw = (d * 100.0).round().to_int()
  let mut raw = raw.to_string()
  raw = "0".repeat(3 - raw.length()) + raw
  let raw_len = raw.length()
  "\{raw.view(end_offset=raw_len - 2)}.\{raw.view(start_offset=raw_len - 2)}"
}

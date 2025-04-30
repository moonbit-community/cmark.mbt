///|
fn main {
  let doc : String = @fs.read_file_to_string?("./src/data/test/spec.md").unwrap()
  let count = 5
  let cases = Map::new()
    ..set("\{ident}(spec * 100)", doc.repeat(100))
    ..set("\{ident}(spec * 200)", doc.repeat(200))
  let summaries = []
  let b = @bench.new()
  for k, input in cases {
    summaries.push(
      @bench.single_bench(name=k, count=count.reinterpret_as_uint(), fn() {
        b.keep(@lib.render?(input))
      }),
    )
  }
  let us_per_s = 1_000_000.0
  for v in summaries {
    let v = v.to_json().as_object().unwrap()
    let k = v["name"].unwrap().as_string().unwrap()
    // let max = 1.0 / v["min"].unwrap().as_number().unwrap()
    // let min = 1.0 / v["max"].unwrap().as_number().unwrap()
    let avg = us_per_s / v["mean"].unwrap().as_number().unwrap()
    let moe_estm = {
      let sigma = v["std_dev"].unwrap().as_number().unwrap()
      let sem = sigma / us_per_s / count.to_double().sqrt()
      let df = count - 1
      let critical = {
        let len = t_table.length()
        t_table.get(df).or(t_table[len - 1])
      }
      sem * critical
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

///|
let t_table : Array[Double] = [
  12.706, 12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228,
  2.201, 2.179, 2.16, 2.145, 2.131, 2.12, 2.11, 2.101, 2.093, 2.086, 2.08, 2.074,
  2.069, 2.064, 2.06, 2.056, 2.052, 2.048, 2.045, 2.042, 1.96,
]

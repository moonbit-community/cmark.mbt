///|
fn main {
  let doc : String = @fs.read_file_to_string?("./src/data/test/spec.md").unwrap()
  let doc100 = doc.repeat(100)
  let doc200 = doc.repeat(200)
  let res = @benchmark.Criterion::new()
    ..add(
      @benchmark.Task::new(
        "spec * 100",
        fn() { @lib.render?(doc100) |> ignore },
        count=10,
      ),
    )
    ..add(
      @benchmark.Task::new(
        "spec * 200",
        fn() { @lib.render?(doc200) |> ignore },
        count=10,
      ),
    )
    .run()
  println(res)
}

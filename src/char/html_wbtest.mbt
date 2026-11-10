///|
fn lookup(name : StringView) -> String? {
  html_named_entity(name).map(v => v.to_owned())
}

///|
test "html_named_entity hits" {
  debug_inspect(
    lookup("copy"),
    content=(
      #|Some("©")
    ),
  )
  debug_inspect(
    lookup("ngE"),
    content=(
      #|Some("≧̸")
    ),
  )
  // Supplementary-plane value (U+1D504).
  debug_inspect(
    lookup("Afr"),
    content=(
      #|Some("𝔄")
    ),
  )
  // First and last names in the table.
  debug_inspect(
    lookup("AElig"),
    content=(
      #|Some("Æ")
    ),
  )
  // U+200C ZERO WIDTH NON-JOINER is invisible, so compare instead.
  debug_inspect(lookup("zwnj") == Some("\u{200C}"), content="true")
  // Values with two code points, and escaped characters.
  debug_inspect(
    lookup("nGt"),
    content=(
      #|Some("≫⃒")
    ),
  )
  debug_inspect(
    lookup("quot"),
    content=(
      #|Some("\"")
    ),
  )
  debug_inspect(
    lookup("NewLine"),
    content=(
      #|Some("\n")
    ),
  )
}

///|
test "html_named_entity misses" {
  debug_inspect(
    lookup("notanentity"),
    content=(
      #|None
    ),
  )
  debug_inspect(
    lookup(""),
    content=(
      #|None
    ),
  )
  // Prefixes of real names are not entities themselves.
  debug_inspect(
    lookup("cop"),
    content=(
      #|None
    ),
  )
  debug_inspect(
    lookup("Aacut"),
    content=(
      #|None
    ),
  )
  // Lookup is case sensitive.
  debug_inspect(
    lookup("COPy"),
    content=(
      #|None
    ),
  )
  // Names with the delimiters attached are not stripped.
  debug_inspect(
    lookup("&copy;"),
    content=(
      #|None
    ),
  )
}

///|
test "html_named_entity finds every name" {
  let n = html_entity_name_offsets.length() - 1
  debug_inspect(
    n,
    content=(
      #|2125
    ),
  )
  debug_inspect(
    html_entity_value_offsets.length() - 1 == n,
    content=(
      #|true
    ),
  )
  for i in 0..<n {
    let name = html_entity_names.unsafe_view(
      start=html_entity_name_offsets[i].to_int(),
      end=html_entity_name_offsets[i + 1].to_int(),
    )
    let value = html_entity_values.unsafe_view(
      start=html_entity_value_offsets[i].to_int(),
      end=html_entity_value_offsets[i + 1].to_int(),
    )
    guard html_named_entity(name) is Some(found) && found == value else {
      fail("lookup failed for \{name}")
    }
    if i > 0 {
      let prev = html_entity_names.unsafe_view(
        start=html_entity_name_offsets[i - 1].to_int(),
        end=html_entity_name_offsets[i].to_int(),
      )
      guard prev.lexical_compare(name) < 0 else {
        fail("names not sorted at \{name}")
      }
    }
  }
}

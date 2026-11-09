///|
/// Looks up the replacement text of the HTML named character reference
/// `&name;`. `name` excludes the leading `&` and the trailing `;`.
fn html_named_entity(name : StringView) -> StringView? {
  // Binary search over the sorted names; `hi` is exclusive.
  let mut lo = 0
  let mut hi = html_entity_name_offsets.length() - 1
  while lo < hi {
    let mid = lo + (hi - lo) / 2
    let entry = html_entity_names.unsafe_view(
      start=html_entity_name_offsets[mid].to_int(),
      end=html_entity_name_offsets[mid + 1].to_int(),
    )
    let cmp = name.lexical_compare(entry)
    if cmp < 0 {
      hi = mid
    } else if cmp > 0 {
      lo = mid + 1
    } else {
      return Some(
        html_entity_values.unsafe_view(
          start=html_entity_value_offsets[mid].to_int(),
          end=html_entity_value_offsets[mid + 1].to_int(),
        ),
      )
    }
  }
  None
}

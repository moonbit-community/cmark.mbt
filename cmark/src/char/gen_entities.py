#!/usr/bin/env python3
"""Generate `entities.mbt` from the WHATWG `entities.json`.

The table is emitted as static data instead of a `Json`/`Map` literal, which
would otherwise be rebuilt by startup code on every program start:

- `html_entity_names`: every entity name (without `&` and `;`), sorted in
  UTF-16 code-unit order and concatenated into one string;
- `html_entity_name_offsets`: n + 1 offsets into `html_entity_names`;
- `html_entity_values`: the replacement texts, in the same order;
- `html_entity_value_offsets`: n + 1 offsets into `html_entity_values`.

Entry `i` is `names[name_offsets[i]:name_offsets[i + 1]]`, and likewise for
the value. Offsets are in UTF-16 code units, as MoonBit strings are.
"""

import argparse
import json
import subprocess
import unicodedata
from pathlib import Path

UINT16_MAX = 0xFFFF


def utf16_len(s: str) -> int:
    return len(s.encode("utf-16-le")) // 2


def utf16_key(s: str) -> bytes:
    # Big-endian UTF-16 bytes compare in the same order as UTF-16 code units,
    # which is what `StringView::lexical_compare` uses.
    return s.encode("utf-16-be")


def escape(s: str) -> str:
    """Render `s` as the body of a MoonBit string literal.

    Printable characters are kept as is for readability; quotes, backslashes,
    control, format, combining and whitespace characters are escaped.
    """
    out = []
    for c in s:
        if c == '"' or c == "\\":
            out.append("\\" + c)
        elif c == " " or (
            unicodedata.category(c)[0] not in "CMZ" and ord(c) >= 0x20
        ):
            out.append(c)
        else:
            out.append(f"\\u{{{ord(c):x}}}")
    return "".join(out)


def offsets(parts: list[str], what: str) -> list[int]:
    result = [0]
    for p in parts:
        result.append(result[-1] + utf16_len(p))
    if result[-1] > UINT16_MAX:
        raise SystemExit(
            f"{what}: total length {result[-1]} does not fit in UInt16 offsets"
        )
    return result


def render_array(name: str, values: list[int]) -> str:
    lines = []
    for i in range(0, len(values), 16):
        lines.append("  " + ", ".join(str(v) for v in values[i : i + 16]) + ",")
    body = "\n".join(lines)
    return f"///|\nlet {name} : ReadOnlyArray[UInt16] = [\n{body}\n]\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="Input file")
    parser.add_argument("output", help="Output file")
    args = parser.parse_args()

    fin, fout = args.input, args.output

    entities: dict[str, dict[str, str]] = json.loads(Path(fin).read_text())

    table: dict[str, str] = {}
    for entity, value in entities.items():
        if not entity.endswith(";"):
            continue
        name = entity.removeprefix("&").removesuffix(";")
        table[name] = value["characters"]

    names = sorted(table, key=utf16_key)
    values = [table[n] for n in names]
    name_offsets = offsets(names, "names")
    value_offsets = offsets(values, "values")

    buf = f"""///|
// Named character references in HTML, generated from
// <https://html.spec.whatwg.org/entities.json> by `gen_entities.py`.
// To regenerate, run `moon build`. {len(names)} entries.
//
// Entry `i` is `html_entity_names[html_entity_name_offsets[i]:html_entity_name_offsets[i + 1]]`
// (without the `&` and `;`), mapped to the same slice of `html_entity_values`.
// Names are sorted in UTF-16 code-unit order (`StringView::lexical_compare`).

///|
let html_entity_names : String = "{escape("".join(names))}"

{render_array("html_entity_name_offsets", name_offsets)}
///|
let html_entity_values : String = "{escape("".join(values))}"

{render_array("html_entity_value_offsets", value_offsets)}"""

    Path(fout).write_text(buf, encoding="utf-8")
    subprocess.run(["moonfmt", "-w", f"{fout}"])


if __name__ == "__main__":
    main()

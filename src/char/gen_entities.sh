#!/bin/sh

INPATH=$(dirname "$0")
OUTPATH="${INPATH}/entities.mbt"

# Header
cat << 'EOF' > "$OUTPATH"
/// A collection of named entities in HTML,
/// generated from <https://html.spec.whatwg.org/entities.json>.
/// To regenerate, run `./src/char/gen_entities.sh`.
priv let html_named_entities : Json = {
EOF

# Key-value pairs
cat "${INPATH}/entities.json" | \
  # Extract entities and characters
  jq --ascii-output -r \
  'with_entries(.value |= .characters)' | \
  # Drop entities from the list that are not closed by a ';'
  grep ';' | \
  # Keep only the name of entities
  sed 's/[&;]//g' \
  >> "$OUTPATH"

# Footer
echo '}' >> "$OUTPATH"

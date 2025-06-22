#!/bin/bash

input="all.csv"
output="stocks.sql"
schema="idxstock"
table="stocks"

# Buat DDL opsional (hapus jika tidak perlu)
cat <<EOF >"$output"
INSERT INTO $schema.$table (code, name, listing_date, shares, board) VALUES
EOF

tail -n +2 "$input" | while IFS=',' read -r code name listingDate shares listingBoard; do
	date_formatted=$(echo "$listingDate" | sed 's/T.*//')
	shares_formatted=$(echo "$shares" | sed 's/\.0$//')
	echo "('$code', '$name', '$date_formatted', $shares_formatted, '$listingBoard')," >>"$output"
	echo "Processed: $code - $name"
done

sed -i '' -e '$ s/,$/;/' "$output"

echo "Done! SQL saved as $output"

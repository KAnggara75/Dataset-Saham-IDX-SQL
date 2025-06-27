#!/bin/bash

url="https://raw.githubusercontent.com/KAnggara75/Dataset-Saham-IDX/refs/heads/master/List%20Emiten/all.csv"
output="SQL/stocks.sql"
schema="idxstock"
table="stocks"

mkdir -p SQL

SKIP_CODES="FINN FORZ KPAL KPAS KRAH MAMI MAMIP MYRX MYRXP NIPS PRAS RMBA TURI"

cat <<EOF >"$output"
INSERT INTO $schema.$table (code, name, listing_date, shares, board) VALUES
EOF

curl -sL "$url" | tail -n +2 | while IFS=',' read -r code name listingDate shares listingBoard; do
	if [[ " $SKIP_CODES " == *" $code "* ]]; then
		echo "SKIPPED: $code - $name"
		continue
	fi

	date_formatted=$(echo "$listingDate" | sed 's/T.*//')
	shares_formatted=$(echo "$shares" | sed 's/\.0$//')

	case "$listingBoard" in
	"Utama") board_enum="Main" ;;
	"Ekonomi Baru") board_enum="Ekonomi Baru" ;;
	"Akselerasi") board_enum="Acceleration" ;;
	"Pengembangan") board_enum="Development" ;;
	"Pemantauan Khusus") board_enum="Watchlist" ;;
	*) board_enum="$listingBoard" ;;
	esac

	echo "('$code', '$name', '$date_formatted', $shares_formatted, '$board_enum')," >>"$output"
	echo "Processed: $code - $name ($board_enum)"
done

sed -i '' -e '$ s/,$//' "$output"

cat <<'EOF' >>"$output"
ON CONFLICT ("code")
    DO UPDATE SET "name"=excluded."name",
                  "listing_date"=excluded."listing_date",
                  "delisting_date"=excluded."delisting_date",
                  "shares"=excluded."shares",
                  "board"=excluded."board",
                  "last_modified"=excluded."last_modified";
EOF

echo "Done! SQL saved as $output"

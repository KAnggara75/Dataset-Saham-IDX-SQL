#!/bin/bash

DB_NAME="idxstock"
SQL_DIR="history"

for file in "$SQL_DIR"/*.sql; do
	echo "Running: $file"
	psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -f "$file"

	if [ $? -eq 0 ]; then
		echo "OK: $file"
	else
		echo "FAILED: $file"
		exit 1
	fi
done

echo "All SQL files executed."

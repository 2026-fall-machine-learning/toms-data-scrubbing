# Animals Prompting Log

## Prompts (word for word)

1. sql to aggregate animals table from animals.csv, create animals table, i plan to run in duckdb, myself, don't run just gen sql
2. hey, want to see the avg race time in mm:ss, and don't want all the other totals stuff
3. Binder Error: column "meat_eater" must appear in the GROUP BY clause or must be part of an aggregate function.
Either add it to the GROUP BY list, or use "ANY_VALUE(meat_eater)" if the exact value of "meat_eater" is not important. (Line Number: 2)
4. what about loose python do to this in animals.py
5. what about m code to run in power query
6. please create an animals-prompting.md file with all my prompts word for word, and just the final versions of sql, py, and m
7. how about a sqlite version, got errors when i tried it
8. update my md and sql files with this version too, keep the duckdb versions as well

## Final SQL (DuckDB)

```sql
CREATE OR REPLACE TABLE animals_agg AS
WITH avg_sec AS (
    SELECT
        meat_eater,
        tail,
        AVG(
            CAST(split_part(race_time, ':', 1) AS INTEGER) * 60
            + CAST(split_part(race_time, ':', 2) AS INTEGER)
        ) AS avg_sec
    FROM animals
    GROUP BY meat_eater, tail
)
SELECT
    meat_eater,
    tail,
    printf('%02d:%02d', CAST(avg_sec AS INTEGER) // 60, CAST(avg_sec AS INTEGER) % 60) AS avg_race_time
FROM avg_sec
ORDER BY meat_eater, tail;

SELECT * FROM animals_agg;
```

## Final SQL (SQLite)

```sql
-- SQLite can't read a CSV directly in SQL; create the schema first
CREATE TABLE IF NOT EXISTS animals (
    animal     TEXT,
    meat_eater TEXT,
    legs       INTEGER,
    tail       TEXT,
    race_time  TEXT
);

-- Then, in the sqlite3 CLI (these are dot-commands, not SQL):
-- .mode csv
-- .import --skip 1 animals.csv animals

WITH avg_sec AS (
    SELECT
        meat_eater,
        tail,
        AVG(
            CAST(substr(race_time, 1, instr(race_time, ':') - 1) AS INTEGER) * 60
            + CAST(substr(race_time, instr(race_time, ':') + 1) AS INTEGER)
        ) AS avg_sec
    FROM animals
    GROUP BY meat_eater, tail
)
SELECT
    meat_eater,
    tail,
    printf('%02d:%02d', CAST(avg_sec AS INTEGER) / 60, CAST(avg_sec AS INTEGER) % 60) AS avg_race_time
FROM avg_sec
ORDER BY meat_eater, tail;
```

## Final Python (animals.py)

```python
import pandas as pd

animals = pd.read_csv("animals.csv")

# Convert "mm:ss" race_time into total seconds so it can be averaged
race_time_parts = animals["race_time"].str.split(":", expand=True).astype(int)
animals["race_time_sec"] = race_time_parts[0] * 60 + race_time_parts[1]

animals_agg = animals.groupby(["meat_eater", "tail"], as_index=False).agg(
    avg_race_time_sec=("race_time_sec", "mean")
)

# Convert the averaged seconds back into "mm:ss"
avg_sec = animals_agg["avg_race_time_sec"].astype(int)
animals_agg["avg_race_time"] = (
    (avg_sec // 60).astype(str).str.zfill(2) + ":" + (avg_sec % 60).astype(str).str.zfill(2)
)
animals_agg = animals_agg.drop(columns="avg_race_time_sec")

print(animals_agg)
```

## Final M (Power Query)

```m
let
    Source = Csv.Document(
        File.Contents("C:\Users\tsteele\Downloads\toms-data-scrubbing\animals.csv"),
        [Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {
        {"animal", type text},
        {"meat_eater", type text},
        {"legs", Int64.Type},
        {"tail", type text},
        {"race_time", type text}
    }),

    // Convert "mm:ss" race_time text into total seconds
    #"Added Seconds" = Table.AddColumn(#"Changed Type", "race_time_sec", each
        let
            parts   = Text.Split([race_time], ":"),
            minutes = Number.FromText(parts{0}),
            seconds = Number.FromText(parts{1})
        in
            minutes * 60 + seconds,
        Int64.Type
    ),

    // Group by meat_eater and tail, averaging the seconds
    #"Grouped Rows" = Table.Group(#"Added Seconds", {"meat_eater", "tail"}, {
        {"avg_race_time_sec", each List.Average([race_time_sec]), type number}
    }),

    // Convert the averaged seconds back to "mm:ss"
    #"Added avg_race_time" = Table.AddColumn(#"Grouped Rows", "avg_race_time", each
        let
            total = Number.Round([avg_race_time_sec], 0),
            mins  = Number.IntegerDivide(total, 60),
            secs  = Number.Mod(total, 60)
        in
            Text.PadStart(Text.From(mins), 2, "0") & ":" & Text.PadStart(Text.From(secs), 2, "0"),
        type text
    ),

    #"Removed Columns" = Table.RemoveColumns(#"Added avg_race_time", {"avg_race_time_sec"})
in
    #"Removed Columns"
```

-- ==========================================================
-- DuckDB version
-- ==========================================================
CREATE OR REPLACE TABLE animals AS
SELECT * FROM read_csv_auto('animals.csv');

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

-- ==========================================================
-- SQLite version
-- ==========================================================
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

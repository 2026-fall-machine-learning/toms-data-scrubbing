CREATE OR REPLACE TABLE inventory AS
SELECT * FROM read_csv_auto('inventory.csv');

SELECT
    buyer,
    protein_shake + powerade + protein_bar + vitamins AS health_food,
    nike_sneakers + adidas_boots                       AS apparel,
    fitbit + fitness_watch                              AS digital
FROM inventory;


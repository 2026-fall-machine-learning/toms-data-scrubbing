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

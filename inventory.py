import pandas as pd

inventory = pd.read_csv("inventory.csv")

inventory_collapsed = pd.DataFrame({
    "buyer": inventory["buyer"],
    "health_food": inventory["protein_shake"] + inventory["powerade"] + inventory["protein_bar"] + inventory["vitamins"],
    "apparel": inventory["nike_sneakers"] + inventory["adidas_boots"],
    "digital": inventory["fitbit"] + inventory["fitness_watch"],
})

print(inventory_collapsed)

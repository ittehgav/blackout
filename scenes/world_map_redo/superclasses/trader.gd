extends Building

class_name Trader

@export_group("Item Trade")
@export_subgroup("Shop Metadata")
@export_range(1, 10) var max_items:int;
@export_range(1, 10) var rarity_rate:int;
## item pool is within the NpcInventory

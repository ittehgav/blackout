extends Node2D

class_name FighterIndex

## fighter bases are only stored as index references outside of combat
@export var all_fighter_base_scenes:Array[PackedScene];
var all_fighter_bases:Array[FighterBase];

func find_base(target_name:String)->FighterBase:
	return all_fighter_bases.filter(func(b:FighterBase)->bool:return b.name == target_name)[0]

func random_fighter_base(only_non_evolved:bool=false)->FighterBase:
	var pool:Array[FighterBase] = all_fighter_bases;
	if only_non_evolved:
		pool = pool.filter(func(f:FighterBase)->bool:return len(f.tags) == 2);
	return pool.pick_random();

extends Node2D

class_name FighterIndex

## fighter bases are only stored as index references outside of combat
@export var all_fighter_bases:Array[FighterBase];

func find_base(target_name:String)->FighterBase:
	return all_fighter_bases.filter(func(b:FighterBase)->bool:return b.name == target_name)[0]

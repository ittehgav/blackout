extends Consumable

const size_x = 2;
const size_y = 2;

const rarity = 2;
@export var modifier:ItemModifier

func get_description()->String:
	return "Use to give +5 "+Index.stat_colored_name("defense") + " to an accessory.";


func use_on_item(target:Accessory)->void:
	modifier.reparent(target)
	target.applied_modifier = modifier;
	

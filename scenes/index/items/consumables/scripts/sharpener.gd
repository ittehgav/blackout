extends Consumable

const size_x = 2;
const size_y = 1;

const rarity = 1;
@export var modifier:ItemModifier

func get_description()->String:
	return "Use to increase the " +Index.get_color_tag("attack") + "damage[/color] of a melee weapon by 10.";

func item_filter(weapon:Weapon)->bool:
	return weapon.melee;

func use_on_item(target:Weapon)->void:
	modifier.reparent(target)
	target.applied_modifier = modifier;

extends Weapon

const rarity = 2

const cooldown = 1;

const type = "support"
const effect_range = 50
const damage = 0;

var description:String = Meta.get_color_tag("no_dmg") + "Deals no damage.[/color] Can [color=green]heal allies[/color] in an area or give them a [color=green]movement speed boost.[/color]\n[color=blue]right-click[/color] to alternate between the effects in battle."

const aoe_radius = 250;

var holder:Node2D;

const use_sfx = "cast"

var hit_sfx:String = "heal";

@export var projection:Polygon2D

func use()->void:
	pass
	
func alt_use()->void:
	## staff can switch between healing allies 
	## and giving them a speed buff
	pass

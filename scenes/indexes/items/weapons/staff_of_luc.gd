extends Weapon

const rarity = 2

@export var vfx:Node2D
const angle_adjust = 0;
const type = "support";



const damage = 0;
const cooldown = 1;

const aoe_radius = 200;
const hit_scan_offset = "follow_cursor";
const max_range = 300;

const projection = "circle_aoe";

var description :String= Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color]"+Index.get_color_tag("max_hp") + "Heals[/color] or gives an " + Index.get_color_tag("agility") + "Agility buff to allies in an area.\n Press [right-click] to alternate between modes.";

const use_vfx = ["grow"];

const heal_value = 20;
const buff_frac = .1;

var use_sfx:String = "heal";
var alt_mode = false;


func use()->bool:
	if not alt_mode:
		Combat.aoe_heal(Entities.in_fight_player, heal_value)
	else:
		Combat.aoe_stat_buff(Entities.in_fight_player,"agility", buff_frac)
	vfx.play_vfx()
	return false;

func alt_use()->void:
	alt_mode = not alt_mode;
	if alt_mode:
		use_sfx = "buff"
	else:
		use_sfx = "heal"

func _on_equipped() -> void:
	Entities.in_fight_player.hit_scan.set_collision_mask_value(2, false)
	Entities.in_fight_player.hit_scan.set_collision_mask_value(1, true)


func _on_unequipped() -> void:
	Entities.in_fight_player.hit_scan.set_collision_mask_value(1, false)
	Entities.in_fight_player.hit_scan.set_collision_mask_value(2, true)

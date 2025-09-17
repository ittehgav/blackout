extends Weapon

const rarity = 2

const size_x = 2;
const size_y = 4;

@export var vfx:Node2D
const angle_adjust = 0;
const type = "support";


const damage = 0;

const aoe_radius = 200;
const hit_scan_offset = "follow_cursor";
const max_range = 300;

const main_projection_modulate = Color.GREEN - Color(0, 0, 0, .75)
const alt_projection_modulate = Color.YELLOW - Color(0, 0, 0, .75)

var projection_modulate:Color = main_projection_modulate;


const projection = "circle_aoe";

var description :String

func get_description()->String:
	return Index.get_color_tag("no_dmg") + "Doesn't deal damage.[/color]"+Index.get_color_tag("max_hp")\
 + " Heals[/color] or gives an " + Index.stat_colored_name("agility") +\
 " buff to allies in an area.\nPress [right-click] in combat to alternate between modes.";

const use_vfx = ["grow"];

const base_heal = 20;
const base_buff_frac = .1;

func weapon_heal()->float:
	## just gets nothing from player attack stat?
	var heal: = base_heal;
	var technique:float = Entities.player.combat_stats.technique;
	if technique > 1:
		heal = Scaling.technique_scaled_value(heal, Entities.player_fighter.technique, "heal");
	return heal;
	


var use_sfx:String = "heal";
const alt_use_sfx = "alternate"
var alt_mode:bool = false;


func use()->bool:
	if not alt_mode:
		Combat.aoe_heal(Entities.player_fighter, weapon_heal())
	else:
		Combat.aoe_stat_buff(Entities.player_fighter,"agility", base_buff_frac)
	vfx.play_vfx()
	return false;

func alt_use()->void:
	alt_mode = not alt_mode;
	if alt_mode:
		use_sfx = "buff"
		projection_modulate = alt_projection_modulate
	else:
		use_sfx = "heal"
		projection_modulate = main_projection_modulate;
	refresh_request.emit();

func _on_equipped() -> void:
	Entities.player_fighter.hit_scan.set_collision_mask_value(2, false)
	Entities.player_fighter.hit_scan.set_collision_mask_value(1, true)


func _on_unequipped() -> void:
	Entities.player_fighter.hit_scan.set_collision_mask_value(1, false)
	Entities.player_fighter.hit_scan.set_collision_mask_value(2, true)

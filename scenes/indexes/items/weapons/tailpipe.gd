extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs
const rarity = 1;

const size_x = 2;
const size_y = 4;

const angle_adjust = 30;


const type = "melee";
const cooldown:float = 2;
const base_damage = 50


const aoe_radius = 100;
const hit_scan_offset = Vector2(60, 0)

const projection = "none"

const description:String = "Short range, quick, reliable weapon.";

const use_vfx = ["swing", "arc", "camera_lunge"];
const hit_vfx = ["freeze_camera"];

const use_sfx = "swing"
const hit_sfx = "swing_hit"


var swung:bool = false;

@export var arc:Sprite2D;
var arc_duplicate:Sprite2D;


func use()->bool:
	var holder:InFightPlayer = Entities.player_fighter;
	Combat.aoe_damage(holder);
	if len(holder.hit_scan.get_overlapping_bodies()):
		return true
	return false


func _on_equipped() -> void:
	arc_duplicate = arc.duplicate()
	arc_duplicate.show();
	get_parent().add_child(arc_duplicate);


func _on_unequipped() -> void:
	arc_duplicate.queue_free();

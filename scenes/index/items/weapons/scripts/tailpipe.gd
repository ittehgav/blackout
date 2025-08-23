extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs
const rarity = 1;

const size_x = 2;
const size_y = 4;

const angle_adjust = 30;


const type = "melee";
const base_damage = 50

@export var hit_scan:Area2D;
const aoe_radius = 100;
const hit_scan_offset = Vector2(60, 0)

const projection = "none"

const description:String = "Short range, reliable weapon.";

const use_vfx = ["swing", "arc", "camera_lunge"];
const hit_vfx = ["freeze_camera"];

const use_sfx = "swing"
const hit_sfx = "swing_hit"


var swung:bool = false;

@export var arc:Sprite2D;
var arc_duplicate:Sprite2D;


func use()->bool:
	var holder:PlayerFighter = Entities.player_fighter;
	Combat.aoe_damage(holder, hit_scan);
	if len(hit_scan.get_overlapping_bodies()):
		return true
	return false


func _on_equipped() -> void:
	var parent:Node = get_parent();
	hit_scan.reparent(parent)
	arc.reparent(parent);
	arc.show()




func _on_unequipped() -> void:
	hit_scan.reparent(self)
	arc.hide();
	arc.reparent(self);

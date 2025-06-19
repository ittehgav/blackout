extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs
const rarity = 1;

const size_x = 2;
const size_y = 4;

const angle_adjust = 30;


const type = "melee";
const cooldown:float = .5;
const base_damage = 2220


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

func use()->bool:
	var holder:InFightPlayer = Entities.in_fight_player;
	Combat.aoe_damage(holder);
	if len(holder.hit_scan.get_overlapping_bodies()):
		return true
	return false


func _on_equipped() -> void:
	arc.show();
	arc.reparent(get_parent());

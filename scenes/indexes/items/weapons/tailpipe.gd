extends Weapon

## weapons can be weapons or tools with effects such as heals/buffs

const cooldown:float = .5;

const type = "melee";
const effect_range = 1;
const damage = 100;

const aoe_radius = 100;

var swung:bool = false;
var holder:Node2D;

const use_sfx = "swing"
const hit_sfx = "swing_hit"

@export var arc:Polygon2D;


func use()->bool:
	Tweens.swing_tween(self);
	Tweens.arc_vfx(arc)
	Tweens.camera_lunge(holder)

	Combat.aoe_damage(holder);
	if len(holder.hit_scan.get_overlapping_bodies()):
		return true
	return false

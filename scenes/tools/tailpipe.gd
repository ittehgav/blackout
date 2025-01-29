extends Sprite2D

## tools can be weapons or support items

const cooldown:float = 1.0;

const type = "melee";
const effect_range = 1;
const damage = 100;

const aoe_radius = 100;

var swung:bool = false;
var holder:Node2D;

@export var arc:Polygon2D;

func use():
	Tweens.swing_tween(self);
	Tweens.arc_vfx(arc)
	Combat.aoe_damage(holder);
	Tweens.lunge_forward_tween(holder);
	Tweens.camera_lunge(holder)

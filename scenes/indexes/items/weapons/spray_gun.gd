extends Weapon

const rarity = 3

const size_x = 3;
const size_y = 2;

const angle_adjust = 0;
const type = "ranged";

const cooldown:float = 2;
const base_damage = 10;



const aoe_radius = 160;

const projection = "cone_aoe";

const description = "Sprays poisionous gas on a cone-shaped area, damaging enemies."

const use_vfx = ["gun_recoil"];

const use_sfx = "spray";

@export var cone:Sprite2D;

func use()->bool:
	var new_cone:Sprite2D = cone.duplicate();
	new_cone.launch()
	new_cone.hit.connect(enemy_hit)
	return false

func enemy_hit(target:ActiveFighter)->void:
	Combat.deal_damage(Entities.in_fight_player, target);

extends Weapon


const rarity = 2;

const angle_adjust = 0;
## taser gun, stuns and damages a target
const type = "ranged";


const damage = 20;
const cooldown:float = 1
const stun_duration = .5;

const projection = "gun_shot"


const description:String = "Long range, damages and stuns enemies."

const use_vfx = ["gun_recoil"];


const use_sfx = "shoot";


@export var projectile:Projectile;

func use()->bool:
	Combat.shoot_projectile(projectile, Entities.in_fight_player, projectile_hit);
	return false
	
func projectile_hit(target:ActiveFighter)->void:
	## for weapons we just make the function here, for NPCs things will get more generic i suppose
	var holder:InFightPlayer = Entities.in_fight_player;
	Combat.deal_damage(holder, target);
	Combat.stun_target(holder, target, stun_duration)
	Entities.in_fight_player.equipment.weapon_sfx.play_hit_sfx("swing_hit")

func _on_equipped() -> void:
	projectile.setup(Entities.in_fight_player);

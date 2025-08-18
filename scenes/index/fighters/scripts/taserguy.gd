extends FighterBase

@export var projectile:Projectile;


const sample_offset = Vector2(8, -26)

const target_type = "nearest_enemy"

const skill_name = "Taser Shot"
const description = "Deals light damage and stuns target."
const flavor = "The most violent form of non-violence."
#
#const tags = [
	#"disruptor",
	#"scientist"
#]

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var stun_duration_str:String = Index.get_technique_scaled_string(unit, "stun", "status_duration");
	
	var string:String = "Deals " + damage_str + " to a target and stuns them for "\
	 + stun_duration_str + " seconds.";
	string += "\n\nCan be [u]upgraded[/u] to heal allies or to deal heavy damage."
	return string

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 300;
const skill_cooldown = 5;

const status_duration = .75


const evolutions = {
	"Tether Guy":{
		"juice":50,
		"food":50
	},
	"Coil Guy":{
		"chips":20,
		"scrap":50
	}
}



func skill()->void:
	Combat.shoot_projectile(projectile, fighter, projectile_hit);


func projectile_hit(target:ActiveFighter)->void:
	Combat.deal_damage(fighter);
	Combat.stun_target(fighter, target)

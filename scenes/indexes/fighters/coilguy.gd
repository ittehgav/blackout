extends FighterBase

const skill_effects = ["special"];
const skill_visuals = ["recoil"];

## sounds for this guy are played through the special_skill function
const skill_use_sfx = []
const skill_hit_sfx = []


const sample_offset = Vector2(10, -26)

const target_type = "nearest_enemy"

const skill_name = "Chain Lightning"
const description = "Fires powerful chain lightning Attacks."
const flavor = "He tells the party-mates that the magnetism only affects people who make fun of his baldness.";

const tags = [
	"cyborg",
	"scientist",
	"mechanic"
]

func full_skill_description(unit:FighterUnit)->String:
	var damage_str:String = Index.get_unit_damage_string(unit);
	var technique_str:String = Index.get_technique_scaled_string(unit, "", 0,.05, "x")
	
	
	var string:String="[color=yellow]Magnetizes[/color] the nearest enemy that's not [color=yellow]magnetized[/color], then deals " +\
	damage_str + " to all [color=yellow]magnetized[/color] enemies.\nDeals " + technique_str + \
	" more damage to all targets for each [color=yellow]magnetized[/color] enemy on the battlefield."
	return string

const hitbox_radius = 25;
const hitbox_height = 60;
const hitbox_offset = Vector2(0, 5)

const skill_range = 300;
const skill_cooldown = 10;


var tagged_targets:Array[ActiveFighter] = [];
##TODO: make the chain lighjtning VFX thingy

func special_skill()->void:
	if not len(tagged_targets):
		tagged_targets.push_back(fighter.target_unit);
		fighter.target_unit.death.connect(remove_from_tagged.bind(fighter.target_unit))
		

	elif not len(fighter.enemy_team.units) == len(tagged_targets):
		var untagged_targets:Array[Node] = fighter.enemy_team.units.duplicate();
		
		for unit:ActiveFighter in tagged_targets:
			untagged_targets.erase(unit)
		untagged_targets.sort_custom(closer_to_last_tagged)

		var target:ActiveFighter = untagged_targets[0];
		tagged_targets.push_back(target);
		target.death.connect(remove_from_tagged.bind(target));

	for unit:ActiveFighter in fighter.enemy_team.units:
		if unit in tagged_targets:
			Combat.deal_damage(fighter, unit, target_count_amplifier);
	
	if len(tagged_targets) > 1:
		fighter.npc_sfx.play_sound_by_key("lightning_big");
	else:
		fighter.npc_sfx.play_sound_by_key("lightning_small")


func target_count_amplifier(damage:float)->float:
	for i in len(tagged_targets):
		damage += damage * fighter.technique/20;
	return damage;

func closer_to_last_tagged(a:ActiveFighter, b:ActiveFighter)->bool:
	var check_index:int = -1;
	while not is_instance_valid(tagged_targets[check_index]):
		check_index -= 1;
	return a.position.distance_to(tagged_targets[check_index].position) < b.position.distance_to(tagged_targets[check_index].position)
	

func remove_from_tagged(_killer:ActiveFighter, target:ActiveFighter)->void:
	tagged_targets.erase(target);

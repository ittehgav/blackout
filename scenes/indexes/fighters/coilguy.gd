extends FighterBase

const skill_effects = ["special"];
const skill_visuals = ["recoil"]

const target_type = "nearest_enemy"

const skill_name = "Chain Lightning"
const short_description = "Fires Chain Lightning Attacks."
const long_description = "Magnetizes one enemy, then deals damage to all magnetized enemies."

const tags = [
	"hunter",
	"scientist",
	"mechanic"
]

const hitbox_radius = 50;
const hitbox_height = 150;

const skill_range = 1000;
const skill_cooldown = 2;


var tagged_targets:Array[ActiveFighter] = [];

func special_skill(fighter:ActiveFighter)->void:
	if not len(tagged_targets):
		tagged_targets.push_back(fighter.target_unit);
		fighter.target_unit.death.connect(remove_from_tagged.bind(fighter.target_unit))

	elif not len(fighter.enemy_team) == len(tagged_targets):
		var untagged_targets:Array[ActiveFighter] = fighter.enemy_team.duplicate();
		
		for unit:ActiveFighter in tagged_targets:
			untagged_targets.erase(unit)
		untagged_targets.sort_custom(closer_to_last_tagged)

		var target:ActiveFighter = untagged_targets[0];
		tagged_targets.push_back(target);
		target.death.connect(remove_from_tagged.bind(target));

	for unit:ActiveFighter in fighter.enemy_team:
		if unit in tagged_targets:
			Combat.deal_damage(fighter, unit);


func closer_to_last_tagged(a:ActiveFighter, b:ActiveFighter)->bool:
	return a.position.distance_to(tagged_targets[-1].position) < b.position.distance_to(tagged_targets[-1].position)
	

func remove_from_tagged(_killer, target:ActiveFighter)->void:
	tagged_targets.erase(target);

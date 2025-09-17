extends Accessory

const size_x = 4;
const size_y = 2;

const rarity = 3;


func get_description()->String:
	var description:String = super();
	description += "\nThe wearer deals 50% damage back to melee units.";
	return description;

func combat_start_effect(fighter:ActiveFighter)->void:
	fighter.damage_taken.connect(damage_reflection.bind(fighter));
	
func damage_reflection(damage:float, source:ActiveFighter, wearer:ActiveFighter)->void:
	if source is NpcFighter:
		if source.base.skill_range == FighterBase.MELEE_RANGE:
			Combat.deal_damage(wearer, source, Callable(), 0, false)

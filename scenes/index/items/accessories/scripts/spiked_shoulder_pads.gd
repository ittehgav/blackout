extends Accessory

const size_x = 4;
const size_y = 2;

const rarity = 3;


func get_description()->String:
	var description:String = super();
	description += "\nThe wearer deals 50% damage back to melee attackers.";
	return description;

func battle_start_apply(target:ActiveFighter)->void:
	target.damage_taken.connect(damage_reflection.bind(target));
	
func damage_reflection(damage:float, source:ActiveFighter, quiet:bool, wearer:ActiveFighter)->void:
	if quiet:
		return
	if source is NpcFighter:
		if source.base.skill_range == FighterBase.MELEE_RANGE:
			Combat.deal_damage(wearer, source, damage/2, true)
	elif source is PlayerFighter:
		if Entities.player_fighter.equipment.weapon_control.weapon.melee:
			Combat.deal_damage(wearer, source, damage/2, true);

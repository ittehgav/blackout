extends Accessory


const size_x = 2;
const size_y = 1;

const rarity = 1;

var current_attack_change:Status

func get_description()->String:
	var description:String = super();
	description += "Increases damage from melee weapons by 20%, if you have two [u]brass knuckles[/u] equipped, the bonus for each is 40%.";
	return description

func battle_start_apply(target:ActiveFighter)->void:
	## runs before weapon control setup right?
	await target.equipment.ready;
	## untested
	var wc:WeaponControl = target.equipment.weapon_control;
	check_bonus(wc.weapon);
	check_bonus(wc.alternative_weapon)
		
func check_bonus(target:Weapon)->void:
	## needs to match the signature of EquipmentControl.weapon_equipped
	if target.melee:
		if current_attack_change:
			current_attack_change.remove()
		
		var other_accessory:Accessory = other_equipped_accessory();
		
		var bonus_multiplier:float = .2;
		if other_accessory and other_accessory.scene_file_path == scene_file_path:
			bonus_multiplier = .4

		var bonus:float = target.base_damage * bonus_multiplier;
		
		target.base_damage += bonus;
		

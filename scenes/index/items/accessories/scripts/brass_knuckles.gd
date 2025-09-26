extends Accessory

const size_x = 2;
const size_y = 1;

const rarity = 1;

var current_attack_change:float;

func get_description()->String:
	var description:String = super();
	description += "Increases damage from melee weapons by 20%, if you have two [u]brass knuckles[/u] equipped, the bonus for each is 40%.";
	return description

func battle_start_apply(_target:ActiveFighter)->void:
	## runs before weapon control setup right?
	Entities.player_fighter.equipment.weapon_equipped.connect(check_bonus)
		
		
func check_bonus(target:Weapon)->void:
	## needs to match the signature of EquipmentControl.weapon_equipped
	if target.melee:
		var bonus_multiplier:float = .2;
		if current_attack_change:
			Entities.player_fighter.in_battle_stat_modifiers.attack -= current_attack_change
		
		var other_accessory:Accessory = other_equipped_accessory();
		
		if other_accessory and other_accessory.scene_file_path == scene_file_path:
			bonus_multiplier = .4
			
		current_attack_change = target.base_tamage * bonus_multiplier;
		
		Combat.apply_stat_change(Entities.player_fighter, Entities.player_fighter, current_attack_change, "attack");
		

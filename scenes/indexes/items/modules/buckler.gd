extends Module;

@export var parry_timer:Timer;

const rarity = 1;

const size_x = 1;
const size_y = 1;

const cooldown = 5;
const sfx_key = "buckler";

const continuous = true;

var description:String = "Hold to slow down movement and greatly increase your " + Index.stat_colored_name("defense") +\
", if an enemy attacks you immediately after activating [u]Module - Buckler[/u], the enemy is stunned.";

const base_defense_frac = .5;
const base_stun_duration = 3;

var defense_gain:float;
var move_speed_loss:float;

func use()->void:
	## TODO PARRY NOT IMPLEMENTED YET
	parry_timer.start();
	## right now this is the only thing that alters movement speed
	## but will need to be more comprehensive eventually
	var defense_frac: = base_defense_frac;
	var technique: = Entities.in_fight_player.technique;
	if technique > 1:
		defense_frac *= technique
	defense_gain = Entities.in_fight_player.defense * defense_frac;
	
	move_speed_loss = Entities.in_fight_player.move_speed - Entities.in_fight_player.move_speed/2
	
	var player:InFightPlayer = Entities.in_fight_player
	Combat.apply_stat_change(player, player, defense_gain, "defense")
	Combat.apply_stat_change(player, player, -move_speed_loss, "move_speed")
	
func release()->void:
	var player:InFightPlayer = Entities.in_fight_player
	Combat.apply_stat_change(player, player, -defense_gain, "defense");
	Combat.apply_stat_change(player, player, move_speed_loss, "move_speed");

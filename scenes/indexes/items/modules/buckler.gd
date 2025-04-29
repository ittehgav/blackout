extends Module;

@export var parry_timer:Timer;

const rarity = 1;

const size_x = 1;
const size_y = 1;

const cooldown = 5;
const sfx_key = "buckler";

const continuous = true;

var description = "Hold to slow down movement and take double your " + Index.get_color_tag("defense") +\
"defense[/color] , if you get hit by an enemy immediately after activating Buckler, the enemy becomes stunned for 5 seconds.";

var defense_gain:float;
var move_speed_loss:float;

func use()->void:
	parry_timer.start();
	## right now this is the only thing that alters movement speed
	## but will need to be more comprehensive eventually
	defense_gain = Entities.in_fight_player.defense;
	move_speed_loss = Entities.in_fight_player.move_speed - Entities.in_fight_player.move_speed/10
	
	var player:InFightPlayer = Entities.in_fight_player
	Combat.apply_stat_change(player, player, defense_gain, "defense")
	Combat.apply_stat_change(player, player, move_speed_loss*-1, "move_speed")
	
func release()->void:
	var player:InFightPlayer = Entities.in_fight_player
	Combat.apply_stat_change(player, player, defense_gain * -1, "defense");
	Combat.apply_stat_change(player, player, move_speed_loss, "move_speed");

extends Module;

@export var parry_timer:Timer;

const rarity = 1;


const cooldown = 5;
const sfx_key = "buckler";

const continuous = true;

var description:String = "Hold to reduce speed and damage and greatly increase your " + Index.stat_colored_name("defense") +\
", if an enemy attacks you immediately after activating [u]Module - Buckler[/u], the enemy is stunned.";

const base_defense_frac = .5;
const base_stun_duration = 3;

var defense_gain:float;
var attack_loss:float
var move_speed_loss:float;

var projection:TextureRect;

func use()->void:

	## TODO PARRY NOT IMPLEMENTED YET
	projection_blink();
	parry_timer.start();
	## right now this is the only thing that alters movement speed
	## but will need to be more comprehensive eventually
	var defense_frac: = base_defense_frac;
	var technique: = Entities.player_fighter.technique;
	if technique > 1:
		defense_frac *= technique
	defense_gain = Entities.player_fighter.defense * defense_frac;
	attack_loss = Entities.player_fighter.attack/2
	
	move_speed_loss = Entities.player_fighter.move_speed - Entities.player_fighter.move_speed/2
	
	var player:InFightPlayer = Entities.player_fighter
	Combat.apply_stat_change(player, player, defense_gain, "defense")
	Combat.apply_stat_change(player, player, attack_loss * -1, "attack")
	Combat.apply_stat_change(player, player, -move_speed_loss, "move_speed")
	
	
func projection_blink()->void:
	projection.show();

	projection.scale *= 1.5;
	projection.modulate.a = 1;
	
	var tween:Tween = create_tween();
	tween.tween_property(projection, "scale", Vector2.ONE, parry_timer.wait_time)
	tween.parallel().tween_property(projection, "modulate:a", .5, parry_timer.wait_time)
	
func release()->void:
	var player:InFightPlayer = Entities.player_fighter
	Combat.apply_stat_change(player, player, -defense_gain, "defense");
	Combat.apply_stat_change(player, player, attack_loss, "attack")
	Combat.apply_stat_change(player, player, move_speed_loss, "move_speed");
	projection.hide();


func check_parry(_damage:float, source:ActiveFighter)->void:
	if not parry_timer.is_stopped():
		Combat.stun_target(Entities.player_fighter, source, 3);


func _on_equipped() -> void:
	Entities.player_fighter.damage_taken.connect(check_parry)
	projection = Entities.player_fighter.equipment.module_aoe_vfx;
	projection.size = Vector2(100, 100);
	projection.position = Vector2(-75, -75)

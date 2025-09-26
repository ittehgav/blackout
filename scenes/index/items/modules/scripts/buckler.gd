extends Module;

@export var parry_timer:Timer;
@export var parry_cue:Sprite2D;
@export var parry_sfx:AudioStreamPlayer;
const rarity = 1;


func get_description()->String:
	return "Hold to reduce speed and damage and greatly increase your " + Index.stat_colored_name("defense") +\
	", if an enemy damages you immediately after activating [u]Module - Buckler[/u], the enemy is stunned.";


const base_defense_frac = .5;
const base_stun_duration = 3;

var defense_gain:float;
var attack_loss:float
var move_speed_loss:float;


func start()->void:
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
	
	var player:PlayerFighter = Entities.player_fighter
	Combat.apply_stat_change(player, player, defense_gain, "defense", false)
	Combat.apply_stat_change(player, player, attack_loss * -1, "attack", false);
	Combat.apply_stat_change(player, player, -move_speed_loss, "move_speed", false)
	
	cue_animation();
	
func cue_animation()->void:
	parry_cue.show();
	parry_cue.global_position = Entities.player_fighter.global_position
	animation_player.play("cue")
	await animation_player.animation_finished;
	parry_cue.hide();
	
func release()->void:
	var player:PlayerFighter = Entities.player_fighter
	Combat.apply_stat_change(player, player, -defense_gain, "defense", false);
	Combat.apply_stat_change(player, player, attack_loss, "attack", false)
	Combat.apply_stat_change(player, player, move_speed_loss, "move_speed", false);


func check_parry(_damage:float, source:ActiveFighter)->void:
	## matching the signature of damage_taken signal
	## only ever procs from npcfighters
	if not parry_timer.is_stopped() and source.base.skill_range == FighterBase.MELEE_RANGE:
		Combat.stun_target(Entities.player_fighter, source, 3);
		parry_sfx.play()


func _on_equipped() -> void:
	parry_cue.reparent(Entities.player_fighter.ally_team.projectiles)
	Entities.player_fighter.damage_taken.connect(check_parry)

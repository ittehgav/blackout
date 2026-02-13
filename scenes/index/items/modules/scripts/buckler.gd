extends Module;

@export var parry_timer:Timer;
@export var parry_cue:Sprite2D;
@export var parry_sfx:AudioStreamPlayer;
const rarity = 1;

@export var parry_stun:Status

var current_status:Status

func get_description()->String:
	return "Hold to reduce speed and damage and greatly increase your " + Index.stat_colored_name("defense") +\
	", if an enemy damages you immediately after activating [u]Module - Buckler[/u], the enemy is stunned.";


const base_defense_frac = .5;
const base_stun_duration = 3;




func start()->void:
	use_sfx.play()
	parry_timer.start();
	## right now this is the only thing that alters movement speed
	## but will need to be more comprehensive eventually


	current_status = status.apply_on_target(Entities.player_fighter);

	cue_animation();
	
func cue_animation()->void:
	parry_cue.show();
	parry_cue.global_position = Entities.player_fighter.global_position
	animation_player.play("cue")
	await animation_player.animation_finished;
	parry_cue.hide();
	
func release()->void:
	current_status.remove()

func check_parry(_damage:float, source:ActiveFighter)->void:
	## matching the signature of damage_taken signal
	## only ever procs from npcfighters
	if not parry_timer.is_stopped() and source.base.skill_range == SkillComponent.RangeOptions.melee:
		parry_stun.apply_on_target(source);
		parry_sfx.play()


func _on_equipped() -> void:
	parry_cue.reparent(Entities.player_fighter.ally_team.projectiles)
	Entities.player_fighter.damage_taken.connect(check_parry)

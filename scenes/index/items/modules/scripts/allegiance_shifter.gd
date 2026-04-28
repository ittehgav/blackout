extends Module

const rarity = 3

@export var tethers:VBoxContainer
@export var tether_1:TextureProgressBar;
@export var tether_2:TextureProgressBar

@export var proc_sfx:AudioStreamPlayer

@export var timer:Timer;
var conversion_target:ActiveFighter

func get_description()->String:
	return "Hold to start converting a nearby enemy, becoming unable to move and attack for the duration, when the conversion finishes, the enemy starts fighting for your party until the end of battle.";

func start()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	suppress_fighter(Entities.player_fighter)

	use_sfx.play()

	conversion_target = Entities.player_fighter.nearest_enemy()

	timer.start()
	tethers.show();

	tethers.global_position = Entities.player_fighter.global_position
	tethers.size.x = Entities.player_fighter.global_position.distance_to(conversion_target.global_position)
	
	tethers.rotation = Entities.player_fighter.global_position.angle_to_point(conversion_target.global_position)
	tether_loop()

var tether_tween:Tween
func tether_loop()->void:
	if tether_tween and tether_tween.is_running():
		tether_tween.kill();
	tether_1.value = 0;
	tether_2.value = 0;
	
	tether_tween = create_tween();
	tether_tween.tween_property(tether_1, "value", 100, .5)
	tether_tween.parallel().tween_property(tether_2, "value", 100, .5)
	tether_tween.tween_callback(tether_loop)


func release()->void:
	clear_suppress(Entities.player_fighter)
	process_mode = Node.PROCESS_MODE_INHERIT
	tethers.hide()
	timer.stop()

func _on_equipped() -> void:
	timer.wait_time -= (timer.wait_time/10) * Entities.player_fighter.technique
	tethers.reparent(Entities.player_fighter.ally_team.projectiles)


func _on_timer_timeout() -> void:
	proc_sfx.play();
	
	conversion_target.sprite.material.set_shader_parameter("width", 10);
	var tween:Tween = create_tween();
	tween.tween_property(conversion_target.sprite, "material:shader_parameter/width", 1, .5)
	
	Entities.player_fighter.ally_team.convert_fighter(conversion_target)
	Entities.player_fighter.equipment.module_control.release_module_command()

var player_pre_suppress_move_speed:int;
func suppress_fighter(target:ActiveFighter)->void:
	## make this a status node if i end up using it elsewhere?
	if target is PlayerFighter:
		player_pre_suppress_move_speed = target.move_speed;
		target.move_speed = 0
		target.equipment.process_mode = Node.PROCESS_MODE_DISABLED;
		
func clear_suppress(target:ActiveFighter)->void:
	if target is PlayerFighter:
		target.move_speed = player_pre_suppress_move_speed;
		target.equipment.process_mode = Node.PROCESS_MODE_INHERIT;

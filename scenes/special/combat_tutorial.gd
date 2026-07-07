@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_interrogation.png")
extends Node2D

signal section_cleared;

var chosen_weapon:Weapon;

@export var arena:Arena

@export var boundary_barriers:Array[StaticBody2D]

@export var player_fighter:PlayerFighter

@export var walking_instructions:Control;
@export var choose_a_weapon_instruction:Control;
@export var attack_instruction:Control
@export var destroy_obstacles_instruction:Control;
@export var use_module_instruction:Control;
@export var jump_over_obstacle_instruction:Control;
@export var defeat_all_enemies_instruction:Control


@export var equip_tailpipe_prompt:Control;
@export var equip_slingshot_prompt:Control

@export var tailpipe_sample:Sprite2D
@export var slingshot_sample:Sprite2D


@export var dummy:NpcFighter

@export var forward_arrow:Control;

@export var main_hud:Control;


#func _input(e:InputEvent)->void:
	### remove this before delivery please
	#if e.is_action_pressed("use_module"):
		#main_hud.show()
		#arena.finish_battle(true)


var to_reenable:Array[ActiveFighter]
func _on_arena_ready() -> void:
	for f:ActiveFighter in Entities.arena.team_1.fighters:
		if f != Entities.player_fighter:
			f.set_process_mode(Node.PROCESS_MODE_DISABLED);
			to_reenable.append(f)
			
	for f:ActiveFighter in Entities.arena.team_2.fighters:
		if not f.dummy:
			f.set_process_mode(Node.PROCESS_MODE_DISABLED);
			to_reenable.append(f)
	
	player_fighter.equipment.weapon_control.set_process(false)
	player_fighter.equipment.module_control.set_process(false)
	## so the fight ends
	## make a separate array for dummies and regular units:?
	arena.team_2.fighters.erase(dummy)
	
	await player_fighter.started_moving;
	Tweens.ui_fade_out(walking_instructions);
	show_forward_arrow()


func show_forward_arrow()->void:
	Tweens.ui_fade_in(forward_arrow)

func _on_tailpipe_area_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		equip_slingshot_prompt.hide();
		Tweens.ui_fade_in(equip_tailpipe_prompt)


func _on_slingshot_area_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		equip_tailpipe_prompt.hide();
		Tweens.ui_fade_in(equip_slingshot_prompt)

func weapon_chosen(chosen_tailpipe:bool=false)->void:
	if not player_fighter.equipment.visible:
		if chosen_tailpipe:
			## otherwise this just plays as the regular weapon switch sound
			player_fighter.equipment.weapon_control.sfx.play_sound_by_key("weapon_change")
			chosen_weapon = Entities.player_fighter.equipment.weapon_control.weapon
		else:
			chosen_weapon = Entities.player_fighter.equipment.weapon_control.alternative_weapon
			
		player_fighter.equipment.show()
		player_fighter.equipment.weapon_control.set_process(true)
		choose_a_weapon_instruction.hide();
		
		Tweens.ui_fade_in(attack_instruction)
		await player_fighter.equipment.weapon_used;
		show_forward_arrow()
		Tweens.ui_fade_out(attack_instruction)
		return
	chosen_weapon = Entities.player_fighter.equipment.weapon_control.alternative_weapon


func _process(_delta:float)->void:
	if Input.is_action_just_pressed("switch_weapon"):
		if equip_tailpipe_prompt.visible:
			weapon_chosen(true)
			slingshot_sample.self_modulate.v = 1
			tailpipe_sample.self_modulate.v = .1
			if not player_fighter.equipment.weapon_control.weapon.melee:
				player_fighter.equipment.weapon_control.switch_weapon()
				
		elif equip_slingshot_prompt.visible:
			weapon_chosen()
			slingshot_sample.self_modulate.v = .1
			tailpipe_sample.self_modulate.v = 1
			if player_fighter.equipment.weapon_control.weapon.melee:

				player_fighter.equipment.weapon_control.switch_weapon()

func _on_advance_boundary_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		var barrier:StaticBody2D = boundary_barriers[0];
		barrier.set_collision_layer_value(17, true)
		barrier.get_parent().set_collision_mask_value(17, false)
		boundary_barriers.pop_front()
		
		Tweens.ui_fade_out(forward_arrow)
		section_cleared.emit()


func _on_slingshot_area_body_exited(body: Node2D) -> void:
	if body == player_fighter:
		equip_slingshot_prompt.hide()


func _on_tailpipe_area_body_exited(body: Node2D) -> void:
	if body == player_fighter:
		equip_tailpipe_prompt.hide()


func _on_before_weapon_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		Tweens.ui_fade_in(choose_a_weapon_instruction);
		


func _on_before_obstacles_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		Tweens.ui_fade_in(destroy_obstacles_instruction)


func _on_after_obstacles_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		Tweens.ui_fade_out(destroy_obstacles_instruction)
		show_forward_arrow()


func _on_before_module_body_entered(body: Node2D) -> void:
	if body == player_fighter:
		Tweens.ui_fade_in(use_module_instruction);
		player_fighter.equipment.module_control.set_process(true)
		await player_fighter.equipment.module_used;
		Tweens.ui_fade_out(use_module_instruction);
		show_forward_arrow()


func _on_before_module_obstacles_body_entered(_body: Node2D) -> void:
	Tweens.ui_fade_in(jump_over_obstacle_instruction);


func _on_after_items_tutorial_body_entered(_body: Node2D) -> void:
	jump_over_obstacle_instruction.hide();
	Tweens.ui_fade_in(defeat_all_enemies_instruction)
	State.bgm.volume_db = 0;
	for unit:ActiveFighter in to_reenable:
		unit.set_process_mode(Node.PROCESS_MODE_INHERIT)
	Tweens.ui_fade_in(main_hud)
	
	await get_tree().create_timer(5).timeout
	Tweens.ui_fade_out(defeat_all_enemies_instruction)

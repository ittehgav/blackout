extends Control

class_name FighterOverlay

@export var outline:ReferenceRect;
@export var bg:ColorRect

@export var hp_bar:TextureProgressBar;
@export var hp_bar_trail:TextureProgressBar;

@export var shield_bar:TextureProgressBar;


@export var charge_bar:TextureProgressBar;
@export var floating_icon_anchor:Node2D

@export var cooldown_timer:Timer;
@export var fighter:ActiveFighter

@export var status_icons:HBoxContainer;

@export var status_display:TextureProgressBar
@export var special_statuses_container:HBoxContainer;


var trail_tween:Tween;

func _on_npc_fighter_ready() -> void:
	hp_bar.max_value = fighter.max_hp;
	hp_bar.value = fighter.hp;
	


	hp_bar_trail.max_value = fighter.max_hp;
	hp_bar_trail.value = fighter.hp;
	if not fighter.dummy:
		if fighter.base.omit_charge_bar:
			charge_bar.hide()
		charge_bar.max_value = cooldown_timer.wait_time;
		get_node("refresh_bar").start()


		shield_bar.max_value = fighter.max_hp;
	else:
		charge_bar.hide()

func on_status_applied(source:ActiveFighter, status:Status, quiet:bool)->void:
	if source is PlayerFighter:
		struck_by_player = true

	match status.type:
		"stun":
			display_stun_timer(status.duration)
			apply_color_blink(status.get_status_color())
		"stat_change":
			if not quiet:
				generate_floating_icon(status.stat, status.value > 0);
				apply_color_blink(status.get_status_color())
		"special":
			assert(status.special_status_texture);
			add_special_status_icon(status)

func add_special_status_icon(status:Status)->void:
	var icon:TextureRect = TextureRect.new();
	icon.custom_minimum_size = Vector2(16, 16);
	icon.texture = status.special_status_texture;
	special_statuses_container.add_child(icon);
	status.removed.connect(icon.queue_free)


func generate_floating_icon(key:String, positive:bool)->void:
	var icon:StatIcon = Index.scenes.ui.stat_icon.instantiate();
	icon.stat = key
	icon.floating = true;
	icon.positive = positive
	floating_icon_anchor.add_child(icon);


func display_stun_timer(duration:float)->void:
	var bar:TextureProgressBar = status_display.duplicate();
	status_icons.add_child(bar)
	bar.show()
	var tween:Tween = create_tween();
	## doesnt really need to change the max value of the texture?
	tween.tween_property(bar, "value", 0, duration)
	tween.tween_callback(bar.queue_free)
	bar.modulate = Color.PURPLE


func _on_fighter_damage_taken(damage: float, source:ActiveFighter, quiet:bool) -> void:
	if source is PlayerFighter:
		struck_by_player = true
	floating_number(int(damage))
	hp_bar.value = fighter.hp;
	
	if not quiet:
		apply_color_blink(FighterBase.combat_effect_colors.damage)
	


@onready var initial_position:Vector2 = position
var player_hit_tween:Tween



const min_fn_delay = .15
var current_floating_numbers:Array[Label]
func floating_number(value:int, type:String = "damage")->void:

	var floating_n:Label = Label.new();
	match type:
		"damage":
			floating_n.modulate = Color.RED
		"heal":
			floating_n.modulate = Color.GREEN
		"block":
			floating_n.modulate = Color.YELLOW.darkened(.2);
		"shield":
			floating_n.modulate = Color.YELLOW

	
	floating_n.text = str(value);
	floating_icon_anchor.add_child(floating_n);
	current_floating_numbers.append(floating_n)
	
	if len(current_floating_numbers) > 1:
		await get_tree().create_timer(min_fn_delay * len(current_floating_numbers)).timeout

	Tweens.fade_up(floating_n);
	await get_tree().create_timer(min_fn_delay).timeout;
	clear_floating_number(floating_n);

func clear_floating_number(target:Label)->void:
	current_floating_numbers.erase(target)

func refresh_charge_bar() -> void:
	if not fighter.dummy:
		charge_bar.value = cooldown_timer.wait_time - cooldown_timer.time_left


func _on_hp_bar_value_changed(value: float) -> void:
	if not trail_tween or not trail_tween.is_running():
		hp_bar_trail.self_modulate.a = 1;
		
		trail_tween = create_tween();
		trail_tween.tween_property(hp_bar_trail, "self_modulate:a", 0, .5)
		trail_tween.tween_callback(hp_bar_trail.set_value.bind(hp_bar.value))


func _on_npc_fighter_healing_received(value: float, _quiet:bool=false) -> void:
	floating_number(value, "heal");
	hp_bar.value = fighter.hp;
	apply_color_blink(FighterBase.combat_effect_colors.heal);
	
func refresh_charge_bar_max(_stat:String="")->void:
	charge_bar.max_value = cooldown_timer.wait_time;


func _on_npc_fighter_damage_blocked(_source: ActiveFighter, value: float, quiet:bool) -> void:
	shield_bar.value = fighter.shield
	
	if not quiet:
		floating_number(value, "block");
		Tweens.squish_bar(shield_bar);


func _on_npc_fighter_shield_gained(_source: ActiveFighter, value: float, quiet:bool) -> void:
	shield_bar.value = fighter.shield
	if not quiet:
		floating_number(value, "shield");
		Tweens.stretch_bar(shield_bar);


var pending_blink:bool=false;
var blink_color:Color;
var struck_by_player:bool=false
func play_color_blink()->void:
	if pending_blink:
		if not struck_by_player:
			blink_color.a = .5
		Tweens.shader_color_blink(fighter.sprite, blink_color);
		pending_blink = false
		struck_by_player = false;

func apply_color_blink(target:Color)->void:
	if not pending_blink:
		## pending_blink when this fn is called = 
		## other colors applied in current propagation
		blink_color = target;
	else:
		blink_color = target/2 + blink_color/2
	pending_blink = true;
	play_color_blink.call_deferred();


func on_fighter_knocked_back(source: ActiveFighter, _strength: int) -> void:
	if source is PlayerFighter:
		struck_by_player = true
	apply_color_blink(FighterBase.combat_effect_colors.knockback);

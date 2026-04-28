extends Control

@export var hud_section:VBoxContainer

@export var player_fighter:PlayerFighter;

@export var hp_bar:TextureProgressBar;
@export var status_bar:TextureProgressBar;

@export var floating_icon_anchor:Control

func _ready()->void:
	hp_bar.max_value = player_fighter.max_hp;
	hp_bar.value = player_fighter.hp;

@onready var bar_tween:Tween = create_tween();
func refresh_hp_bar(blink_color:Color = Color.WHITE)->void:
	const bar_refresh_time = .25
	if bar_tween.is_running():
		bar_tween.kill()
	bar_tween = create_tween()
	bar_tween.tween_property(hp_bar, "value", player_fighter.hp, bar_refresh_time);
	bar_tween.parallel().tween_property(hp_bar, "modulate", blink_color, bar_refresh_time);
	bar_tween.tween_property(hp_bar, "modulate", hp_frac_color(), bar_refresh_time)

func hp_frac_color()->Color:
	var fraction:float = float(player_fighter.hp)/float(player_fighter.max_hp)

	if fraction > .8:
		return Color(0.4, 1.0, 0.4, 1.0);
	elif fraction >= .6:
		return Color(0.361, 0.6, 0.361, 1.0);
	elif fraction >= .3:
		return Color(0.6, 0.6, 0.122, 1.0);
	else:
		return Color(0.6, 0.122, 0.122, 1.0)

var current_color_tween:Tween;
var current_color_tween_duration:float;
func _on_player_fighter_status_applied(_source: ActiveFighter, status: Status) -> void:
	match status.type:
		"stun":
			if current_color_tween and current_color_tween.is_running():
				if current_color_tween_duration - current_color_tween.get_total_elapsed_time()\
				> status.duration:
					current_color_tween.kill()
				else:
					return

			add_status_bar(Color.PURPLE, status.timer)
			current_color_tween_duration = status.duration
			hud_section.modulate = Color.PURPLE;
			
			var tween:Tween = create_tween();
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(hud_section, "modulate", Color.WHITE, current_color_tween_duration);
			
func ammo_consumed(type:String, _amount:int)->void:
	var icon:ResourceIcon = Index.scenes.ui.resource_icon.instantiate();
	icon.resource = type
	icon.floating = true;
	floating_icon_anchor.add_child(icon)
	

func add_status_bar(bar_color:Color, status_timer:Timer)->void:
	var bar:TextureProgressBar = status_bar.duplicate();
	bar.modulate = bar_color

	bar.show()
	add_child(bar);
	bar.max_value = status_timer.wait_time;
	bar.value = status_timer.wait_time;
	bar.size_flags_horizontal =Control.SIZE_EXPAND
	
	var tween:Tween = create_tween();
	tween.tween_property(bar, "value", 0, status_timer.wait_time);
	tween.tween_callback(bar.queue_free);

func _on_player_fighter_damage_taken(_damage: float, _source: ActiveFighter, _quiet:bool=false) -> void:
	refresh_hp_bar(Color.RED)


func _on_player_fighter_healing_received(_value: float, _quiet:bool=false) -> void:
	refresh_hp_bar(Color.GREEN);

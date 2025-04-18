extends Control

@export var leadership_exp_progress:ExperienceBar;
@export var combat_exp_progress:ExperienceBar;

@export var victory_label:Label;

@export var player_gains_panel:Panel;
@export var recruit_gains_panel:Panel;

@export var exp_gain_container:VBoxContainer;
@export var leadership_container:VBoxContainer;
@export var combat_container:VBoxContainer;

@export var loot_container:VBoxContainer;
@export var resource_loot_container:HBoxContainer;
@export var item_loot_container:GridContainer;

@export var food_icon:ResourceIcon;
@export var fuel_icon:ResourceIcon;
@export var money_icon:ResourceIcon;

@export var juice_icon:ResourceIcon;
@export var scrap_icon:ResourceIcon;
@export var chips_icon:ResourceIcon;

func show_post_fight(winner_n:int)->void:
	show()
	Entities.main_bgm.stop()
	var tween = Entities.arena.create_tween();
	tween.set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", .3, 1.5);
	tween.parallel().tween_property($bg, "modulate:a", 1, 1);
	await tween.finished
	Engine.time_scale = 1;
	
	for r in Index.all_resources:
		self[r+"_icon"].setup_adjacent_items(Entities.arena.battle_loot[r]);
	
	get_tree().paused = true;
	Entities.main_bgm.stop();
	if winner_n == 1:
		victory_animation()
		Entities.main_bgm.play_bgm("victory");
	else:
		show_defeat_view()
		Entities.main_bgm.play_bgm("defeat")

	
func victory_animation():
	const beat_delay = .5;
	const between_bits = 2;
	
	
	leadership_exp_progress.build_from_player("leadership");
	combat_exp_progress.build_from_player("combat");

	$victory_view.show();
	
	var exp_gain = Entities.arena.battle_exp_value;
	
	var tween = create_tween();
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(exp_gain_container, "position:x", 40, beat_delay);
	tween.tween_callback(leadership_exp_progress.animate.bind(exp_gain))
	tween.tween_property(exp_gain_container, "theme_override_constants/separation", 10,  beat_delay);
	tween.tween_callback(combat_exp_progress.animate.bind(exp_gain))
	tween.tween_interval(between_bits);
	tween.tween_callback(loot_container.show)
	tween.tween_property(resource_loot_container, "theme_override_constants/separation", 20, beat_delay);
	tween.tween_interval(beat_delay)
	tween.tween_callback(item_loot_container.show);
	

func _input(e:InputEvent):
	if (e is InputEventKey or e is InputEventMouseButton) and e.pressed:
		next_panel();
		
func next_panel():
	if $victory_view.visible and $victory_view.position.x == 0:
		var tween = create_tween();
		tween.tween_property($victory_view, "position:x", -5950, .5);
		tween.tween_callback(recruit_gains_panel.animate_levels);

func show_defeat_view():
	pass

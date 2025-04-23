extends Control

@export var leadership_exp_progress:ExperienceBar;
@export var combat_exp_progress:ExperienceBar;

@export var morale_icon:TextureRect;
@export var morale_label:Label;

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

func _ready()->void:
	morale_label.text = str(snapped(Entities.player.morale, .01));

func victory_animation()->void:
	const beat_delay = .5;
	const between_bits = 2;
	
	for r:String in Index.all_resources:
		self[r+"_icon"].setup_adjacent_items(Entities.arena.battle_loot[r]);
	
	leadership_exp_progress.build_from_player("leadership");
	combat_exp_progress.build_from_player("combat");

	show();
	
	var exp_gain:int = Entities.arena.battle_exp_value;
	Entities.player.battle_victory_morale();
	
	var tween := create_tween();
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(exp_gain_container, "position:x", 40, beat_delay);
	
	tween.tween_callback(animate_morale_label)

	tween.parallel().tween_callback(leadership_exp_progress.animate.bind(exp_gain))
	tween.tween_property(exp_gain_container, "theme_override_constants/separation", 10,  beat_delay);
	tween.tween_callback(combat_exp_progress.animate.bind(exp_gain))
	tween.tween_interval(between_bits);
	tween.tween_callback(loot_container.show)
	tween.tween_property(resource_loot_container, "theme_override_constants/separation", 20, beat_delay);
	tween.tween_interval(beat_delay)
	tween.tween_callback(item_loot_container.show);

func animate_morale_label()->void:
	var tween: = create_tween();
	tween.tween_method(update_morale_label, float(morale_label.text), Entities.player.morale, 2);
	tween.tween_callback(morale_icon.update)
	

func update_morale_label(target:float)->void:
	morale_label.text = str(snapped(target, .01))
	
func _input(e:InputEvent)->void:
	if visible and e is InputEventMouseButton and e.pressed:
		next_panel();
		
func next_panel()->void:
	if position.x == 0:
		var tween: = create_tween();
		tween.tween_property(self, "position:x", -5950, .5);
		tween.tween_callback(recruit_gains_panel.animate_levels);
	else:
		get_parent().end_post_fight();

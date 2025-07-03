extends Panel


@export var victory_title:Label
@export var player_name_label:Label;
@export var leadership_exp_gain:ExperienceBar;
@export var combat_exp_gain:ExperienceBar;
@export var step_timer:Timer;

@export var continue_btn:Button;
var step_finished:bool=false;

@export var unit_exp_gain_container:GridContainer;
@export var unit_exp_gain_scene:PackedScene
var all_recruit_exp_gains:Array[Control];

@export_group("Combat level up")
@export var combat_stat_points_label:Label;
@export var assign_points_mesage:Label

@export_subgroup("Max HP")
@export var max_hp_label:Label;
@export var add_max_hp:Button;
@export var remove_max_hp:Button;

@export_subgroup("Attack")
@export var attack_label:Label;
@export var add_attack:Button;
@export var remove_attack:Button;

@export_subgroup("Defense")
@export var defense_label:Label;
@export var add_defense:Button;
@export var remove_defense:Button;

@export_subgroup("Agility")
@export var agility_label:Label;
@export var add_agility:Button;
@export var remove_agility:Button;

@export_subgroup("Technique")
@export var technique_label:Label;
@export var add_technique:Button;
@export var remove_technique:Button;

var remaining_combat_stat_points:int = 0;

var assigned_stat_points:Dictionary[String, int] = {
	## only 
	"max_hp":0,
	"attack":0,
	"defense":0,
	"agility":0,
	"technique":0
}


func _ready()->void:
	## runs as post_battle starts
	## maybe keeps the game from laggin when done as arena loads rather than right as it needs to play?
	leadership_exp_gain.build_from_player("leadership")
	combat_exp_gain.build_from_player("combat")
	assign_points_message_blink();
	
	player_name_label.text = Entities.player.name;

	for unit:FighterUnit in Entities.player.roster.units:
		var display:Control = unit_exp_gain_scene.instantiate();
		display.build(unit);
		unit_exp_gain_container.add_child(display)
		all_recruit_exp_gains.append(display)
		
func assign_points_message_blink()->void:
	var tween: = create_tween();
	tween.tween_property(assign_points_mesage, "modulate:v", .1, .75);
	tween.tween_property(assign_points_mesage, "modulate:v", 1, .75);
	
	tween.tween_callback(assign_points_message_blink)

func distribute_exp()->void:
	step_timer.start()
	victory_title.rotation_degrees = randf_range(-90, 90);
	
	var tween:Tween = create_tween();
	tween.tween_property(victory_title, "rotation_degrees", victory_title.rotation_degrees * -1, .05);
	tween.tween_property(victory_title, "rotation_degrees", 0, .1)
	
	var exp_gain:float = Entities.arena.battle_exp_value;
	
	leadership_exp_gain.gain_exp(exp_gain)
	combat_exp_gain.gain_exp(exp_gain);
	
	for d in all_recruit_exp_gains:
		d.exp_bar.gain_exp(exp_gain);


func _on_step_timeout() -> void:
	step_finished = true



func refresh_stat_points()->void:
	combat_stat_points_label.text = "Stat Points: " + str(remaining_combat_stat_points);
	continue_btn.disabled = remaining_combat_stat_points;
	if remaining_combat_stat_points:
		assign_points_mesage.show();
	else:
		assign_points_mesage.hide()
	for stat:String in Index.all_combat_stats:
		var label:Label = self[stat+"_label"];
		var add_btn:Button = self["add_"+stat];
		var remove_btn:Button = self["remove_"+stat]
		
		remove_btn.disabled = assigned_stat_points[stat] == 0;
		add_btn.disabled = not remaining_combat_stat_points;
		
		var final_stat_value:float = snapped(Entities.player.combat_stats[stat] + Scaling.player_stats_per_point[stat] * assigned_stat_points[stat], .01);
		label.text = str(final_stat_value)

func _on_combat_exp_level_up() -> void:
	remaining_combat_stat_points += 1;
	refresh_stat_points();
	
	combat_stat_points_label.show();
	combat_stat_points_label.add_theme_font_size_override("font_size", 96);
	
	var tween: = create_tween();
	tween.tween_property(combat_stat_points_label, "theme_override_font_sizes/font_size", 64, .25);
	for stat:String in Index.all_combat_stats:
		self["add_"+stat].show();
		self["remove_"+stat].show();
	


func remove_stat_point(stat: String) -> void:
	remaining_combat_stat_points += 1;
	assigned_stat_points[stat] -= 1
	refresh_stat_points()


func add_stat_point(stat: String) -> void:
	remaining_combat_stat_points -= 1;
	assigned_stat_points[stat] += 1
	refresh_stat_points()


func _on_continue_pressed() -> void:
	for stat:String in Index.all_combat_stats:
		Entities.player.combat_stats[stat] += Scaling.player_stats_per_point[stat] * assigned_stat_points[stat]
	get_parent().show_loot()

extends Panel


@export var victory_title:Label
@export var leadership_exp_gain:ExperienceBar;
@export var combat_exp_gain:ExperienceBar;
@export var step_timer:Timer;

var step_finished:bool=false;

@export var unit_exp_gain_container:GridContainer;
@export var unit_exp_gain_scene:PackedScene
var all_recruit_exp_gains:Array[Control];

func _ready()->void:
	## runs as post_battle starts
	## maybe keeps the game from laggin when done as arena loads rather than right as it needs to play?
	leadership_exp_gain.build_from_player("leadership")
	combat_exp_gain.build_from_player("combat")
	

	
	
	for unit:FighterUnit in Entities.player.roster.units:
		var display:Control = unit_exp_gain_scene.instantiate();
		display.build(unit);
		unit_exp_gain_container.add_child(display)
		all_recruit_exp_gains.append(display)
	
		

func distribute_exp()->void:
	step_timer.start()
	victory_title.rotation_degrees = randf_range(-90, 90);
	
	var tween:Tween = create_tween();
	tween.tween_property(victory_title, "rotation_degrees", victory_title.rotation_degrees * -1, .05);
	tween.tween_property(victory_title, "rotation_degrees", 0, .1)
	
	var exp_gain:float = Entities.arena.battle_exp_value;
	
	leadership_exp_gain.animate(exp_gain)
	combat_exp_gain.animate(exp_gain);
	
	for d in all_recruit_exp_gains:
		d.exp_bar.animate(exp_gain);


func _on_step_timeout() -> void:
	step_finished = true

func _on_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and step_finished:
		get_parent().show_loot();

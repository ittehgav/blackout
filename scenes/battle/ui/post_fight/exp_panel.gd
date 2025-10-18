extends Panel

@export var player_exp_bar:ExperienceBar;
@export var exp_gain_scene:PackedScene
@export var exp_gains_container:VBoxContainer

var unit_exp_gain_displays:Array[PanelContainer];

func _ready()->void:
	for unit:FighterUnit in Entities.player.roster.units:
		
		var gain:PanelContainer = exp_gain_scene.instantiate()
		gain.load_unit(unit)
		unit_exp_gain_displays.append(gain)
		exp_gains_container.add_child(gain)
		

func distribute_exp()->void:
	var bounty:int = Entities.arena.team_2.roster.get_exp_bounty();
	for display:PanelContainer in unit_exp_gain_displays:
		var bar:ExperienceBar = display.bar;
		bar.gain_exp(bounty);
	player_exp_bar.gain_exp(bounty);
	
	

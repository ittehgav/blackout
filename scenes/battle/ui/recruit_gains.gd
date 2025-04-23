extends Panel


@export var unit_display:HBoxContainer;
@export var grid:GridContainer;

var unit_exp_bars:Array[ExperienceBar]

func _ready()->void:
	for unit:FighterUnit in Entities.player.roster.units:
		## where we filter the units who didnt fight when that becomes a thingyou can do
		var display :HBoxContainer= unit_display.duplicate();
		display.display_recruit_data(unit);
		unit_exp_bars.append(display.exp_bar)
		grid.add_child(display);


func animate_levels()->void:
	for bar:ExperienceBar in unit_exp_bars:
		bar.animate(Entities.arena.battle_exp_value);

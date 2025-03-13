extends Panel

@export var sprite_sample_scene:PackedScene;

@export var recruit_full_view:Container;

@export var recruits_grid:GridContainer;

func _ready():
	for unit:FighterUnit in Entities.player.roster.units:
		var sample:SpriteSample = sprite_sample_scene.instantiate();
		sample.set_sample(unit.base)
		recruits_grid.add_child(sample)
		sample.gui_input.connect(show_more.bind(unit))
		
		
func show_more(e:InputEvent, unit:FighterUnit):
	if e is InputEventMouseButton and e.pressed:
		recruit_full_view.display_recruit(unit)

extends Panel

@export var ui_sfx:AudioStreamPlayer;

@export var recruit_full_view:Container;

@export var recruits_grid:GridContainer;

func _ready()->void:
	for unit:FighterUnit in Entities.player.roster.units:
		var sample:SpriteSample = Index.sprite_sample_scene.instantiate();
		sample.get_node("additional_data").text = "Lv. " + str(unit.level);
		sample.set_sample(unit.base, Entities.player.color_scheme_index)
		recruits_grid.add_child(sample)
		sample.gui_input.connect(show_more.bind(unit))
		
		
func show_more(e:InputEvent, unit:FighterUnit)->void:
	if e is InputEventMouseButton and e.pressed:
		ui_sfx.play_stream("button_click")
		recruit_full_view.display_recruit(unit)

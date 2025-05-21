extends Control

@export var ui_sfx:AudioStreamPlayer;

@export var recruit_full_view:Container;

@export var recruits_grid:GridContainer;

@export var upgrade_hint:TextureRect

func refresh_data()->void:
	for c in recruits_grid.get_children():
		c.queue_free()
	
	for unit:FighterUnit in Entities.player.roster.units:
		var sample:SpriteSample = Index.sprite_sample_scene.instantiate();
		sample.get_node("additional_data").text = "Lv. " + str(unit.level);
		sample.set_sample(unit.base)
		recruits_grid.add_child(sample)
		sample.gui_input.connect(show_more.bind(unit))
		
		if unit.upgrade_available():
			var hint:TextureRect = upgrade_hint.duplicate();
			hint.show()
			sample.add_child(hint)
		
		
func show_more(e:InputEvent, unit:FighterUnit)->void:
	if e is InputEventMouseButton and e.pressed:
		ui_sfx.play_stream("button_click")
		recruit_full_view.display_recruit(unit)

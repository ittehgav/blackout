extends ItemTargetSelector

class_name ItemSelector
@export var player_body_scene:PackedScene

@export var options_hbox:HBoxContainer

func show_options(options:Array, source:Item)->void:
	get_parent().sfx.play_sound_by_key("item_target")
	options_hbox.queue_free();
	options_hbox = HBoxContainer.new();
	add_child(options_hbox)
	for item:Item in options:
		var sample:ItemSample = Index.scenes.ui.item_sample.instantiate();
		sample.load_item(item, 4, true);
		
		var wearer_sprite:Sprite2D;
		if item in Entities.player.equipment:
			wearer_sprite = player_body_scene.instantiate();

		elif item in Entities.player.roster.equipped_accessories:
			## only ever gets here if item is accessory
			var wearer:FighterUnit = Entities.player.roster.units.filter(find_wearer.bind(item))[0]
			wearer_sprite = wearer.base.duplicate();
		
		if wearer_sprite:
			wearer_sprite.scale = Vector2(.5, .5)
			var anchor:Control = Control.new();
			anchor.add_child(wearer_sprite);
			anchor.set_anchors_preset(PRESET_TOP_RIGHT);
			sample.add_child(anchor);
			wearer_sprite.top_level = true;
			anchor.position += Vector2(-10,15)
			
		sample.clicked.connect(item_chosen.bind(source))
		options_hbox.add_child(sample);
	fit_to_window()
	
	Tweens.ui_fade_in(self);



func find_wearer(unit:FighterUnit, accessory:Accessory)->bool:
	return unit.equipped_accessory == accessory;




func item_chosen(target:Item, source:Item)->void:
	source.use_on_item(target);
	Tweens.ui_fade_out(self);
	if source.use_sfx:
		source.mirror.display.sfx.play_sound_obj(source.use_sfx);
	source.mirror.display.board_shake(5);
	source.mirror.display.remove_mirror(source.mirror);
	Entities.player_sheet.refresh_data();

extends PanelContainer

@export var options_hbox:HBoxContainer

func clear_options()->void:
	options_hbox.queue_free()
	options_hbox = HBoxContainer.new();
	add_child(options_hbox)

func show_options(accessory:Accessory)->void:
	clear_options()
	
	generate_options(accessory);
	global_position = get_global_mouse_position();
	Tweens.ui_fade_in(self);
	
func generate_options(accessory:Accessory)->void:
	var options:Array[Node];
	if accessory.equippable.player:
		options.append(Entities.player);
	if accessory.equippable.unit:
		if accessory.exclusive_tag:
			for unit:FighterUnit in Entities.player.roster.units:
				if unit.base.tags.has(accessory.exclusive_tag):
					options.append(unit);
		else:
			options.append_array(Entities.player.roster.units);
	
	for option:Node in options:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		if option is Player:
			sample.load_player(accessory.mirror.equip_accessory_on_player)
		else:
			assert(option is FighterUnit);
			sample.load_unit(option, accessory.mirror.equip_accessory_on_unit.bind(option))
		sample.pressed.connect(Tweens.ui_fade_out.bind(self));
		options_hbox.add_child(sample)

func _on_mouse_exited() -> void:
	await get_tree().create_timer(.5).timeout;
	var rect:Rect2 = get_global_rect();

	if not rect.has_point(get_global_mouse_position()):
		Tweens.ui_fade_out(self)

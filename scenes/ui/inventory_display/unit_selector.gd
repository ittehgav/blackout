extends PanelContainer

class_name UnitSelector



@export var options_hbox:HBoxContainer

func clear_options()->void:
	options_hbox.queue_free()
	options_hbox = HBoxContainer.new();
	add_child(options_hbox)

func show_options(item:Item)->void:
	get_parent().sfx.play_sound_by_key("consumable_target")
	clear_options()
	
	if item is Accessory:
		generate_equip_options(item);
	elif item is Consumable:
		generate_use_options(item)
		
	global_position = get_global_mouse_position();
	var window_size:Vector2 = get_window().size;

	if global_position.x + size.x > window_size.x:
		global_position.x -= size.x;
	elif global_position.x < 0:
		global_position.x += size.x;
	if global_position.y + size.y > window_size.y:
		global_position.y -= size.y
	elif global_position.y < 0:
		global_position.y += size.y
	set_anchors_preset(PRESET_CENTER)
	
	Tweens.ui_fade_in(self);
	size = Vector2.ZERO

func play_item_use_sound(item:Consumable)->void:
	item.mirror.display.sfx.play_sound_obj(item.use_sfx)

func generate_use_options(item:Consumable)->void:
	var targets:Array[FighterUnit]
	if item.tag_target:
		targets = Entities.player.roster.units.filter(func(f:FighterUnit)->bool:return item.tag_target in f.base.tags);
	else:
		targets = Entities.player.roster.units;
	
	for target:FighterUnit in targets:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		sample.load_unit(target, item.use_on_unit.bind(target));
		
		sample.pressed.connect(Tweens.ui_fade_out.bind(self));
		
		if item.use_sfx:
			sample.pressed.connect(play_item_use_sound.bind(item));
		## would i rather make the remove_mirror only ever be called in the mirror's script?
		sample.pressed.connect(item.mirror.display.remove_mirror.bind(item.mirror));
		sample.pressed.connect(item.mirror.display.board_shake)
		options_hbox.add_child(sample);
		

func generate_equip_options(accessory:Accessory)->void:
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

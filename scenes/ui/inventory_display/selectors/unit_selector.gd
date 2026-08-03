extends ItemTargetSelector
class_name UnitSelector



@export var options_container:GridContainer

func clear_options()->void:
	options_container.queue_free()
	options_container  = GridContainer.new();
	options_container.columns = 5
	add_child(options_container)

func show_options(item:Item)->void:
	get_parent().sfx.play_sound_by_key("item_target")
	clear_options()
	
	if item is Accessory:
		generate_equip_options(item);
	elif item is Consumable:
		generate_use_options(item)

	fit_to_window()
	Tweens.ui_fade_in(self);
	size = Vector2.ZERO
	

func play_item_use_sound(item:Consumable)->void:
	item.mirror.display.sfx.play_sound_obj(item.use_sfx)

func generate_use_options(item:Consumable)->void:
	var targets:Array[FighterUnit]
	
	targets = Entities.player.roster.units.filter(item.filter_valid_target);

	
	for target:FighterUnit in targets:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		sample.load_unit(target, item.use_on_unit.bind(target));
		sample.pressed.connect(Tweens.ui_fade_out.bind(self));
		sample.pressed.connect(Entities.player_sheet.consumable_feedback.bind(item))
		if item.use_sfx:
			sample.pressed.connect(play_item_use_sound.bind(item));
		## would i rather make the remove_mirror only ever be called in the mirror's script?
		sample.pressed.connect(item.mirror.display.remove_mirror.bind(item.mirror));
		sample.pressed.connect(item.mirror.display.board_shake)
		options_container.add_child(sample);
	fit_to_window()
		

func generate_equip_options(accessory:Accessory)->void:
	var options:Array[Node];
	if accessory.equippable.player:
		options.append(Entities.player);
	if accessory.equippable.unit:
		if accessory.tag_restriction:
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
		options_container.add_child(sample)

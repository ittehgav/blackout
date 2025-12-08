extends UIRoot;

class_name EvolutionMenu;
@export var options_hbox:HBoxContainer

@export var evolution_prompt:PanelContainer

func load_options(tag:FighterBase.Tag )->void:
	## only gets here if player has at least one unit with tag
	## dont have to be ready for upgrade
	## (in whatever the conditions may end up being determined)
	modulate = Index.primary_tag_colors[str(tag)].blend(Color.WHITE)
	var units_with_tag:Array[FighterUnit] = Entities.player.roster.units.filter(can_evolve.bind(tag))
	assert(len(units_with_tag));
	for unit:FighterUnit in units_with_tag:
		var option:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		option.load_unit(unit, show_upgrade_prompt.bind(unit))
		if unit.level < 5:
			option.disabled = true
		options_hbox.add_child(option)
	
func can_evolve(unit:FighterUnit, tag:FighterBase.Tag)->bool:
	return "evolutions" in unit.base and tag in unit.base.tags;

func show_upgrade_prompt(target:FighterUnit)->void:
	evolution_prompt.display_evolutions(target)


func _on_button_pressed() -> void:
	close()
	

func close()->void:
	await Tweens.ui_fade_out(self).finished
	get_parent().queue_free()

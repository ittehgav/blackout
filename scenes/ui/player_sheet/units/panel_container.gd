extends PanelContainer

@export var ev1_sprite:Sprite2D;
@export var ev2_sprite:Sprite2D;

@export var hint_label:Label;

func setup(unit:FighterUnit)->void:
	if not "evolutions" in unit.base:
		hide();
		return;
	if unit.level >= 5:
		set_evolution_hint(unit.base);
		ev1_sprite.modulate.v = 1;
		ev2_sprite.modulate.v = 1;
	else:
		hint_label.text = "Level up this unit to evolve it"
		ev1_sprite.modulate.v = 0;
		ev2_sprite.modulate.v = 0;
	
	var ev1_base:FighterBase = Index.fighters.find_base(unit.base.evolutions[0]);
	var ev2_base:FighterBase = Index.fighters.find_base(unit.base.evolutions[1]);
	
	ev1_sprite.texture = ev1_base.texture.duplicate();
	ev2_sprite.texture = ev2_base.texture.duplicate();
	

func set_evolution_hint(base:FighterBase)->void:
	var evolution_location:String;
	if "bodybuilder" in base.tags:
		evolution_location = "Gym";
	elif "mechanic" in base.tags:
		evolution_location = "Chop Shop"
	elif "scientist" in base.tags:
		evolution_location = "Laboratory"

	
	hint_label.text = "Visit a " + evolution_location + " to evolve this unit.";

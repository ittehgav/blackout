extends Button

class_name UnitSample;

@export var accessory_sample:ItemSample;




func load_unit(unit:FighterUnit, callback:Callable)->void:
	$level.text = "Lv. " + str(unit.level);
	
	var base:FighterBase = unit.base.duplicate();
	base.scale = Vector2.ONE;
	base.centered = false;
	base.material = null;
	add_child(base);
	
	if unit.equipped_accessory:
		accessory_sample.load_item(unit.equipped_accessory,  1);
	else:
		accessory_sample.load_blank(1);
	
	pressed.connect(callback);
	
func load_player(callback:Callable)->void:
	var body:Sprite2D = Index.scenes.player_body.instantiate();
	body.scale = Vector2.ONE;
	body.centered = false;
	body.material = null;
	add_child(body)
	
	pressed.connect(callback)
	accessory_sample.queue_free()

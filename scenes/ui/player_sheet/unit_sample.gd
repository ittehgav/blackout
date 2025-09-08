extends Button

class_name UnitSample;



func load_unit(unit:FighterUnit, callback:Callable)->void:
	$level.text = "Lv. " + str(unit.level);
	
	var base:FighterBase = unit.base.duplicate();
	base.scale = Vector2.ONE;
	base.centered = false;
	base.material = null;
	add_child(base);
	
	pressed.connect(callback);
	
func load_player(callback:Callable)->void:
	var body:Sprite2D = Index.scenes.player_body.instantiate();
	body.scale = Vector2.ONE;
	body.centered = false;
	body.material = null;
	add_child(body)
	
	pressed.connect(callback)

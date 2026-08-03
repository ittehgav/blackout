extends PanelContainer



@export var artifice_1_display:TextureRect
@export var artifice_1_count:Label;
@export var artifice_1_highlight:TextureRect
@export var artifice_1_keybind:Label;

@export var artifice_2_display:TextureRect;
@export var artifice_2_count:Label;
@export var artifice_2_highlight:TextureRect
@export var artifice_2_keybind:Label;


@export var artifice_3_display:TextureRect
@export var artifice_3_count:Label;
@export var artifice_3_highlight:TextureRect
@export var artifice_3_keybind:Label;


func _on_player_fighter_ready() -> void:
	var dict:Dictionary = Entities.player.equipped_artifices;
	for key:int in dict.keys():
		var artifice:Artifice = dict[key]
		if artifice:
			load_artifice(artifice, key)
		else:
			get_node("artifices/artifice_"+str(key)).hide()
			var separator:HSeparator =get_node_or_null("artifices/HSeparator"+str(key))
			if separator:
				separator.hide()
	
	Entities.player.equipment_changed.connect(_on_player_equipment_changed)
			
func _on_player_equipment_changed(which:Equipment)->void:
	if which is Artifice:
		var slot:int = which.get_equipped_slot();
		if slot:
			refresh_artifice_count(slot)
			

func load_artifice(target:Artifice, slot:int)->void:
	var display:TextureRect = self["artifice_"+str(slot)+"_display"];
	var count_label:Label = self["artifice_"+str(slot)+"_count"]
	display.texture = target.texture;
	display.custom_minimum_size = Vector2(target.size_x, target.size_y) * 32

	display.modulate = Index.get_color(target.color_tag)
	
	
	var count:int = Entities.player.inventory.get_item_count(target);
	count_label.text = str(count)
	if target.use_type == Artifice.UseType.passive:
		var kb:Label = self["artifice_"+str(slot)+"_keybind"];
		kb.modulate.a = .5
		kb.modulate.v = .85
	


func _on_equipment_artifice_aiming_started(which: int) -> void:
	self["artifice_"+str(which)+"_highlight"].show()

func _on_equipment_artifice_aiming_stopped(which: int) -> void:
	self["artifice_"+str(which)+"_highlight"].hide()

func _on_equipment_artifice_used(which: int) -> void:
	self["artifice_"+str(which)+"_highlight"].hide()
	var target:TextureRect = self["artifice_"+str(which)+"_display"];
	var tween:Tween = create_tween();
	tween.tween_property(target, "offset_transform_scale", Vector2(2,2), .1)
	tween.tween_property(target, "offset_transform_scale", Vector2.ONE, .1)
	refresh_artifice_count(which)
	
func refresh_artifice_count(which:int)->void:
	var artifice:Artifice = Entities.player.equipped_artifices[which]
	var display:TextureRect = self["artifice_"+str(which)+"_display"]
	var count_label:Label = self["artifice_"+str(which)+"_count"]
	var count:int = 0;
	if not Entities.player.equipped_artifices[which]:
		display.modulate.a = .5;
		display.modulate.v = .5;
		
		count_label.modulate.a = .5;
		count_label.modulate.v = .5;
	else:
		## so they can regenerate when artifices 
		## are regained/reloaded during combat
		display.modulate.a = 1;
		display.modulate.v = 1;
		
		count_label.modulate.a = 1;
		count_label.modulate.v = 1;
		count = Entities.player.inventory.get_item_count(artifice);
	count_label.text = str(count)
	

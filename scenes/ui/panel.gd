extends Panel

@export var title_label:Label;

@export var confirmation:Control;

@export var evolution_texture_buffer:Node2D;

@export_group("Evolution 1")

@export var evolution_1_sprite:TextureRect;
@export var evolution_1_overlay:ColorRect;

@export var evolution_1_costs_container:HBoxContainer
@export var evolution_1_cost_1_icon:ResourceIcon
@export var evolution_1_cost_1_label:Label;
@export var evolution_1_cost_2_icon:ResourceIcon;
@export var evolution_1_cost_2_label:Label;

@export_group("Evolution 2")


@export var evolution_2_sprite:TextureRect;
@export var evolution_2_overlay:ColorRect;

@export var evolution_2_costs_container:HBoxContainer;
@export var evolution_2_cost_1_icon:ResourceIcon
@export var evolution_2_cost_1_label:Label;
@export var evolution_2_cost_2_icon:ResourceIcon;
@export var evolution_2_cost_2_label:Label;

var can_evolve:bool;

var enough_resources_for_ev1:bool;
var enough_resources_for_ev2:bool;

var unit:FighterUnit

var evolution_1_base:FighterBase;
var evolution_1_resource_1:String
var evolution_1_cost_1:int;
var evolution_1_resource_2:String
var evolution_1_cost_2:int;

var evolution_2_base:FighterBase;
var evolution_2_resource_1:String
var evolution_2_cost_1:int;
var evolution_2_resource_2:String
var evolution_2_cost_2:int;

func setup(target:FighterUnit)->void:
	confirmation.get_parent().hide();
	for c in evolution_texture_buffer.get_children():
		c.free();
	
	unit = target
	
	enough_resources_for_ev1 = true
	enough_resources_for_ev2 = true
	
	if "evolutions" in unit.base:
		show();
		var i:int = 1;
		can_evolve = unit.level >= 10;
		
		for evolution:String in unit.base.evolutions.keys():
			self["evolution_" + str(i) + "_base"] = Index[evolution+"_scene"].instantiate();
			evolution_texture_buffer.add_child(self["evolution_" + str(i) + "_base"]);
			
			var image:Image = Image.load_from_file("res://assets/visual/sprites/fighters/"+evolution.replace("_", "")+".png")
			var texture:Texture2D = ImageTexture.create_from_image(image);
			var atlas:AtlasTexture = AtlasTexture.new();
			atlas.region.position.x = 10;
			atlas.region.size.x = 180;
			atlas.region.size.y = 100;
			atlas.atlas = texture;
			atlas.resource_local_to_scene = true
			
			var pairs:Dictionary[Color,Color] = ColorCoder.scheme_to_sprite_color_pairs(Entities.player)
			self["evolution_" + str(i) + '_sprite'].texture = ColorCoder.color_code_texture(atlas, pairs)
			
			var i2:int = 1;
			for resource:String in unit.base.evolutions[evolution].keys():
				self["evolution_" + str(i) + "_resource_" + str(i2)] = resource;
				
				var cost:int = unit.base.evolutions[evolution][resource];
				self["evolution_" + str(i) + "_cost_" + str(i2)] = cost
				
				var icon:ResourceIcon = self["evolution_" + str(i) + "_cost_" + str(i2) + '_icon']
				icon.resource = resource
				icon.setup()
				
				if Entities.player.inventory[resource] < cost:
					self["enough_resources_for_ev" + str(i)] = false;
				
				var label:Label = self["evolution_" + str(i) + "_cost_" + str(i2) + '_label']
				label.text = str(cost);
				
				i2 += 1;
				
			i += 1;
		if can_evolve:
			title_label.hide();
			evolution_1_sprite.modulate = Color.WHITE;
			evolution_2_sprite.modulate = Color.WHITE;
			
			evolution_1_costs_container.show();
			evolution_2_costs_container.show();
		else:
			evolution_1_sprite.modulate.v = 0;
			evolution_1_sprite.modulate.a = .5;
			
			evolution_2_sprite.modulate.v = 0;
			evolution_2_sprite.modulate.a = .5;

			evolution_1_costs_container.hide();
			evolution_2_costs_container.hide();

	else:
		hide();
			
			
func evolution_confirmation(evolution_index:int)->void:
	var r1:String = self["evolution_" + str(evolution_index) + "_resource_1"];
	var c1:int = self["evolution_" + str(evolution_index) + "_cost_1"]
	
	var r2:String = self["evolution_" + str(evolution_index) + "_resource_2"];
	var c2:int = self["evolution_" + str(evolution_index) + "_cost_2"]
	
	var base:FighterBase = self["evolution_" + str(evolution_index) + "_base"]
	confirmation.generate_confirmation(unit, base, r1, c1, r2, c2 )
#func generate_confirmation(unit:FighterUnit, new_base:FighterBase, resource_1:String, cost_1:int, resource_2:String, cost_2:int)->void:



func _on_ev1_overlay_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and can_evolve:
		if enough_resources_for_ev1:
			evolution_confirmation(1);

func _on_ev1_overlay_mouse_entered() -> void:
	evolution_1_overlay.color.a = .5

func _on_ev1_overlay_mouse_exited() -> void:
	evolution_1_overlay.color.a = 0




func _on_ev2_overlay_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and can_evolve:
		if enough_resources_for_ev2:
			evolution_confirmation(2);

func _on_ev2_overlay_mouse_entered() -> void:
	evolution_2_overlay.color.a = .5

func _on_ev2_overlay_mouse_exited() -> void:
	evolution_2_overlay.color.a = 0

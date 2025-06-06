extends Panel

@export var title_label:Label;

@export var confirmation:Control;

@export var evolution_texture_buffer:Node2D;

@export_group("Evolution 1")

@export var evolution_1_sprite:TextureButton;
@export var evolution_1_panel:Panel;

@export var evolution_1_costs_container:HBoxContainer
@export var evolution_1_cost_1_icon:ResourceIcon
@export var evolution_1_cost_1_label:Label;
@export var evolution_1_cost_2_icon:ResourceIcon;
@export var evolution_1_cost_2_label:Label;

@export_group("Evolution 2")


@export var evolution_2_sprite:TextureButton;
@export var evolution_2_panel:Panel;

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
			self["evolution_" + str(i) + '_sprite'].texture_normal = ColorCoder.color_code_texture(atlas, pairs)
			self["evolution_" + str(i) + '_sprite'].texture_hover = ColorCoder.color_code_texture(atlas, pairs)
			
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
			
		if title_label_tween and title_label_tween.is_running():
			title_label_tween.kill();
		
		if can_evolve:
			title_label.text = "EVOLUTION AVAILABLE!"
			title_label.add_theme_font_size_override("font_size", 48)
			evolution_label_highlight_tween();
			evolution_1_sprite.modulate = Color.WHITE;
			evolution_2_sprite.modulate = Color.WHITE;
			
			evolution_1_costs_container.show();
			evolution_2_costs_container.show();
		else:

			title_label.text = "Bring this unit to level 10 to unlock upgrades."
			title_label.add_theme_font_size_override("font_size", 32)
			title_label.add_theme_constant_override("outline_size",0)
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







var title_label_tween:Tween;
func evolution_label_highlight_tween()->void:
	title_label_tween = create_tween();
	title_label_tween.tween_property(title_label, "theme_override_constants/outline_size", 6, .75);
	title_label_tween.tween_callback(title_label.add_theme_constant_override.bind("outline_size",0));
	title_label_tween.tween_callback(evolution_label_highlight_tween)


func _on_evolution_1_pressed() -> void:
	evolution_confirmation(1)


func _on_evolution_2_pressed() -> void:
	evolution_confirmation(2)


func _on_evolution_1_mouse_entered() -> void:
	evolution_1_panel.show()

func _on_evolution_2_mouse_entered() -> void:
	evolution_2_panel.show()

func _on_evolution_1_mouse_exited() -> void:
	evolution_1_panel.hide()


func _on_evolution_2_mouse_exited() -> void:
	evolution_2_panel.hide();

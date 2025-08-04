extends Panel

@export var title_label:Label;

@export var confirmation:Control;

@export var evolution_texture_buffer:Node2D;

@export_group("Evolution 1")

@export var evolution_1_sprite:TextureButton;
@export var evolution_1_panel:Panel;
@export var evolution_1_highlight:ColorRect

@export var evolution_1_costs_container:HBoxContainer
@export var evolution_1_cost_1_icon:ResourceIcon
@export var evolution_1_cost_1_label:Label;
@export var evolution_1_cost_2_icon:ResourceIcon;
@export var evolution_1_cost_2_label:Label;

@export_group("Evolution 2")


@export var evolution_2_sprite:TextureButton;
@export var evolution_2_panel:Panel;
@export var evolution_2_highlight:ColorRect

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
	
	evolution_2_highlight.modulate.a = 0;
	evolution_1_highlight.modulate.a = 0;

	if evolution_1_highlight_tween and evolution_1_highlight_tween.is_running():
		evolution_1_highlight_tween.kill()
	if evolution_2_highlight_tween and evolution_2_highlight_tween.is_running():
		evolution_2_highlight_tween.kill()
			
	
	if "evolutions" in unit.base:
		show();
		var i:int = 1;
		can_evolve = unit.level >= 5;
		
		for evolution:String in unit.base.evolutions.keys():
			var button:TextureButton = self["evolution_"+str(i)+"_sprite"];
			
			var base:FighterBase = Index.fighters.find_base(evolution).duplicate();
			self["evolution_" + str(i) + "_base"] = base;
			evolution_texture_buffer.add_child(base);
			
			var base_texture:Texture = ColorCoder.color_code_fighter_base_texture(base, Entities.player.color_scheme_index)
			
			button.texture_normal.atlas = base_texture
			button.texture_hover.atlas = base_texture
			button.texture_disabled.atlas = base_texture
			
			var i2:int = 1;
			button.disabled = false;
			for resource:String in unit.base.evolutions[evolution].keys():
				self["evolution_" + str(i) + "_resource_" + str(i2)] = resource;
				
				var cost:int = unit.base.evolutions[evolution][resource];
				self["evolution_" + str(i) + "_cost_" + str(i2)] = cost
				
				var icon:ResourceIcon = self["evolution_" + str(i) + "_cost_" + str(i2) + '_icon']
				icon.resource = resource
				icon.setup()
			
				var label:Label = self["evolution_" + str(i) + "_cost_" + str(i2) + '_label']
				label.text = str(cost);
				
				if Entities.player.inventory[resource] < cost:
					self["enough_resources_for_ev" + str(i)] = false;
					button.disabled = true;
				i2 += 1;
		
			button.modulate = Color.WHITE;
			if button.disabled or not can_evolve:
				button.modulate = Color.from_hsv(1, 1, 0, .5)
		
			if not button.disabled and can_evolve:
				evolution_highlight_tween_loop(i);
	
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

			title_label.text = "Bring this unit to level 5 to unlock upgrades."
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




var evolution_1_highlight_tween:Tween
var evolution_2_highlight_tween:Tween
func evolution_highlight_tween_loop(target:int)->void:
	var highlight:ColorRect = self["evolution_" + str(target) + "_highlight"]
	 
	self["evolution_"+str(target)+"_highlight_tween"] = create_tween();
	var tween:Tween = self["evolution_"+str(target)+"_highlight_tween"];
	tween.tween_property(highlight, "modulate:a", 1,.5)
	tween.tween_property(highlight, "modulate:a", .1,.5)
	tween.tween_callback(evolution_highlight_tween_loop.bind(target))
	
	
	

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

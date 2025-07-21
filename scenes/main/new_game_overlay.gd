extends Control

@export var main_menu:Control;


@export_group("origins")
@export var brigand:Player;
@export var aristocrat:Player;
@export var indigent:Player;

@export_group("visual elements")
@export_subgroup("data")
@export var player_body:TextureRect;
@export var colors_outline:ReferenceRect;
@export var main_color_sample:ColorRect;
@export var off_color_sample:Polygon2D

@export var money_label:Label;

@export var name_edit:LineEdit;

@export var origin_name_label:Label;
@export var origin_description_label:RichTextLabel;

@export var origins_container:VBoxContainer;

@export var items_container:GridContainer

@export_subgroup("stat labels")
@export var max_hp_label:Label;
@export var attack_label:Label;
@export var defense_label:Label;
@export var agility_label:Label;
@export var technique_label:Label;

@export_subgroup("samples")
@export var weapon_sample:TextureRect;
@export var weapon_sample_bg:ColorRect;

@export var module_sample:TextureRect;
@export var module_sample_bg:ColorRect

@export var party_member_sample:TextureRect;
@export var party_units_container:VBoxContainer




const origin_descriptions = {
	"aristocrat":
	"You were born into wealth and know that money can get you anything, so long as you know how to spend it.
[color=green]Bonus Resources.
Start with two bodyguards.",
	
	"brigand":
	"You're the son of a brigand fighter, who was the son of a brigand fighter, who was the grandson of a brigand.
[color=green]High Initial Stats.
Start with a small warband.",
	
	"indigent":
"You woke up one day all alone in the middle of nowhere and remember nothing prior to that.
[color=red]You get (basically) nothing."
}

var scheme_player_textures:Array[Texture]

var origin_index:int = 0;
var current_color_scheme:int = 0;


@onready var origins_parties_textures:Dictionary = {
	## any given texture = origins_parties_textures[origin][current_index][unit]
	aristocrat:[],
	brigand:[],
	indigent:[]
}

func _ready()->void:
	for scheme:Array in Index.color_schemes:
		var texture:Texture = player_body.texture.atlas;
		var base_color:Color = scheme[0]
		var off_color:Color = scheme[1];
		
		var pairs:={
			Color.GREEN: base_color,
			Color.BLUE: base_color.darkened(.5),
			Color.YELLOW: off_color,
			Color.RED: off_color.darkened(.5)
		} 
		scheme_player_textures.append(ColorCoder.color_code_texture(texture, pairs));
		
		for origin:Player in [aristocrat, brigand, indigent]:
			var textures:Dictionary;
			for unit:FighterUnit in origin.roster.units:
				if not unit.base:
					var base:FighterBase =  unit.get_child(-1)
					unit.base = Index.all_fighter_bases[base.name]
					base.queue_free();
				textures[unit] = ColorCoder.color_code_texture(unit.base.texture, pairs);
			origins_parties_textures[origin].append(textures);
	refresh_origin_data()
	name_edit_blink_loop();
	
func name_edit_blink_loop()->void:
	var tween:Tween = create_tween();
	tween.tween_property(name_edit, "theme_override_colors/font_placeholder_color:a", .2, 1.15)
	tween.tween_property(name_edit, "theme_override_colors/font_placeholder_color:a", 1, 1.15)
	tween.tween_callback(name_edit_blink_loop)
	
func _on_previous_pressed() -> void:
	change_origin(-1)


func _on_next_pressed() -> void:
	change_origin(1)

func change_origin(move:int)->void:
	origin_index += move;
	if origin_index == 3:
		origin_index = 0;
	if origin_index == -1:
		origin_index = 2;
	
	refresh_origin_data()
	
func refresh_origin_data()->void:
	var origin_name:String = ["aristocrat", "brigand", "indigent"][origin_index];
	var origin:Player = self[origin_name];

	var target_container_y:int = origin_index * -500
	var tween: = create_tween();
	tween.tween_property(origins_container, "position:y", target_container_y, .25)
	
	var scheme:Array = Index.color_schemes[current_color_scheme];
	var base_color:Color = scheme[0]
	var off_color:Color = scheme[1];
	
	main_color_sample.color = base_color;
	colors_outline.border_color = base_color;
	off_color_sample.color = off_color;
	

	for c:Node in party_units_container.get_children():
		if c.visible:
			c.queue_free();
			
	
	for unit:FighterUnit in origin.roster.units:
		var rect:TextureRect = party_member_sample.duplicate()
		rect.texture = AtlasTexture.new();
		rect.texture.region = party_member_sample.texture.region;
		
		rect.texture.atlas =  origins_parties_textures[origin][current_color_scheme][unit]
		party_units_container.add_child(rect);
		rect.show()

		var tooltip:Tooltip = Index.tooltip_scene.instantiate();
		tooltip.target = unit.base;
		rect.add_child(tooltip)
		tooltip.setup();

	for c:Node in items_container.get_children():
		if c.visible:
			c.queue_free();
			
	money_label.text = str(origin.inventory.money)
	
	for item:Item in origin.inventory.items:
		if item != origin.equipped_module and\
		item != origin.equipped_weapon:
			var mirror:ItemMirror = Index.item_mirror_scene.instantiate();
			mirror.load_item(item, false, true);
			if item is ResourceContainer:
				mirror.stack_size_label.show();
				mirror.stack_size_label.text = str(item.stack_size)+"/"+str(item.capacity);
			items_container.add_child(mirror)
			mirror.set_anchors_preset(Control.PRESET_CENTER)
			var mirror_size: = Vector2(item.size_x * 32, item.size_y * 32)
			mirror.custom_minimum_size = mirror_size;
			mirror.size = mirror_size
	player_body.texture.atlas = scheme_player_textures[current_color_scheme]
	player_body.material.set_shader_parameter("color", off_color.darkened(.5))

	origin_name_label.text = origin.name;
	origin_description_label.text = origin_descriptions[origin_name];
	
	for stat:String in Index.all_combat_stats:
		self[stat+"_label"].text = str(origin.combat_stats[stat])
	
	var weapon:Weapon = origin.equipped_weapon;
	weapon_sample.texture = weapon.texture;
	
	var sample_size: = Vector2(weapon.size_x * 32, weapon.size_y * 32)
	weapon_sample.custom_minimum_size = sample_size
	weapon_sample.size = sample_size;
	weapon_sample.material.set_shader_parameter("base_color", off_color)
	
	weapon_sample_bg.color = base_color.lightened(.3)
	weapon_sample_bg.get_node("rect").border_color = base_color.darkened(.5)
	
	var weapon_tooltip:Tooltip = weapon_sample.get_node("Tooltip");
	weapon_tooltip.target = weapon;
	weapon_tooltip.setup();
	weapon_tooltip.hint.hide()
	
	module_sample.texture = origin.equipped_module.texture;
	module_sample.material.set_shader_parameter("base_color", off_color)

	module_sample_bg.color = base_color.lightened(.3)
	module_sample_bg.get_node("rect").border_color = base_color.darkened(.5)

	var module_tooltip:Tooltip = module_sample.get_node("Tooltip");
	module_tooltip.target = origin.equipped_module;
	module_tooltip.setup();
	module_tooltip.hint.hide()


func _on_previous_scheme_pressed() -> void:
	current_color_scheme -= 1;
	if current_color_scheme == -1:
		current_color_scheme = len(Index.color_schemes) - 1
	refresh_origin_data()

func _on_next_scheme_pressed() -> void:
	current_color_scheme += 1;
	if current_color_scheme == len(Index.color_schemes):
		current_color_scheme =  0
	refresh_origin_data()




func start_new_game() -> void:
	if len(name_edit.text) < 3:
		const interval = .15
		name_edit.grab_focus();
		var tween:Tween = create_tween();
		for i in 3:
			tween.tween_property(name_edit, "modulate", Color.RED, interval);
			tween.tween_property(name_edit, "modulate", Color.WHITE, interval)
	else:
		await Tweens.ui_fade_in(Entities.loading_screen).finished;
		get_parent().hide();
		
		var map:WorldMap = Index.world_map_scene.instantiate();
		Entities.world_map = map;
		map.finished_generating.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
		
		var origin_name:String = ["aristocrat", "brigand", "indigent"][origin_index];
		var origin:Player = self[origin_name];
		origin.name = name_edit.text
		origin.color_scheme_index = current_color_scheme;
		
		map.player_party.setup(origin)
		
		Entities.main.add_child.call_deferred(map);
		Entities.main.move_child.call_deferred(map, 0)
		get_parent().get_parent().queue_free()


func _on_return_pressed() -> void:
	if modulate.a == 1:
		Tweens.ui_fade_out(self);
		Tweens.ui_fade_in(main_menu)

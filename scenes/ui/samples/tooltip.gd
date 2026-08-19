extends PanelContainer

class_name Tooltip;

var target:Node;

enum TargetType{
	constant, 
	## default value bc it will fire an error if this has no hardcoded values
	single_load,
	fully_dynamic,
	manual ## calls refresh manually from source
	## right now only for the simple tooltips in location options 
	## where it's cleaner to set the hardcoded texts from there
	## rather than further bloating the tooltip script
}
@export var target_type:TargetType=TargetType.constant;

@export var name_label:Label;
@export var sub_name_label:Label;
@export var description_label:RichTextLabel;
@export var hint:Label;

@export var hover_timer:Timer;


@export_group("hardcode")
@export var hardcoded_name:String;
@export var hardcoded_sub_name:String;
@export var hardcoded_description:String;


func _ready() -> void:
	var parent:Node = get_parent();
	assert(parent is Control)
	target = parent;
	setup_target()
	
	enable();
	
func setup_target()->void:
	if target is Icon and target.floating:
		queue_free();
		return

	
	if target_type == TargetType.fully_dynamic:
		target.mouse_entered.connect(refresh)
	elif target_type != TargetType.manual:
		refresh();
		
	target.mouse_entered.connect(hover_timer.start);
	target.mouse_exited.connect(stop_hover_timer);
func disable()->void:
	if len(hover_timer.timeout.get_connections()):
		hover_timer.timeout.disconnect(_on_hover_timer_timeout)
	
func enable()->void:
	if not len(hover_timer.timeout.get_connections()):
		hover_timer.timeout.connect(_on_hover_timer_timeout)


func _on_hover_timer_timeout() -> void:
	Tweens.ui_fade_in(self);
	var window_size:Vector2 = get_window().size;
	
	var target_position:Vector2 = get_global_mouse_position();
	global_position = target_position
	
	if target_position.x + size.x >= window_size.x - 50:
		position.x -= size.x
	if target_position.y + size.y >= window_size.y -10:
		position.y -= size.y
		
func stop_hover_timer()->void:
	if not hover_timer.is_stopped():
		hover_timer.stop();
	hide();

func refresh()->void:
	match target_type:
		TargetType.constant, TargetType.manual:
			assert(hardcoded_name or hardcoded_description);
			if hardcoded_name:
				name_label.text = hardcoded_name;
			if hardcoded_description:
				description_label.text = hardcoded_description
		TargetType.single_load:
			single_load_target()
			
		TargetType.fully_dynamic:
			dynamic_load_target()


func single_load_target()->void:
	## LIST ALL CLASS THAT USE THIS
	if target is ResourceIcon:
		load_resource_icon()
	elif target is StatIcon:
		load_stat_icon();

func load_resource_icon()->void:
	var icon:ResourceIcon = target;
	
	name_label.text = icon.resource.capitalize();
	name_label.add_theme_color_override("font_color", Resources.resource_colors[icon.resource]);
	description_label.text = Resources.resource_descriptions[icon.resource];

func load_stat_icon()->void:
	var icon:StatIcon = target;
	var stat_name:String = icon.stat.capitalize();
	if stat_name == "Max Hp":
		stat_name = "Max HP"
	name_label.text = stat_name;
	
	name_label.add_theme_color_override("font_color", CombatStats.stat_colors[icon.stat]);
	description_label.text = CombatStats.stat_descriptions[target.stat];
func dynamic_load_target()->void:
	## LIST ALL CLASS THAT USE THIS
	## ItemSample
	## ItemMirror
	if target is CombatMechanicIcon:
		load_combat_mechanic_icon()
	if target is ItemMirror:
		## item mirrors and displays will call the item_setup on their own
		item_mirror_setup();
	elif target is ItemSample and target.item:
		item_sample_setup()


func load_combat_mechanic_icon()->void:
	@warning_ignore("confusable_local_usage", "shadowed_variable")
	var icon:CombatMechanicIcon = target
	var mechanic:CombatMechanicIcon.Mechanics = icon.mechanic;
	match mechanic:
		CombatMechanicIcon.Mechanics.damage:
			name_label.text = "Damage"
		CombatMechanicIcon.Mechanics.range:
			name_label.text = "Range"
		CombatMechanicIcon.Mechanics.stun:
			name_label.text = "Stun Duration"
		CombatMechanicIcon.Mechanics.knockback:
			name_label.text = "Knockback Distance"
		CombatMechanicIcon.Mechanics.stat_up:
			name_label.text = target.stat.capitalize() + " buff"
		CombatMechanicIcon.Mechanics.stat_down:
			name_label.text = target.stat.capitalize() + " debuff"
		CombatMechanicIcon.Mechanics.cooldown:
			name_label.text = "Cooldown"



func item_sample_setup()->void:
	item_setup();
	var player:Player = Entities.player
	var item:Item = target.item;
	match item:
		## tooltip just hides if the sample is blank
		player.equipped_weapon:
			hint.show()
			hint.text = "[right-click] to unequip";
		player.alternative_weapon:
			hint.show()
			hint.text = "[right-click] to unequip";
		player.equipped_accessory_1, Entities.player.equipped_accessory_2:
			hint.show()
			hint.text = "[right-click] to unequip";
	
	if item.unique_name in Entities.player.equipped_artifices_names.values():
		hint.show();
		hint.text = "[right-click] to unequip or change slots"
		## idk why when this line is there the script gets a bug at the bottom line?

func item_mirror_setup()->void:
	var mirror:ItemMirror = target;
	item_setup();
	hint.show()
	var item:Item = target.item;
	match mirror.display.context:
		"player_sheet":
			if item is ResourceContainer:
				if not item.raw_stack:
					hint.text = "[right-click] to empty";
				else:
					hint.text = "[right-click] to store";
			elif item is Equipment:
				hint.text = "[right-click] to equip";
			elif item is Consumable:
				hint.text = "[right-click] to use"
		"trade":
			if mirror.being_traded:
				hint.text = "[right-click] to return"
			elif mirror.display.inventory.holder == Entities.player:
				hint.text = "[right-click] to sell";
			else:
				hint.text = "[right-click] to buy";
		"loot":
			if mirror.display.inventory.holder == Entities.player:
				hint.text = "[right-click] to deposit";
			else:
				hint.text = "[right-click] to loot";
		"refinement":
			if mirror.item is Equipment:
				hint.text = "[right-click] to refine";
			else:
				hint.text = "can't be refine"
	


func item_setup()->void:
	var item:Item = target.item;
	name_label.add_theme_color_override("font_color", Index.get_color(item.color_tag))
	var target_name:String = item.unique_name;
	if item is Weapon and item.refinement_level:
		target_name = "+"+str(item.refinement_level)+" "+target_name
		self_modulate = Index.refinement_level_colors[item.refinement_level - 1].blend(Color.WHITE/2)
	
	description_label.text = "";
	if item is Weapon or item is Module:
		var cd:String = str(snapped(item.final_cooldown(), .01))
		description_label.text += "Cooldown: " + cd+"\n"
	

	name_label.text = target_name;\
	
	if item is Weapon:
		sub_name_label.text = "Weapon";

		var not_active:="[color="+ Color(0.4, 0.4, 0.4, 1.0).to_html()+"]"
		var active:="[color="+ Color(0.672, 0.7, 0.28, 1.0).to_html()+"]"

		description_label.text += "[font_size=32]"
		for i:int in range(1, 4):
			var color_tag:String = active if item.refinement_level >= i else not_active;
			var refinement_string:String = color_tag +  item["r"+str(i)+"_improvement"]+"[/color]\n"
			description_label.text += refinement_string
		
		description_label.text += "[/font_size]"
	elif item is ResourceContainer:
		if item.raw_stack:
			sub_name_label.text = "Resource";
		else:
			sub_name_label.text = "Container";
	elif item is Module:
		sub_name_label.text = "Module";
	elif item is Accessory:
		sub_name_label.text = "Accessory";
	elif item is Consumable:
		sub_name_label.text = "Consumable"
	elif item is Artifice:
		sub_name_label.text = "Artifice";
	elif item is CarKey:
		sub_name_label.text = "Vehicle"
		description_label.text += "[color=green]+"+str(item.cargo_space) + " cargo space\n";
		description_label.text += "+"+str(item.party_space) + " party capacity[/color]\n";
		description_label.text += Index.get_color_tag("fuel")+"+"+str(item.fuel_cost)+" travel fuel cost[/color]\n"
	sub_name_label.show()
	## do the just method for everything that gets colors from index?
	## some other way that's gonna make me feel stupid once i find out about how do modularize this stuff?
	description_label.text += item.get_description();
	

extends PanelContainer

class_name Tooltip;

var target:Node;

@export var name_label:Label;
@export var sub_name_label:Label;
@export var description_label:RichTextLabel;
@export var icon:TextureRect;
@export var hint:Label;

@export var hover_timer:Timer;


@export_group("hardcode")
@export var hardcoded_name:String;
@export var hardcoded_sub_name:String;
@export var hardcoded_description:String;

func _ready() -> void:
	var parent:Node = get_parent();
	assert(parent is Control)
	parent.mouse_entered.connect(hover_timer.start);
	parent.mouse_exited.connect(stop_hover_timer);
	enable();
	if parent is Icon:
		load_target(parent)
		
	if hardcoded_name:
		name_label.text = hardcoded_name;
	if hardcoded_sub_name:
		sub_name_label.show()
		sub_name_label.text = hardcoded_sub_name
	if hardcoded_description:
		description_label.show();
		description_label.text = hardcoded_description
	



func load_target(new_target:Node)->void:
	target = new_target;

	if target is ItemMirror:
		## item mirrors and displays will call the item_setup on their own
		item_mirror_setup(target);
	elif target is ItemSample:
		item_sample_setup(target)

	elif target is ResourceIcon:
		if target.show_tooltip:
			name_label.text = target.resource.capitalize();
			name_label.add_theme_color_override("font_color", Index.resource_colors[target.resource]);
			description_label.text = Index.resource_descriptions[target.resource];
	
	elif target is StatIcon:
		var stat_name:String = target.stat.capitalize();
		if stat_name == "Max Hp":
			stat_name = "Max HP"
		name_label.text = stat_name;
		
		name_label.add_theme_color_override("font_color", Index.stat_colors[target.stat]);
		description_label.text = Index.stat_descriptions[target.stat];
	elif target is DisciplineIcon:
		var discipline:String = target.discipline;
		name_label.text = discipline.capitalize();
		description_label.text = Index.discipline_descriptions[discipline]


		

func item_sample_setup(sample:ItemSample)->void:
	var item:Item = sample.item;
	item_setup(item);
	match item:
		## tooltip just hides if the sample is blank
		Entities.player.equipped_weapon:
			hint.show()
			hint.text = "[right-click] to unequip";
		Entities.player.alternative_weapon:
			hint.show()
			hint.text = "[right-click] to unequip";
		Entities.player.equipped_accessory_1, Entities.player.equipped_accessory_2:
			hint.show()
			hint.text = "[right-click] to unequip";



func item_mirror_setup(mirror:ItemMirror)->void:
	var item:Item = mirror.item;
	item_setup(item);
	hint.show()
	match mirror.display.context:
		"player_sheet":
			if item is ResourceContainer:
				if not item.raw_stack:
					hint.text = "[right-click] to empty";
				else:
					hint.text = "[right-click] to store";
			if item is Weapon or item is Module or item is Accessory:
				hint.text = "[right-click] to equip";
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
	


func item_setup(item:Item)->void:
	var target_name:String = item.name;
	while target_name[-1].is_valid_int():
		target_name = target_name.left(-1);
	name_label.text = target_name;
	
	if item is Weapon:
		sub_name_label.text = "Weapon";
	elif item is ResourceContainer:
		if item.raw_stack:
			sub_name_label.text = "Resource";
		else:
			sub_name_label.text = "Container";
	elif item is Module:
		sub_name_label.text = "Module";
	elif item is Accessory:
		sub_name_label.text = "Accessory";
	sub_name_label.show()
	## do the just method for everything that gets colors from index?
	## some other way that's gonna make me feel stupid once i find out about how do modularize this stuff?
	description_label.text = item.get_description()

func disable()->void:
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

extends Control

@export var all_recruits:Roster;
@export var sheet:VBoxContainer

@export var new_recruit_container:HBoxContainer;

@export var new_recruit_sprite_container:PanelContainer;
@export var new_recruit_name:Label;
@export var new_recruit_tags:Label
@export var new_recruit_skill:RichTextLabel;
@export var new_recruit_level:Label;
@export var new_recruit_max_hp:Label;
@export var new_recruit_attack:Label;
@export var new_recruit_defense:Label;
@export var new_recruit_agility:Label;
@export var new_recruit_technique:Label;


func _ready()->void:
	for recruit:FighterUnit in all_recruits.units:
		new_recruit_name.text = recruit.base.name;
		

		new_recruit_tags.text = "";
		for tag:String in recruit.base.tags:
			new_recruit_tags.text += tag + "\n"
		
		new_recruit_skill.text = "Cooldown: " + str(snapped(recruit.final_skill_cooldown(), .01)) + "s\n"
		new_recruit_skill.text += recruit.base.full_skill_description(recruit)
		
		new_recruit_level.text = str(recruit.level);
		new_recruit_max_hp.text = str(recruit.stats.max_hp);
		new_recruit_attack.text = str(recruit.stats.attack)
		new_recruit_defense.text = str(recruit.stats.defense)
		new_recruit_agility.text = str(recruit.stats.agility);
		new_recruit_technique.text = str(recruit.stats.technique);
		
		var container:HBoxContainer = new_recruit_container.duplicate();
		container.show();
		sheet.add_child(container)
		
		var base_sprite:FighterBase = recruit.base.duplicate(DUPLICATE_USE_INSTANTIATION)
		base_sprite.centered = false;
		base_sprite.position -= Vector2(16, 16)
		base_sprite.z_index += 2
		container.get_node("sprite/sprite_panel").add_child(base_sprite)
	
	new_recruit_container.queue_free()

		
		
func _input(e:InputEvent)->void:
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			sheet.position.y -= 50
		elif e.button_index == MOUSE_BUTTON_WHEEL_UP:
			sheet.position.y += 50;

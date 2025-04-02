extends Control

@export var all_recruits:Roster;
@export var sheet:VBoxContainer

@export var new_recruit_container:HBoxContainer;

@export var new_recruit_sprite:TextureRect;
@export var new_recruit_name:Label;
@export var new_recruit_level:Label;
@export var new_recruit_max_hp:Label;
@export var new_recruit_attack:Label;
@export var new_recruit_defense:Label;
@export var new_recruit_agility:Label;
@export var new_recruit_technique:Label;


func _ready():
	for recruit:FighterUnit in all_recruits.units:
		new_recruit_name.text = recruit.base.name;
		
		new_recruit_sprite.texture.atlas = recruit.base.texture;
		
		new_recruit_level.text = str(recruit.level);
		new_recruit_max_hp.text = str(recruit.stats.max_hp);
		new_recruit_attack.text = str(recruit.stats.attack)
		new_recruit_defense.text = str(recruit.stats.defense)
		new_recruit_agility.text = str(recruit.stats.agility);
		new_recruit_technique.text = str(recruit.stats.technique);
		
		var container = new_recruit_container.duplicate();
		container.show();
		sheet.add_child(container)
		
func _input(e:InputEvent):
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			sheet.position.y -= 50
		elif e.button_index == MOUSE_BUTTON_WHEEL_UP:
			sheet.position.y += 50;

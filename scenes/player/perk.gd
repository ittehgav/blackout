extends Node

class_name Perk;

signal animation_finished;

## NEED TO ENTER TREE BEFORE BEING TURNED INTO BUTTON
@export var icon:Texture;
@export var description:String;

@export var title_color:Color

@export var panel:Control;
@export var sfx:AudioStreamPlayer;


func animation_callback(_display:Control)->void:
	## what plays when you choos the perk
	printerr("PERKANIMATIONMISSING ", name)

func apply()->void:
	## de-facto change caused by choosing the perk
	printerr("APPLYMISSING ", name);

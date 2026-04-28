extends Control

@export var warning_label:RichTextLabel;

signal response

var accepted:bool;

func _ready()->void:
	warning_label.text = "If you run out of " + Index.resource_colored_name("food")\
	+" while travelling, your party's [color=green]Morale[/color] will drop.\n\n"\
	+ "If your party runs out of " + Index.resource_colored_name("fuel") + \
	" while travelling, your [color=green]navigation speed[/color] will drop drastically!";


func _on_cancel_btn_pressed() -> void:
	accepted = false;
	Tweens.ui_fade_out(self);
	response.emit()


func _on_go_btn_pressed() -> void:
	accepted = true;
	Tweens.ui_fade_out(self);
	response.emit()

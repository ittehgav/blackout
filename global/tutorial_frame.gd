extends Control

class_name TutorialFrame;

signal clear_finished

@export var check:Tutorial.TutorialChecks;

@export var activation_source:Node;
@export var activation_signal_key:String="clear_finished";

@export var deactivation_source:Node;
@export var deactiveation_signal_key:String;

func _ready()->void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	activation_source[activation_signal_key].connect(show_tutorial);
	deactivation_source[deactiveation_signal_key].connect(clear_tutorial);
	
func show_tutorial()->void:
	if not Tutorial.checks[check]:
		Tweens.ui_fade_in(self);
		Tutorial.checks[check] = true;

func clear_tutorial()->void:
	if visible:
		Tweens.ui_fade_out(self);
		await get_tree().create_timer(2).timeout
		clear_finished.emit()

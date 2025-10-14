extends PanelContainer

var target_unit:FighterUnit

var initial_base:FighterBase;
var evolved_base:FighterBase

@export var menu:EvolutionMenu;

@export var confirmation_message:RichTextLabel

@export var before_container:Control
@export var after_container:Control;

@export var evolution_animation_container:ColorRect;
@export var evolution_sound:AudioStreamPlayer

@export var after_evolution_message:Control

var animation_finished:bool=false;

func show_confirmation()->void:
	before_container.get_child(0).queue_free()
	after_container.get_child(0).queue_free()
	
	var initial_sample:FighterBase = initial_base.duplicate();
	initial_sample.scale = Vector2(3, 3);
	before_container.add_child(initial_sample);
	initial_sample.position = before_container.size/2;
	
	var evolved_sample:FighterBase = evolved_base.duplicate();
	evolved_sample.scale = Vector2(3, 3);
	after_container.add_child(evolved_sample);
	evolved_sample.position = after_container.size/2;
	
	confirmation_message.modulate = Index.primary_tag_colors[initial_base.tags[0]];
	confirmation_message.text = "Evolve your " + initial_base.name + " into " + evolved_base.name+"?"

	
	Tweens.ui_fade_in(self)

func _input(e:InputEvent)->void:
	if  animation_finished and (e is InputEventKey or e is InputEventMouseButton) and e.is_pressed():
		menu.close()
		

func evolution_animation()->void:
	evolution_animation_container.show()
	target_unit.base = evolved_base;
	
	var initial_sample:FighterBase = initial_base.duplicate()
	initial_sample.scale = Vector2(6, 6)

	var evolved_sample:FighterBase = evolved_base.duplicate()
	evolved_sample.scale = Vector2(6, 6)
	evolved_sample.hide()
	
	evolution_animation_container.add_child(initial_sample)
	evolution_animation_container.add_child(evolved_sample)
	
	var screen_size:Vector2 = get_window().size;
	initial_sample.position = screen_size/2
	evolved_sample.position = screen_size/2;
	
	var tween:Tween = create_tween();
	tween.tween_interval(.75)
	tween.tween_callback(evolution_sound.play);
	tween.tween_property(initial_sample, "scale", initial_sample.scale * 1.25, .2);
	tween.tween_callback(initial_sample.hide)
	tween.tween_callback(evolved_sample.show)
	tween.tween_callback(after_animation)
	

func after_animation()->void:
	after_evolution_message.show()
	animation_finished = true
	
	
	
	
 	

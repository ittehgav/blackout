extends Control
class_name ItemModifierIcon;

@export var arrow_1:TextureRect
@export var arrow_2:TextureRect
@export var arrow_3:TextureRect
@onready var all_arrows:Array[TextureRect] = [arrow_1, arrow_2, arrow_3]

@export var animation:AnimationPlayer;

var current_tier:int;

func refresh(item:Item)->void:
	for a:TextureRect in all_arrows:
		a.hide()
	var m:ShaderMaterial = material;
	show()
	m.set_shader_parameter("width", 0);
	animation.stop();
	var tier:int;
	
	var animated:bool=false;
	if current_tier != -1 and current_tier != tier:
		animated = true
	if not item.applied_modifier:
		tier = 0;
	else:
		tier = item.applied_modifier.tier
	match tier:
		0:
			## 0 = no mod
			hide()
		1:
			arrow_1.show();
		2:
			arrow_1.show();
			arrow_2.show();
			m.set_shader_parameter("width", 1)
			if animated:
				scale_tween(2);
		3:
			arrow_1.show();
			arrow_2.show();
			arrow_3.show();
			m.set_shader_parameter("width", 2)
			animation.play("t3_glow");
			if animated:
				scale_tween(2);
	

func scale_tween(t:int)->void:
	scale = Vector2(t, t);
	var tween:Tween = create_tween();
	tween.tween_property(self, "scale", Vector2.ONE, t);

extends Node2D

@export var holder:CharacterBody2D;
@export var tool_cd:Timer;
@export var tool_node:Sprite2D;
@export var body:Sprite2D;

func _ready()->void:
	equip_tool()

func _input(e:InputEvent)->void:
	if e.is_action_pressed("use_tool") and holder.stun_timer.is_stopped():
		tool_input();

func _process(_delta:float)->void:
	const angle_adjust = 30;
	look_at(get_global_mouse_position())
	if body.flip_h:
		rotation_degrees += 180 - angle_adjust;
		scale.x = -1;
	else:
		rotation_degrees += angle_adjust;
		scale.x = 1
		

func tool_input()->void:
	if tool_cd.is_stopped():
		use_tool()
		

func use_tool():
	tool_cd.start()
	tool_node.use();

func equip_tool()->void:
	## for now just auto equips the exported one but it's where it'll do so at the start of battle and
	## where it'll swap them mid-fight
	tool_cd.wait_time = tool_node.cooldown;
	ColorCoder.color_code_tool(tool_node)
	tool_node.holder = holder;
	holder.attack = tool_node.damage;
	

func tool_use_held() -> void:
	if Input.is_action_pressed("use_tool"):
		use_tool();

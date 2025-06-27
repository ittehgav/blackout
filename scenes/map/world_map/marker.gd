extends Sprite2D

@export var projection:Control;

@export var camera:Camera2D;
@export var sfx:AudioStreamPlayer;

@onready var origin:Node2D = get_parent();

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("place_marker") and not Entities.world_map.pause_stack:
		if not visible:
			show_in_position(get_global_mouse_position());
		else:
			sfx.play_sound_by_key("marker_removed")
			projection.hide();
			hide();

	if visible:
		projection.rotation = Entities.player_map_party.global_position.angle_to_point(global_position)
		
func clear()->void:
	hide();
	projection.hide()
	
func show_in_position(target:Vector2)->void:
	reparent(origin)
	sfx.play_sound_by_key("marker_placed")
	global_position = target;
	projection.show()
	show();


func mark_settlement(settlement:Settlement)->void:
	sfx.play_sound_by_key("marker_placed")
	reparent(settlement, false);
	position = Vector2.ZERO;
	projection.show()
	show();
	
	var tree:SceneTree = get_tree();
	const interval = .35
	await tree.create_timer(1).timeout;
	modulate.a = 0;
	projection.modulate.a = 0
	await tree.create_timer(interval).timeout;
	modulate.a = 1;
	projection.modulate.a = 1
	await tree.create_timer(interval).timeout;
	modulate.a = 0;
	projection.modulate.a = 0
	await tree.create_timer(interval).timeout;
	modulate.a = 1;
	projection.modulate.a = 1

extends Panel

@export var item_icon_scene:PackedScene;

@export var bg:ColorRect;
@export var item_message:Label;

var current_icon:ItemIcon;

func use_animation(item:Item):
	## PLAY SOME DOPAMINEY SOUND
	var icon:ItemIcon = item_icon_scene.instantiate();
	icon.tooltip.queue_free();
	icon.get_node("panel").hide()
	icon.item = item;
	icon.position = Vector2(200, 150);
	icon.custom_minimum_size = Vector2(160, 160)
	add_child(icon);
	current_icon = icon;
	if not icon.is_node_ready():
		await icon.ready;
	bg.show();
	item_message.text = item.use_message;
	
	var tween = create_tween();
	tween.set_trans(Tween.TRANS_BOUNCE);
	tween.tween_property(icon, "scale", Vector2(1.25, 1.25), .3)
	tween.tween_interval(1);
	await tween.finished
	item_message.show()
	
func _input(e:InputEvent):
	if (e is InputEventKey or e is InputEventMouseButton) and e.pressed and item_message.visible:
		current_icon.queue_free()
		item_message.hide();
		bg.hide();
	

extends Perk

@export var space_label:Label;
var player_inv_space:int;
@onready var player:Player = get_tree().get_first_node_in_group("player")

func _ready()->void:
	if not (get_parent() is Control):
		return
	## space gain hardcoded as 12 bc that's how much its gonna be for
	## the forseeable future
	var inv:Inventory = player.inventory;
	player_inv_space = inv.capacity_x * inv.capacity_y
	space_label.text = str(inv.taken_space()) + "/" + str(player_inv_space)



func set_label_text(target:int)->void:
	space_label.text = str(player_inv_space) +"/"+ str(target)


func animation_callback(display:Control)->void:
	panel.reparent(display)
	panel.show()
	## TODO shows the player's inventory (with items and all)
	## fades in the new slots
	## slide in the whole player sheet?
	await get_tree() .create_timer(.5).timeout
	sfx.play()
	var inv:Inventory = player.inventory;
	var current:int = inv.capacity_x * inv.capacity_y;
	var target:int = (inv.capacity_x+1) * inv.capacity_y;
	var tween:Tween = create_tween();
	tween.tween_method(set_label_text, current, target, 1);
	await tween.finished;
	animation_finished.emit()

func apply()->void:
	## for now just give it one col but maybe eventually start with a smaller y size?
	player.inventory.capacity_x += 1;

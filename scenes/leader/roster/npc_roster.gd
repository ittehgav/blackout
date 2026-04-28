extends Roster

class_name NpcRoster;

@export var loot:LootInventory

func _ready()->void:
	loot.generate_loot(get_level());

func _on_child_entered_tree(node: Node) -> void:
	## so editor-made roster work and are easy to edit
	if node is LootInventory:return
	assert(node is FighterUnit)
	if not units.has(node):
		add_unit(node)
		remove_child.call_deferred(node);


func get_danger_level()->int:
	var player:Player = get_tree().get_first_node_in_group("player")
	var frac:float = get_level()/player.get_party_level()
	if frac <= .5:
		return 1;
	elif frac < .75:
		return 2;
	elif frac <= 2:
		return 3;
	else:
		return 4
	

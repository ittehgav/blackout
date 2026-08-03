extends Roster
class_name RecruitmentRoster
## roster with exported options for unit recruiting customization

## level range do how?
@export_group("Available Tags")
## TODO make this more dynamic somehow?
var base_pool:Array[FighterBase]


func refresh_recruits()->void:
	units.clear();
	for i in 4:
		var player:Player = Entities.player;
	
		var unit:FighterUnit = Index.scenes.fighter_unit.instantiate()
		unit.level = randi_range(max(1, player.level - 3), player.level * 2)
		unit.base = base_pool.pick_random();
		unit.update_stats();
		units.append(unit);

func _on_child_entered_tree(node: Node) -> void:
	assert(node is FighterBase);
	base_pool.append(Index.fighters.all_unit_bases[node.name]);
	remove_child.call_deferred(node)

extends RichTextLabel

class_name MemoLabel
var memo:Memo;

func setup(target:Memo)->void:
	memo = target;
	text = memo.gossip;

func _on_meta_clicked(key: Variant) -> void:
	var settlement:Settlement = Entities.world_map.all_settlements[key]
	var camera:Camera2D = Entities.in_map_player.camera;
	camera.pan_to_target(settlement, true)

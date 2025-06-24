extends RichTextLabel

class_name MemoLabel
var memo:Memo;

func setup(target:Memo)->void:
	memo = target;
	text = memo.gossip;

func _on_meta_clicked(key: Variant) -> void:
	if Entities.current_settlement:
		Entities.world_map.ui.settlement_ui.exit_settlement();
	else:
		Entities.player_sheet.hide_player_sheet();
	var settlement:Settlement = Entities.world_map.all_settlements[key]
	Entities.world_map.ui.marker.mark_settlement(settlement)

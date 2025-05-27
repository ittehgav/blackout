extends Control

@export var memos_container:VBoxContainer
@export var memo_item:HBoxContainer;


func refresh_data()->void:
	for memo:Memo in Entities.player.memos:
		if memo.register:
			if memo.expired:
				memo.register.modulate.a = .5;
				memo.register.mouse_filter = Control.MOUSE_FILTER_IGNORE;
		else:
			var item:HBoxContainer = memo_item.duplicate();
			item.setup(memo);
			memos_container.add_child(item)
			item.memo_label.meta_clicked.connect(Entities.player_sheet.hide_player_sheet);

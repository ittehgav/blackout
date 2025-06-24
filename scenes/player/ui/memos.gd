extends Control

@export var memos_container:VBoxContainer
@export var memo_item:HBoxContainer;


func refresh_data()->void:
	for memo:Memo in Entities.player.memos:
		if memo.register:
			if memo.expired:
				memo.queue_free()
		else:
			var item:HBoxContainer = memo_item.duplicate();
			item.setup(memo);
			memos_container.add_child(item)

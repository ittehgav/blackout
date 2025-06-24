extends HBoxContainer


@export var memo_label_scene:PackedScene;

func setup(memo:Memo)->void:
	while get_child_count():
		remove_child(get_child(0));
	
	var memo_label:MemoLabel = memo_label_scene.instantiate();
	var icon:TextureRect = TextureRect.new();
	icon.custom_minimum_size = Vector2(16, 16)
	
	memo.register = self;
	var target_color:Color
	if memo is TradeAnomaly:
		target_color = Index.resource_colors[memo.resource]
	else:
		target_color = Color.DARK_GOLDENROD;

	memo_label.modulate = target_color;
	icon.modulate = target_color;
	
	memo_label.text = memo.gossip;
	add_child(icon);
	add_child(memo_label);
	show();

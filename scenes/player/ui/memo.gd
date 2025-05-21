extends HBoxContainer

@export var icon:TextureRect;
@export var memo_label:MemoLabel;

func setup(memo:Memo)->void:
	memo.register = self;
	var target_color:Color
	if memo is TradeAnomaly:
		target_color = Index.resource_colors[memo.resource]
	else:
		target_color = Color.DARK_GOLDENROD;

	modulate = target_color;
	icon.material.set_shader_parameter("base_color", target_color);
	
	memo_label.text = memo.gossip;
	show();

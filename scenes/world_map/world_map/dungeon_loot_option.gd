extends PanelContainer

@export var sample:ItemSample
@export var name_label:Label;
@export var item_type_label:Label;
@export var choose_btn:Button;

var item:Item;

func load_item(target:Item)->void:
	item = target;
	sample.load_item(item, 3)
	name_label.text = target.name;
	item_type_label.text = item.type.capitalize()
	show()

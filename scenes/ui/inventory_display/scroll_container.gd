extends ScrollContainer

@onready var bar:HScrollBar = get_h_scroll_bar()

@export var excess_left:TextureRect;
@export var excess_right:TextureRect

func _ready()->void:
	bar.scrolling.connect(check_cropped_sides);

func check_cropped_sides()->void:
	excess_left.hide();
	excess_right.hide()
	if bar.value > 0:
		excess_left.show();
	elif bar.value < 94:
		excess_right.show()

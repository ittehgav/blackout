extends MapEntity;

class_name Settlement;

@export var background:Texture;
@export var settings:SettlementSettings;

@export var inventory:Inventory;

func _ready():
	ColorCoder.color_code_settlement(self)

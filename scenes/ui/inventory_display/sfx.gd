extends SfxPlayer;

@export var item_sfx:AudioStreamPlayer

@export var drop:AudioStream;
@export var pick_up:AudioStream;


@export var money_change:AudioStream

@export var trade:AudioStream;
@export var invalid:AudioStream;

@export var reset:AudioStream;
@export var coin_drop:AudioStream;

@export var loot:AudioStream;
@export var item_target:AudioStream;


@export_group("resource drops")
@export var deposit_food_small:AudioStream;
@export var deposit_food_big:AudioStream;

@export var deposit_liquid_small:AudioStream;
@export var deposit_liquid_big:AudioStream;

@export var deposit_scrap_small:AudioStream;
@export var deposit_scrap_big:AudioStream;

@export var deposit_chips:AudioStream;

func play_item_sfx(key:String)->void:
	item_sfx.stream = self[key];
	item_sfx.play()

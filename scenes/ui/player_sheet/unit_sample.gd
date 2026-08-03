extends Button

class_name UnitSample;

@export var accessory_sample:ItemSample;
@export var sprite:Sprite2D;

@export var hover_sfxes:Array[AudioStream]
@export var hover_sfx_player:AudioStreamPlayer;

func load_base(base:FighterBase, level:int, callback:Callable = Callable())->void:
	## for samples of evolved bases in evolution menu
	$level.text = "Lv." + str(level);
	sprite.texture = base.texture;
	
	if callback.is_valid():
		pressed.connect(callback)


func load_unit(unit:FighterUnit, callback:Callable=Callable())->void:
	$level.text = "Lv. " + str(unit.level);
	sprite.texture = unit.base.texture;
	
	
	if unit.equipped_accessory:
		accessory_sample.load_item(unit.equipped_accessory,  1);
	else:
		accessory_sample.load_blank(1);
	if callback.is_valid():
		pressed.connect(callback);
	
	
func load_player(callback:Callable=Callable())->void:
	sprite.texture = Index.textures.player_body_texture;
	sprite.vframes = Index.textures.player_body_frames.y;
	
	accessory_sample.queue_free()
	
	if callback.is_valid():
		pressed.connect(callback)


func _on_mouse_entered() -> void:
	Tweens.mouseover_shake(self, PI/32, .05)
	hover_sfx_player.stream = hover_sfxes.pick_random();
	hover_sfx_player.play()

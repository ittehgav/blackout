extends ColorRect

@export var recruit_view:Control;

@export var sprite:TextureRect;
@export var mask:ColorRect
@export var label:Label
@export var hint:Label;

func _ready()->void:
	set_process_input(false);

func play_animation(old_base:FighterBase, new_base:FighterBase)->void:
	show();
	Tweens.ui_fade_in(self, .1)
	
	mask.show();
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW;
	const x_shift = 50;
	sprite.texture.atlas = old_base.texture;
	
	sprite.pivot_offset.x += x_shift
	
	var pairs:Dictionary = ColorCoder.scheme_to_sprite_color_pairs(Entities.player)
	var new_texture:Texture = ColorCoder.color_code_texture(new_base.texture, pairs)
	var tween:Tween = create_tween();
	tween.tween_property(sprite, "pivot_offset:x", 90, 1.5);
	tween.parallel().tween_property(sprite, "scale", Vector2(5, 5), 1);
	tween.tween_callback(clear_mask.bind(new_texture))
	tween.tween_property(sprite, "scale", Vector2(4, 4), .25)
	tween.tween_callback(after_animation)
	tween.tween_callback(set_process_input.bind(true));

func after_animation()->void:
	Entities.player.inventory.refresh_resource_counts();
	recruit_view.unit_upgraded.emit()
	label.show()
	hint.show();
	set_process_input(true);

func clear_mask(new_texture:Texture)->void:
	Entities.player_sheet.sfx.play_sound_by_key("unit_upgrade")
	sprite.texture.atlas = new_texture;
	mask.hide();
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED

func _input(e:InputEvent)->void:
	if (e is InputEventKey or e is InputEventMouseButton )and e.pressed:
		recruit_view.fade_out();
		hide();
		set_process_input(false)
		

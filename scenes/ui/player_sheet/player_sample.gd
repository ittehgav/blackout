extends Control

@export var player_body:Sprite2D;


@export var body_animation_player:AnimationPlayer;

@export var equipment_anchor:Node2D;
var current_weapon:Weapon;

func load_weapon(target:Weapon)->void:
	if current_weapon:
		current_weapon.queue_free();

	current_weapon = target.duplicate(DUPLICATE_USE_INSTANTIATION);

	equipment_anchor.add_child(current_weapon);
	var attack_key:String = current_weapon.get_animation_key("attack")
	var player:AnimationPlayer = current_weapon.animation_player;
	var attack_animation:Animation = player.get_animation(attack_key);
	for c:Node in current_weapon.get_children():
		## easier to sterilize them here and not have to change anything in every single weapon?
		if c is CanvasItem:
			c.hide()
		if c is AudioStreamPlayer:
			c.volume_db = -80

	equipment_anchor.scale = Vector2.ONE * current_weapon.display.visual_scale/2;
	equipment_anchor.position = current_weapon.display.equipment_offset/2
	equipment_anchor.modulate = Index.get_color(current_weapon.color_tag)
	
	var anim:Animation = attack_animation.duplicate(true);

	for i in range(anim.get_track_count() -1, -1, -1):
		if anim.track_get_type(i) in [Animation.TYPE_METHOD, Animation.TYPE_AUDIO]:
			anim.remove_track(i);
	player.get_animation_library(current_weapon.animation_root_key)\
		.add_animation("attack_sample", anim);

	

func play_weapon_attack()->void:
	var player:AnimationPlayer = current_weapon.animation_player;
	var attack_key:String = current_weapon.get_animation_key("attack_sample")
	player.play(attack_key);
	
	var key:String = PlayerFighterBase.feedback_animation_keys[current_weapon.display.use_feedback]
	
	body_animation_player.play("player/"+key)
	body_animation_player.animation_finished.connect(play_body_idle, CONNECT_ONE_SHOT)
	player.animation_finished.connect(play_weapon_idle)
	
func play_weapon_idle(_anim_name:String="")->void:
	var idle_key:String = current_weapon.get_animation_key("idle")
	current_weapon.animation_player.play(idle_key);

func play_body_idle(_key:String)->void:
	body_animation_player.play("player/idle")

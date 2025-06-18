extends UIRoot

signal pre_battle_started;

var to_fight:Leader;

var from:String;

@export_group("visual elements")
@export var player_name_label:Label;
@export var enemy_name_label:Label;

@export var enemy_party_count_label:Label;

@export var enemy_party_power_icon:PartyPowerIcon;
@export var enemy_party_icon:PartyIcon;

@export var plates_container:HBoxContainer;

@export var opponent_avatar:Control;
var opponent_sprite:Sprite2D;

func _ready()->void:
	player_name_label.text = Entities.player.name;
	Entities.pre_battle = self;

func start_pre_battle(opponent:Leader=Entities.current_speaking_party.leader, origin:String="dialogue")->void:
	Entities.world_map.pause_map()
	pre_battle_started.emit();
	to_fight = opponent;
	from = origin;
	enemy_name_label.text = opponent.name;
	enemy_party_icon.leader = opponent;
	enemy_party_icon.refresh()
	enemy_party_power_icon.leader = opponent;
	enemy_party_power_icon.refresh()
	set_opponent_avatar(opponent)

	set_process_mode(PROCESS_MODE_ALWAYS)
	Entities.world_map.pause_map()
	
	slide_in()
	
	Entities.main_bgm.play_bgm("combat")
	show()


func _on_start_battle_pressed() -> void:
	await Tweens.ui_fade_in(Entities.loading_screen).finished;
	hide();
	
	var arena:Arena = Index.arena_scene.instantiate();
	arena.finished_loading.connect(Entities.loading_screen.fade_out, CONNECT_ONE_SHOT);
	
	arena.start_battle(to_fight)
	## so inventory stays consitent
	## probably make a better solution eventually
	Entities.player.reparent(Entities.arena);
	
	Entities.main.remove_child(Entities.world_map)


func set_opponent_avatar(target:Leader)->void:
	if opponent_sprite:
		opponent_sprite.queue_free()
	
	opponent_sprite = target.leader_unit.base.duplicate();
	opponent_sprite.offset = opponent_sprite.sample_offset
	ColorCoder.color_code_fighter(opponent_sprite,target.color_scheme_index);
	opponent_avatar.add_child(opponent_sprite);


func _on_animation_ticker_timeout() -> void:
	if opponent_sprite.frame:
		opponent_sprite.frame = 0;
	else:
		opponent_sprite.frame = 1;



func slide_in()->void:
	plates_container.add_theme_constant_override("separation", 2000);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(plates_container, "theme_override_constants/separation", 200, 1);
	tween.set_trans(Tween.TRANS_ELASTIC);
	tween.tween_property(plates_container, "theme_override_constants/separation", 0, .5);

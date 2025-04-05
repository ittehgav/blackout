extends Control

var enemy_leader:NpcFighter;

@export var avatar:TextureRect;
@export var hp_bar:TextureProgressBar
@export var cooldown_bar:TextureProgressBar;

func _ready():
	await Entities.arena.ready;
	enemy_leader = Entities.arena.team_2.leader_fighter;
	var sprite = enemy_leader.base.duplicate();
	for c in sprite.get_children():
		c.queue_free()
	
	enemy_leader.damage_taken.connect(damage_feedback)
	enemy_leader.skill_used.connect(skill_icon_bounce)

	
	hp_bar.max_value = enemy_leader.max_hp;
	cooldown_bar.max_value = enemy_leader.cooldown_timer.wait_time;
		
	ColorCoder.color_code_fighter(sprite, 2);
	avatar.texture.atlas = sprite.texture;
	
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	
func _process(_delta:float)->void:
	if enemy_leader:
		var timer = enemy_leader.cooldown_timer;
		cooldown_bar.value = timer.wait_time - timer.time_left;
		
		hp_bar.value = enemy_leader.hp;


func skill_icon_bounce():
	var x_roll = randi_range(0, 16);
	var y_roll = randi_range(0, 16)
	cooldown_bar.custom_minimum_size = Vector2(48 + x_roll, 48 + y_roll);
	
	var tween = create_tween();
	tween.tween_property(cooldown_bar, "custom_minimum_size", Vector2(48, 48), .25)


func damage_feedback():
	avatar.modulate = Color.RED;
	var tween = create_tween();
	tween.tween_property(avatar, "modulate", Color.WHITE, .25);

extends Control


var enemy_leader:Leader;
var enemy_leader_fighter:NpcFighter;


@export var avatar:TextureRect;
@export var hp_bar:TextureProgressBar
@export var cooldown_bar:TextureProgressBar;

func _ready()->void:
	await Entities.arena.ready;
	enemy_leader = Entities.arena.team_2.leader;
	enemy_leader_fighter = Entities.arena.team_2.leader_fighter;
	var sprite:FighterBase = enemy_leader_fighter.base.duplicate();
	for c in sprite.get_children():
		c.queue_free()
	
	enemy_leader_fighter.damage_taken.connect(damage_feedback)
	enemy_leader_fighter.skill_used.connect(skill_icon_bounce)

	
	hp_bar.max_value = enemy_leader_fighter.max_hp;
	cooldown_bar.max_value = enemy_leader_fighter.cooldown_timer.wait_time;
		
	ColorCoder.color_code_fighter(sprite, enemy_leader.color_scheme_index);
	avatar.texture.atlas = sprite.texture;
	
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	enemy_leader_fighter.death.connect(enemy_leader_death)
	
func _process(_delta:float)->void:
	if is_instance_valid(enemy_leader):
		var timer:Timer = enemy_leader_fighter.cooldown_timer;
		cooldown_bar.value = timer.wait_time - timer.time_left;
		
		hp_bar.value = enemy_leader_fighter.hp;

func enemy_leader_death(_killer:ActiveFighter)->void:
	set_process(false)

func skill_icon_bounce()->void:
	var x_roll:int = randi_range(0, 16);
	var y_roll:int = randi_range(0, 16)
	cooldown_bar.custom_minimum_size = Vector2(48 + x_roll, 48 + y_roll);
	
	var tween:Tween = create_tween();
	tween.tween_property(cooldown_bar, "custom_minimum_size", Vector2(48, 48), .25)


func damage_feedback(_damage:float)->void:
	avatar.modulate = Color.RED;
	var tween:Tween = create_tween();
	tween.tween_property(avatar, "modulate", Color.WHITE, .25);

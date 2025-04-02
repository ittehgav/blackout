extends ActiveFighter;

class_name InFightPlayer

signal started_moving;
signal stopped_moving;

##redeclaring body as base so it gets its VFX to work the same way as they do on ActiveFighter
@export_category("Unique to Player")
@export var body: FighterBase;
@export var weapon:Node2D;
@export var hit_scan:Area2D;
@export var camera:Camera2D;
@export var sfx:AudioStreamPlayer


var moving:bool = false;

func _ready()->void:
	Entities.in_fight_player = self;
	## this node is the only fighter that'll always be in an arena instance
	load_fighter()

func load_fighter()->void:
	var stats:CombatStats = Entities.player.combat_stats;
	
	max_hp = stats.max_hp;
	hp = stats.max_hp;
	
	## player's combat stats will be more tied to equipment?
	attack = stats.attack
	defense = stats.defense
	
	technique = stats.technique
	move_speed = stats.move_speed
	
	var equipped_weapon:Weapon = Entities.player.equipped_weapon.duplicate()
	weapon.add_child(equipped_weapon);
	weapon.equip_weapon(equipped_weapon)
	

func get_input()->void:
	var input_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * move_speed
	body.moving_right = velocity.x > 0;
	if velocity:
		if not moving:
			started_moving.emit()
			moving = true;
			body.switch_animation("walk")
	else:
		if moving:
			stopped_moving.emit()
			moving = false;
			body.switch_animation("idle")
	

func _physics_process(_delta:float)->void:
	get_input()
	move_and_slide()
	hit_scan.look_at(get_global_mouse_position())


func _on_stun_timeout() -> void:
	set_physics_process(true)

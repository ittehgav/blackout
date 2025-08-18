extends ActiveFighter;

class_name PlayerFighter



##redeclaring body as base so it gets its VFX to work the same way as they do on ActiveFighter
@export_category("Unique to Player")
@export var body: FighterBase;
@export var equipment:Node2D;
@export var hit_scan:Area2D;
@export var camera:Camera2D;
@export var sfx:AudioStreamPlayer



var walking_blocked:bool=false;

func _ready()->void:
	name = Entities.player.name;
	Entities.player_fighter = self;

	## this node is the only fighter that'll always be in an arena instance
	load_fighter()


func load_fighter()->void:
	var stats:CombatStats = Entities.player.combat_stats;
	
	max_hp = stats.max_hp;
	hp = stats.max_hp;
	
	## these are loaded and then used by the wepaons and modules
	attack = stats.attack
	defense = stats.defense
	agility = stats.agility
	
	technique = stats.technique
	move_speed = stats.move_speed


func get_input(delta:float)->void:
	var input_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * move_speed
	if velocity:
		if not moving:
			started_moving.emit()
			moving = true;
	else:
		if moving:
			stopped_moving.emit()
			moving = false;
	

func _physics_process(delta:float)->void:
	if not walking_blocked:
		get_input(delta)
		move_and_slide()


func _on_stat_changed(stat: String) -> void:
	match stat:
		"agility":
			equipment.refresh_weapon_cooldown()

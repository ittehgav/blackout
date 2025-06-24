extends ActiveFighter;

class_name InFightPlayer

signal started_moving;
signal stopped_moving;

##redeclaring body as base so it gets its VFX to work the same way as they do on ActiveFighter
@export_category("Unique to Player")
@export var body: FighterBase;
@export var equipment:Node2D;
@export var hit_scan:Area2D;
@export var camera:Camera2D;
@export var sfx:AudioStreamPlayer

@export var shadow:Node2D;


var walking_blocked:bool=false;
var moving:bool = false;

func _ready()->void:
	name = Entities.player.name;
	Entities.player_fighter = self;
	Entities.arena.team_1.leader_fighter = self;
	Entities.arena.tide_bar.team_1_unit_values[self] = Entities.player.combat_level;

	## this node is the only fighter that'll always be in an arena instance
	load_fighter()
	var outline_color:Color = Index.color_schemes[Entities.player.color_scheme_index][1];
	material.set_shader_parameter("color", outline_color )

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
	if not walking_blocked:
		get_input()
		move_and_slide()
		hit_scan.look_at(get_global_mouse_position())


func _on_stat_changed(stat: String) -> void:
	match stat:
		"agility":
			equipment.refresh_weapon_cooldown()

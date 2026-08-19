@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_character.png")
extends ActiveFighter;

class_name PlayerFighter



##redeclaring body as base so it gets its VFX to work the same way as they do on ActiveFighter
@export var body: FighterBase;
@export var equipment:EquipmentControl;
@export var hit_scan:Area2D;
@export var camera:PlayerCamera;
@export var sfx:AudioStreamPlayer


var body_angle:float:
	get():
		if stunned:
			return body.on_stun_angle;
		if equipment.not_attacking() or not equipment.equipped_weapon.melee:
			var direction:Vector2;
			if not moving:
				direction = global_position.direction_to(get_global_mouse_position())
			else:
				direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			
			return direction.angle()
		else:
			return equipment.weapon_control.attack_angle.angle()



func _ready()->void:
	var player:Player = Entities.player;

	name = player.name;
	Entities.player_fighter = self;
	level = player.level;

	## this node is the only fighter 
	## that'll always be in any arena instance
	load_fighter()



func load_fighter()->void:
	var player:Player = Entities.player
	var stats:CombatStats = player.final_stats();
	
	for stat:String in CombatStats.all_stats:
		initial_stats[stat] = stats[stat];

	
	var accessory_1:Accessory = player.equipped_accessory_1;
	var accessory_2:Accessory = player.equipped_accessory_2;
	for accessory:Accessory in [accessory_1, accessory_2]:
		if accessory:
			if accessory.application == "battle_start":
				if not accessory.apply_during_battle:
					accessory.battle_start_apply(self);
				else:
					## TODO probably some signal that gets fetched from global scope
					## instead of this
					ally_team.arena.battle_started.connect(accessory.battle_start_apply.bind(self))
	
	refresh_all_stats()
	hp = max_hp;

func _physics_process(delta:float)->void:
	if not flying and not stunned:
		movement_input(delta)
	if not stunned or flying:
		move_and_slide()



## where slowdown from attacking is applied
var action_force:float = 1;
func movement_input(delta:float)->void:
	var input_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction != Vector2.ZERO:
		if not moving:
			started_moving.emit()
			moving = true;
	else:
		if moving:
			stopped_moving.emit()
			moving = false;
			
	var target_velocity:Vector2 = input_direction * move_speed * action_force
	velocity = velocity.lerp(target_velocity, 1.0  - exp(-10 * delta))


func get_sector(angle: float) -> int:
	## idk the secto function dont catch 7 properly
	## and this is still simpler than making an if to catch all 8 sectors
	var direction_sector:int = get_sector_full(angle)
	match direction_sector:
		0:
			if not moving:
				var cursor_x:int = get_global_mouse_position().x;
				var body_x:int = global_position.x;

				if cursor_x > body_x:
					direction_sector = 1;
				else:
					direction_sector = 7
			else:
				var weapon:Weapon = equipment.weapon_control.weapon;
				if weapon.scale > Vector2.ZERO:
					direction_sector = 1;
				else:
					direction_sector = 7
		4:
			if not moving:
				var cursor_x:int = get_global_mouse_position().x;
				var body_x:int = global_position.x;
				if cursor_x > body_x:
					direction_sector = 3;
				else:
					direction_sector = 5
			else:
				var weapon:Weapon = equipment.weapon_control.weapon;
				if weapon.scale > Vector2.ZERO:
					direction_sector = 3;
				else:
					direction_sector = 5
	return direction_sector;



func _on_stat_changed(stat: String) -> void:
	refresh_stat(stat)
	match stat:
		"agility":
			equipment.refresh_weapon_cooldowns()


func _on_equipment_weapon_unequipped(weapon: Weapon) -> void:
	## don't need to emit here since this always comes just before a weapon_equipped call
	stat_modifiers.attack -= weapon.base_damage;

func _on_equipment_weapon_equipped(weapon: Weapon) -> void:
	stat_modifiers.attack += weapon.base_damage;
	stat_changed.emit('attack')

func on_battle_over(_won:bool)->void:
	pass


func _on_status_applied(_source: ActiveFighter, status: Status, _quiet: bool) -> void:
	if status.type == "stun":
		if moving:
			stopped_moving.emit()
		moving = false;
		

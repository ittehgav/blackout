@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_character.png")
extends ActiveFighter;

class_name PlayerFighter



##redeclaring body as base so it gets its VFX to work the same way as they do on ActiveFighter
@export_category("Unique to Player")
@export var body: FighterBase;
@export var equipment:EquipmentControl;
@export var hit_scan:Area2D;
@export var camera:Camera2D;
@export var sfx:AudioStreamPlayer

@export var floating_icon_anchor:Control



var walking_blocked:bool=false;

func _ready()->void:
	var player:Player = get_tree().get_first_node_in_group("player")

	name = player.name;
	Entities.player_fighter = self;
	level = player.level;

	## this node is the only fighter that'll always be in an arena instance
	load_fighter()


func load_fighter()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	var stats:CombatStats = player.final_stats();
	
	for stat:String in Index.all_combat_stats:
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
	if not walking_blocked:
		movement_input(delta)
		move_and_slide()
		
func movement_input(delta:float)->void:
	var input_direction:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction:
		if not moving:
			started_moving.emit()
			moving = true;
	else:
		if moving:
			stopped_moving.emit()
			moving = false;
			
	var target_velocity:Vector2 = input_direction * move_speed
	velocity = velocity.lerp(target_velocity, 1.0  - exp(-10 * delta))




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

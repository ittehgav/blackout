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
	name = Entities.player.name;
	Entities.player_fighter = self;
	level = Entities.player.level;

	## this node is the only fighter that'll always be in an arena instance
	load_fighter()


func load_fighter()->void:
	
	
	var stats:CombatStats = Entities.player.final_stats();
	
	for stat:String in Index.all_combat_stats:
		initial_stats[stat] = stats[stat];

	
	var accessory_1:Accessory = Entities.player.equipped_accessory_1;
	var accessory_2:Accessory = Entities.player.equipped_accessory_2;
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

func get_input()->void:
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


func _physics_process(_delta:float)->void:
	if not walking_blocked:
		get_input()
		move_and_slide()


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

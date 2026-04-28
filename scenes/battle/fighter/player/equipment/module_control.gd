extends Node

class_name ModuleControl

var module:Module;

@export var module_cd:Timer;
@export var equipment:EquipmentControl;

@export var sfx:AudioStreamPlayer;

var holding_continuous:bool=false

func _ready()->void:

	await equipment.holder.ready
	var player:Player = get_tree().get_first_node_in_group("player")
	module = player.equipped_module.duplicate(DUPLICATE_USE_INSTANTIATION);
	module.hide();
	
	if module.ammo_type:
		module.ammo_consumed.connect(equipment.ammo_consumed.emit);
		module.ammo_ran_out.connect(equipment.ammo_ran_out.emit)
	
	add_child(module); 
	## adding it because there's a lot of stuff that nodes can only do when they're in the tree
	module_cd.wait_time = module.cooldown;
	
	module.equipped.emit();

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("use_module"):
		module_input();
	elif Input.is_action_just_released("use_module") and holding_continuous:
		release_module_command();
		

func module_input()->void:
	if module_cd.is_stopped() and not module.check_disabled():
		if module.continuous:
			holding_continuous = true
			module.start();
			equipment.continuous_module_started.emit()
		else:
			module.use();
			module_cd.start();
			equipment.module_used.emit();
	else:
		equipment.module_fumbled.emit();

func release_module_command()->void:
	## maybe won't be able to always control the active variable from here?
	equipment.continuous_module_released.emit()
	module.release();
	module_cd.start()
	holding_continuous = false

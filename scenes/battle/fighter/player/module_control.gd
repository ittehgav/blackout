extends Node

class_name ModuleControl

var module:Module;

@export var module_cd:Timer;
@export var equipment:EquipmentControl;

@export var sfx:AudioStreamPlayer;

func _ready()->void:
	await equipment.holder.ready
	module = Entities.player.equipped_module.duplicate(DUPLICATE_USE_INSTANTIATION);
	module.hide();
	add_child(module); 
	## adding it because there's a lot of stuff that nodes can only do when they're in the tree
	module_cd.wait_time = module.cooldown;
	
	module.equipped.emit();

func _process(_delta:float)->void:
	if Input.is_action_just_pressed("use_module"):
		module_input();
	elif Input.is_action_just_released("use_module") and module.active:
		module_input_release();
		

func module_input()->void:
	if module_cd.is_stopped() and not module.check_disabled():
		if module.continuous:
			module.start();
			module.active = true
		else:
			module.use();
			module_cd.start();
		equipment.module_used.emit();
	else:
		equipment.module_fumbled.emit();

func module_input_release()->void:
	## maybe won't be able to always control the active variable from here?
	module.release();
	module.active = false;
	module_cd.start()

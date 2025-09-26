extends PanelContainer

@export var module_cd_timer:Timer;
@export var module_bar:TextureProgressBar
var module:Module;

func _ready()->void:
	module = Entities.player.equipped_module;
	module_bar.max_value = module.cooldown
	
	module_bar.texture_under = module.texture;
	module_bar.texture_progress = module.texture;
	module_bar.tint_progress = module.get_mirror_color();
	

func _process(_delta:float)->void:
	module_bar.value = module_cd_timer.wait_time - module_cd_timer.time_left;

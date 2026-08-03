extends PanelContainer
class_name ModuleCooldownDisplay

@export var module_cd_timer:Timer;
@export var module_bar:TextureProgressBar

@export var module_ammo_hbox:HBoxContainer;

@onready var player:Player = Entities.player

var module:Module;

var ammo_label:Label

func _ready()->void:
	module = player.equipped_module;
	module_bar.max_value = module.cooldown
	if module.ammo_cost:
		var icon:ResourceIcon = Index.scenes.ui.resource_icon.instantiate();
		icon.bg.hide();
		
		icon.custom_minimum_size = Vector2(16, 16);
		icon.size = Vector2(16, 16);
		
		ammo_label = Label.new();
		icon.resource = module.ammo_type
		icon.label = ammo_label;
		
		
		module_ammo_hbox.add_child(icon);
		module_ammo_hbox.add_child(ammo_label);
		
	module_bar.texture_under = module.texture;
	module_bar.texture_progress = module.texture;
	module_bar.tint_progress = module.get_mirror_color();


func _process(_delta:float)->void:
	module_bar.value = module_cd_timer.wait_time - module_cd_timer.time_left;

func check_module_disabled()->void:
	if module.check_disabled():
		module_bar.modulate.a = .5;
		module_bar.modulate.v = .5;
	else:
		module_bar.modulate = Color.WHITE;



func _on_equipment_ammo_consumed(ammo_type: String, _amount: int) -> void:
	if ammo_type == module.ammo_type:
		ammo_label.text = str(player.inventory[ammo_type])
		
		module_ammo_hbox.modulate.a = .25;
		var tween:Tween = create_tween();
		tween.tween_property(module_ammo_hbox, "modulate:a", 1, .5)

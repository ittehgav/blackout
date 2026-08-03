extends Node
class_name ArtificeControl;

@export var equipment:EquipmentControl;
@export var weapon_control:WeaponControl

@export var default_cursor:Texture;

@export var crosshair_f1_texture:Texture;
@export var crosshair_f2_texture:Texture;
@export var crosshair_f3_texture:Texture;

@export var crosshair_big_texture:Texture

@export var cursor_loop_ticker:Timer

@export var start_aim_sfx:AudioStreamPlayer;

var projection:Sprite2D;

var artifice_1:Artifice;
var artifice_2:Artifice;
var artifice_3:Artifice;

func _ready()->void:
	await equipment.holder.ready;
	setup()

func setup()->void:
	var player:Player = Entities.player;
	for key:int in player.equipped_artifices.keys():
		var artifice:= player.equipped_artifices[key];
		if artifice:
			self["artifice_" + str(key)] = artifice;
			artifice.setup()
		else:
			self["artifice_"+str(key)] = null;
	Entities.player.equipment_changed.connect(_on_player_equipment_changed)

func _on_player_equipment_changed(eq:Equipment)->void:
	if eq is Artifice:
		var slot:int = eq.get_equipped_slot();
		if slot and slot in depleted:
			depleted.erase(slot)
			self["artifice_"+str(slot)] = eq

func _process(_delta:float)->void:
	if projection:
		projection.global_position = equipment.get_global_mouse_position() - Vector2(48, 0);

func _input(e:InputEvent)->void:
	if e.is_action_pressed("use_artifice_1"):
		use_artifice_command(1);
	elif e.is_action_pressed("use_artifice_2"):
		use_artifice_command(2);
	elif e.is_action_pressed("use_artifice_3"):
		use_artifice_command(3)
	elif e.is_action_pressed("use_artifice_confirm") and current_using_artifice:
		confirm_use_artifice();

var depleted:Array[int]
var current_using_artifice:int=0;
func use_artifice_command(which:int)->void:
	if which in depleted:
		equipment.artifice_fumbled.emit()
		return
	## ARTIFICES WILL CONSUME THEMSELVES IN THEIR OWN USE FUNCTION?
	var to_use:Artifice = self["artifice_"+str(which)];
	assert(to_use);
	const types = Artifice.UseType
	match to_use.use_type:
		types.cursor_input:
			if current_using_artifice == which:
				stop_artifice_aiming(which)
			else:
				start_artifice_aiming(which)
		types.instant:
			start_aim_sfx.play()
			use_artifice(to_use)
			equipment.artifice_used.emit(which)

func use_artifice(target:Artifice)->void:
	var slot:int = target.get_equipped_slot()
	## catching this before so i dont have to think
	## about the object still existing after depleting
	if target.use_sfx:
		target.use_sfx.play();
	var last:bool = target.use()
	
	if last:
		depleted.append(slot);
	else:
		self["artifice_"+str(slot)] = Entities.player.equipped_artifices[slot]



var aiming:bool=false;
func start_artifice_aiming(which:int)->void:
	equipment.artifice_aiming_started.emit(which)
	start_aim_sfx.play()
	stop_artifice_aiming(which, true); ##to clear overlapping artifice aiming starts
	aiming = true;
	var to_use:Artifice = self["artifice_"+str(which)];
	projection = Sprite2D.new();
	projection.top_level = true;
	projection.texture = to_use.texture
	projection.scale = Vector2(2, 2);
	
	
	var tween:Tween = create_tween();
	var target_scale :Vector2 = projection.scale * 2
	tween.tween_property(projection, "scale", target_scale, .05)
	tween.tween_property(projection, "scale", projection.scale, .05)
	Entities.player_fighter.add_child(projection);
	
	_on_crosshair_loop_timeout()
	cursor_loop_ticker.start()
	
	current_using_artifice = which

func stop_artifice_aiming(which:int, clear:bool=false)->void:
	
	cursor_loop_ticker.stop();
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	Input.set_custom_mouse_cursor(default_cursor, 0, Vector2(32, 32))
	current_using_artifice = 0
	
	if projection:
		projection.queue_free();
		projection = null
	
	await get_tree().create_timer(.3).timeout
	if not clear:
		equipment.artifice_aiming_stopped.emit(which)
		aiming = false


func confirm_use_artifice()->void:
	var artifice:Artifice = self["artifice_"+str(current_using_artifice)]
	use_artifice(artifice)
	stop_artifice_aiming(current_using_artifice)
	equipment.artifice_used.emit(current_using_artifice + 1)

var crosshair_loop_f:int = 1
func _on_crosshair_loop_timeout() -> void:
	var cursor:Texture = self["crosshair_f"+str(crosshair_loop_f)+"_texture"]
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	Input.set_custom_mouse_cursor(cursor, 0, Vector2(32, 32));
	crosshair_loop_f += 1;
	if crosshair_loop_f == 4:
		crosshair_loop_f = 1;

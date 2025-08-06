extends Weapon

const rarity = 3

const size_x = 2;
const size_y = 4;

const not_continuous = true;
signal effect_finished;

const angle_adjust = 0;
const type = "melee";

const aoe_radius = 300;
const cooldown:float = 3;
const base_damage = 100;


const charge_time = 7.5;

const projection = "none";

const description = "Charges up a powerful AOE attack. Charge speeds up when units inside the area use their skill."


const use_vfx = ["grow"]

const use_sfx = "";

var active:bool = false;
var progress:float = 0;

@export var area:Area2D;
@export var progress_bar:TextureProgressBar;

var monitored_units:Array[Node2D]

func _ready()->void:
	area.monitoring=false
	progress_bar.max_value = charge_time
	
func _process(delta:float)->void:
	if active:
		progress += delta;
		progress_bar.value = progress;
		if progress >= charge_time:
			explode();

func use()->bool:
	if not active:
		progress_bar.scale = Vector2.ONE
		progress_bar.modulate.a = 1;
		progress_bar.show()
		var sfx:SfxPlayer = Entities.player_fighter.equipment.weapon_sfx
		sfx.play_sound_by_key("charge_up")
		sfx.finished.connect(intensify_charge, CONNECT_ONE_SHOT)
		active = true;
	return false

func explode()->void:
	active = false;
	progress = 0;
	progress_bar.value = 0;
	Combat.aoe_damage(Entities.player_fighter)
	
	Entities.player_fighter.equipment.weapon_sfx.play_sound_by_key("explosion")
	effect_finished.emit()
	
	var tween:= create_tween();
	tween.tween_property(progress_bar, "scale", Vector2(1.25, 1.25), .2);
	tween.parallel().tween_property(progress_bar, "modulate:a", 0, .2);
	tween.tween_callback(progress_bar.hide)



func intensify_charge()->void:
	## should never overlap with other sounds as the weapon SFX only works for the currently equipped weapon
	var sfx:SfxPlayer = Entities.player_fighter.equipment.weapon_sfx
	if active:
		sfx.pitch_scale = 1 + (1/charge_time) * progress + (1/charge_time) * progress
		sfx.play()
		sfx.finished.connect(intensify_charge, CONNECT_ONE_SHOT);
	else:
		sfx.pitch_scale = 1;


	

func _on_area_body_entered(body: Node2D) -> void:
	assert (body is ActiveFighter)
	if body is NpcFighter:
		## no reason to monitor self
		monitored_units.append(body)
		body.skill_used.connect(accelerate_charge)


func _on_area_body_exited(body: Node2D) -> void:
	assert(body is ActiveFighter);
	if body is NpcFighter:
		monitored_units.erase(body)
		if len(body.skill_used.get_connections()):
			body.skill_used.disconnect(accelerate_charge)

func accelerate_charge()->void:
	progress_bar.tint_progress.a = 1;
	var tween:Tween = create_tween();
	tween.tween_property(progress_bar, "tint_progress:a",.5, .1);
	if active:
		progress += 1;

func _on_equipped() -> void:
	area.monitoring = true;
	for body in area.get_overlapping_bodies():
		if body is NpcFighter:
			body.skill_used.connect(accelerate_charge)

func _on_unequipped() -> void:
	while len(monitored_units):
		var unit:Node2D = monitored_units.pop_back();
		assert(unit is ActiveFighter)
		unit.skill_used.disconnect(accelerate_charge)

	active = false;
	progress = 0;
	progress_bar.value = 0;

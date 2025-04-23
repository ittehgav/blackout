extends Weapon

const rarity = 3

const not_continuous = true;
signal effect_finished;

const angle_adjust = 0;
const type = "melee";

const damage = 100;
const aoe_radius = 300;
const cooldown:float = 3;

const charge_time = 7.5;

const projection = "none";

const description = "Charges up a powerful AOE blast. Charging speeds up when units inside the area use their skill."

const use_vfx = ["shake"]

const use_sfx = "";

var active:bool = false;
var progress:float = 0;

@export var area:Area2D;
@export var progress_bar:TextureProgressBar;

var monitored_units:Array[Node2D]

func _ready()->void:
	progress_bar.max_value = charge_time

func use()->bool:
	if not active:
		var sfx:SfxPlayer = Entities.in_fight_player.equipment.weapon_sfx
		sfx.play_sound_by_key("charge_up")
		sfx.finished.connect(intensify_charge, CONNECT_ONE_SHOT)
		active = true;
	return false

func explode()->void:
	active = false;
	progress = 0;
	progress_bar.value = 0;
	Combat.aoe_damage(Entities.in_fight_player)
	
	Entities.in_fight_player.equipment.weapon_sfx.play_sound_by_key("explosion")
	effect_finished.emit()

func _process(delta:float)->void:
	if active:
		progress += delta;
		progress_bar.value = progress;
		if progress >= charge_time:
			explode();

func intensify_charge()->void:
	## should never overlap with other sounds as the weapon SFX only works for the currently equipped weapon
	var sfx:SfxPlayer = Entities.in_fight_player.equipment.weapon_sfx
	if active:
		sfx.pitch_scale = 1 + (1/charge_time) * progress + (1/charge_time) * progress
		sfx.play()
		sfx.finished.connect(intensify_charge, CONNECT_ONE_SHOT);
	else:
		sfx.pitch_scale = 1;


	

func _on_area_body_entered(body: Node2D) -> void:
	assert (body is ActiveFighter)
	monitored_units.append(body)
	body.skill_used.connect(accelerate_charge)


func _on_area_body_exited(body: Node2D) -> void:
	assert(body is ActiveFighter);
	monitored_units.erase(body)
	body.skill_used.disconnect(accelerate_charge)

func accelerate_charge()->void:
	if active:
		progress += 1;

func _on_equipped() -> void:
	for body in area.get_overlapping_bodies():
		body.skill_used.connect(accelerate_charge)

func _on_unequipped() -> void:
	while len(monitored_units):
		var unit:Node2D = monitored_units.pop_back();
		assert(unit is ActiveFighter)
		unit.skill_used.disconnect(accelerate_charge)

	active = false;
	progress = 0;
	progress_bar.value = 0;

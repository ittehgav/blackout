extends ItemTargetSelector
class_name ArtificeSlotSelector

signal artifice_equipped(slot:int);
signal artifice_unequipped(slot:int)

@export var sample_1:ItemSample
@export var sample_2:ItemSample
@export var sample_3:ItemSample

var current_artifice:Artifice;

func _ready()->void:
	set_process_input(false)

func show_options(target:Artifice)->void:
	get_parent().sfx.play_sound_by_key("item_target")
	current_artifice = target;
	for i in range(1, 4):
		var sample:ItemSample = self["sample_"+str(i)]
		var equipped_artifice:Artifice = Entities.player.equipped_artifices[i];
		if equipped_artifice:
			sample.load_item(equipped_artifice, 2);
		else:
			sample.load_blank(3)
	Tweens.ui_fade_in(self)
	global_position = get_global_mouse_position();
	fit_to_window()
	
	enable_input()
	fit_to_window();

func _input(e:InputEvent)->void:
	if e.is_action_pressed("use_artifice_1"):
		equip_on_slot(1)
	elif e.is_action_pressed("use_artifice_2"):
		equip_on_slot(2)
	elif e.is_action_pressed("use_artifice_3"):
		equip_on_slot(3);

func enable_input()->void:
	set_process_input(true)
	for sample:ItemSample in [sample_1, sample_2, sample_3]:
		sample.mouse_filter = Control.MOUSE_FILTER_STOP
func disable_input()->void:
	set_process_input(false)
	for sample:ItemSample in [sample_1, sample_2, sample_3]:
		sample.mouse_filter = Control.MOUSE_FILTER_IGNORE

func equip_on_slot(slot:int)->void:
	current_artifice.mirror.display.board_shake(5);
	current_artifice.mirror.highlight_blink()
	var just_unequipped:Artifice = Entities.player.equip_artifice(current_artifice, slot);
	if just_unequipped:
		just_unequipped.mirror.highlight_blink();
		just_unequipped.mirror.refresh();
		artifice_unequipped.emit(slot)
	
	current_artifice.mirror.display.refresh_data()
	artifice_equipped.emit(slot)
	Tweens.ui_fade_out(self)
	disable_input()

func _on_artifice_1_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.is_pressed():
		equip_on_slot(1);
func _on_artifice_2_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.is_pressed():
		equip_on_slot(2);
func _on_artifice_3_gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.is_pressed():
		equip_on_slot(3);

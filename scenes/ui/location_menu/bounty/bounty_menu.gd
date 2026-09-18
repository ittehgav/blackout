extends UIRoot
class_name BountyMenu

signal bounty_board_exited;
const show_player_resources = true;
var board:BountyBoard;
@export var main_panel:PanelContainer
@export var displays_hbox:HBoxContainer

@export var claim_confirmation:ClaimBountyConfirmation;


@export var unit_sheet_scene:PackedScene;
@export var bounty_display_scene:PackedScene



var active_bounty_displays:Array[BountyDisplay]

const bt = Bounty.Type

func start_bounty_menu()->void:
	claim_confirmation.refresh()
	active_bounty_displays = []
	slide_in()
	for c in displays_hbox.get_children():
		c.queue_free()
	for bounty:Bounty in board.bounties:
		var display:BountyDisplay = bounty_display_scene.instantiate();
		display.load_bounty(bounty);
		displays_hbox.add_child(display)
		active_bounty_displays.append(display)
		
		display.unit_reward_clicked.connect(show_unit_reward)
		display.claim_pressed.connect(on_claim_pressed)
		
	recursive_connect_ui_feedback(self)


func slide_in()->void:
	show()
	var tween:= create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(main_panel, "offset_transform_position:x", 0, .5);
	tween.parallel().tween_interval(.2);
	tween.tween_callback(dangle_bounties)

func dangle_bounties()->void:
	for d:BountyDisplay in active_bounty_displays:
		var tween := create_tween();
		tween.tween_property(d, "offset_transform_rotation", -PI*.018, .05);
		tween.tween_property(d, "offset_transform_rotation", PI*.018, .05);
		tween.tween_property(d, "offset_transform_rotation", 0, .2)

func slide_out()->void:
	var tween := create_tween();
	tween.tween_property(main_panel, "offset_transform_position:x", 3000, .5)
	tween.tween_callback(hide)

func show_unit_reward(target:FighterUnit)->void:
	var sheet:UnitSheet = unit_sheet_scene.instantiate();
	add_child(sheet);
	sheet.display_unit(target)
	Tweens.ui_fade_in(sheet);

func _on_exit_pressed() -> void:
	slide_out();
	bounty_board_exited.emit()

func on_claim_pressed(b:Bounty)->void:
	match b.type:
		bt.deliver_unit:
			claim_confirmation.deliver_unit_confirmation(b);
		bt.deliver_item:
			claim_confirmation.start_confirmation(b);
		bt.deliver_resource:
			claim_confirmation.start_confirmation(b)
		bt.clear_dungeon:
			claim_confirmation.claim_animation(b);
			b.claim()
		_:
			assert(false)

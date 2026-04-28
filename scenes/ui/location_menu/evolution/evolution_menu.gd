extends UIRoot
class_name EvolutionMenu

signal opened;
signal evolution_finished;


@onready var player:Player = get_tree().get_first_node_in_group("player");

@export var content_hbox:HBoxContainer;
@export var available_units_vbox:VBoxContainer

@export var evolution_line_hbox:HBoxContainer

@export var confirmation_screen:Control;

@export var evolutions_view:MarginContainer;
@export var placeholder_text:Label;


var current_unit:FighterUnit

func start_evolution_menu()->void:
	opened.emit()
	for c:Node in available_units_vbox.get_children():
		c.queue_free()
	for unit:FighterUnit in player.roster.units:
		if len(unit.base.evolutions):
			add_unit_option(unit);
	recursive_connect_ui_feedback(available_units_vbox);
	
	
	evolutions_view.hide();
	placeholder_text.show()

	slide_in()

func add_unit_option(unit:FighterUnit)->void:
	var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
	sample.load_unit(unit);
	available_units_vbox.add_child(sample);
	sample.pressed.connect(show_unit_evolutions.bind(unit));

func show_unit_evolutions(unit:FighterUnit)->void:
	for c in evolution_line_hbox.get_children():
		c.queue_free();
	var current_unit_sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
	current_unit_sample.load_unit(unit)
	evolution_line_hbox.add_child(current_unit_sample);
	current_unit_sample.modulate.v = .75
	
	var v:VBoxContainer = VBoxContainer.new()
	for e:FighterBase in unit.base.evolutions:
		var sample:UnitSample = Index.scenes.ui.unit_sample.instantiate();
		sample.load_base(e, unit.level);
		v.add_child(sample);
		recursive_connect_ui_feedback(sample);
		sample.pressed.connect(confirmation_screen.prompt_evolution_confirmation.bind(unit, e))

	evolution_line_hbox.add_child(v);
	
	placeholder_text.hide();
	evolutions_view.show()
	
	

	
func slide_in()->void:
	show()
	content_hbox.add_theme_constant_override("separation", 400);
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 10, .75)

func slide_out()->void:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC);
	tween.tween_property(content_hbox, "theme_override_constants/separation", 400, .5)
	tween.parallel().tween_property(self, "modulate:a", 0, .5);
	tween.tween_callback(hide);
	tween.tween_callback(set_modulate.bind(Color.WHITE))


func _on_exit_pressed() -> void:
	slide_out();
	evolution_finished.emit()

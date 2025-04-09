extends Control

@export var settlement_ui:UIRoot;
@export var main_view:Control;

var fading:bool = false;

func _ready()->void:
	set_process_input(false)

func _input(e: InputEvent) -> void:
	if (e is InputEventMouseButton or e is InputEventKey) and e.pressed and not fading:
		fade_out();

func fade_out()->void:
	main_view.modulate.a = 0;
	main_view.show();
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 0, .25);
	tween.parallel().tween_property(main_view, "modulate:a", 1, .25);
	tween.tween_callback(hide)
	fading = true;
	await tween.finished;
	fading = false


func _on_memo_label_meta_clicked(key: Variant) -> void:
	var settlement:Settlement = Entities.world_map.all_settlements[key]
	settlement_ui.exit_settlement()
	Entities.in_map_player.camera.pan_to_target(settlement)

func _on_visibility_changed() -> void:
	set_process_input(visible);

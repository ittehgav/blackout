extends PanelContainer
class_name ItemTargetSelector

func fit_to_window()->void:
	global_position = get_global_mouse_position();
	var rect:Rect2 = get_global_rect()
	var window_size:Vector2 = get_window().size;
	

	const shift_step = 50
	while rect.position.x < 10:
		position.x += shift_step
		rect = get_global_rect()
	while rect.position.x + rect.size.x > window_size.x:
		position.x -= shift_step;
		rect = get_global_rect()
	
	while rect.position.y < 10:
		position.y += shift_step
		rect = get_global_rect()
	while rect.position.y + rect.size.y > window_size.y:
		position.y -= shift_step;
		rect = get_global_rect()
	## to force it to fit the items
	await get_tree().process_frame
	size = Vector2.ZERO

func _on_mouse_exited() -> void:
	await get_tree().create_timer(.5).timeout;
	var rect:Rect2 = get_global_rect();

	if not rect.has_point(get_global_mouse_position()):
		Tweens.ui_fade_out(self)

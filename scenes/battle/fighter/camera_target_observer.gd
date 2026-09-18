extends VisibleOnScreenNotifier2D
## just make it work until i figure out combat camera more broadly
@export var source:FighterBase

@export var zoom_in_ticker:Timer
var zoom_out_distance:int
var camera:PlayerCamera
func _ready()->void:
	if Entities.arena:
		camera  = Entities.player_fighter.camera
	else:
		queue_free()

var zoom_tween:Tween;
func _on_screen_exited() -> void:
	zoom_out_distance = source.global_position.distance_to(Entities.player_fighter.global_position)
	if zoom_tween and zoom_tween.is_running():
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.set_trans(Tween.TRANS_CUBIC)
	zoom_tween.tween_property(camera,"zoom", Vector2(.5, .5), .75)

	zoom_in_ticker.start()


func _on_check_zoom_in_timeout() -> void:
	if Entities.player_fighter.global_position.distance_to(source.global_position) < zoom_out_distance:
		if zoom_tween and zoom_tween.is_running():
			zoom_tween.kill()
		zoom_tween = create_tween()
		zoom_tween.set_trans(Tween.TRANS_CUBIC)
		zoom_tween.tween_property(camera,"zoom", Vector2.ONE, .75)

		zoom_in_ticker.stop()

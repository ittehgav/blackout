@icon("res://assets/visual/editor_ui/IconGodotNode/node/icon_audio.png")
extends AudioStreamPlayer
class_name SfxPlayer

func play_sound_by_key(key:String)->void:
	if is_inside_tree():
		if stream != self[key]:
			stream=self[key];
		play()
	
func play_sound_obj(obj:AudioStream)->void:
	if is_inside_tree():
		stream = obj;
		play();


var queue:int = 0;
func queue_sound_key(key:String)->void:
	## adds a small delay (rather than really queueing the sounds one after the other finishes)
	## to avoid amplitude sums
	if not queue:
		stream = self[key]
		play();
		queue += 1;
	elif queue < 6:
		## just skips after a while to not get comically long sounds
		queue += 1;
		await get_tree().create_timer(queue * .05).timeout;
		stream = self[key];
		play()
		queue -= 1

extends UIRoot



func world_map() -> void:
	var map:WorldMap = Index.world_map_scene.instantiate();
	get_parent().add_child(map);
	get_parent().remove_child(self);
	## one day this menu will have more stuff to do and will need to be returned to

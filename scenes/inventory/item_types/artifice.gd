@abstract
@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_animation.png")
class_name Artifice
extends Equipment

@export var projectile:Projectile
@export var use_sfx:AudioStreamPlayer;
@export var hit_sfx:AudioStreamPlayer;
@export var detonate_sfx:AudioStreamPlayer;

## ARTIFICES ARE ITEMS THAT ARE EQUIPPED AND USED DURING COMBAT
enum UseType{
	cursor_input,
	instant,
	passive
}
@export var use_type:UseType;
enum TargetType{
	enemy,
	ally
}
@export var target_types:Array[TargetType] = [TargetType.enemy]
## for setting up collision masks/layers, projectile hit scans
## and point-click targetting

@abstract func use()->bool;

func setup()->void:
	if projectile:
		projectile.setup(Entities.player_fighter);
	if status:
		status.source = Entities.player_fighter
		for c:Node in status.get_children():
			c.source  =Entities.player_fighter


func consume()->bool:
	var inventory:= get_parent();
	
	var last_one:bool=true;
	for item:Item in inventory.items:
		if item != self and item.unique_name == unique_name:
			last_one = false;
	if last_one:
		Entities.player.unequip_artifice(get_equipped_slot())
	else:
		## because the first one to be used will 
		## be the one referenced in the player's slot
		var i:int= Entities.player.inventory.artifices.find_custom(func(t:Artifice)->bool:return t.unique_name == unique_name and t != self)
		var copy:Artifice = Entities.player.inventory.artifices[i];
		Entities.player.equipped_artifices[get_equipped_slot()] = copy
		copy.setup()
		
	
	
	## only delete after so it can play sounds and call functions
	inventory.remove_item(self)
	hide();
	reparent(Entities.player_fighter.ally_team.projectiles)

	Entities.arena.battle_ended.connect(queue_free)
	return last_one;

func get_equipped_slot()->int:
	var d:Dictionary = Entities.player.equipped_artifices;
	for key:int in d.keys():
		if d[key] == self:
			return key;
	return 0

func throw()->Projectile:
	assert(projectile);
	if projectile is ArcProjectile:
		var thrown:ArcProjectile = Combat.shoot_projectile(projectile, Entities.player_fighter, hit_callback, detonate_callback)
		return thrown
	else:
		return Combat.shoot_projectile(projectile, Entities.player_fighter, hit_callback)

func hit_callback(_hit_target:ActiveFighter)->void:
	printerr(unique_name, " MISSING HIT CALLBACK")
func detonate_callback(_hit_location:Vector2)->void:
	printerr(unique_name, " MISSING DETONATE CALLBACK")

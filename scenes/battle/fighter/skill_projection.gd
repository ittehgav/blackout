@tool
extends AnimationPlayer
class_name SkillProjection;
@export var source:FighterBase;
@export var single_pixel_fill:Texture

@export var knockback_gradient:GradientTexture1D; 
@export var radial_gradient:GradientTexture2D

## keeps track of generated stuff to delete them on refresh
## only "root" of individual elements
## IE the node2D for a projection shape goes in but the polygon itself doesnt

## CHILD OF HITSCAN SO IT KEEPS ITS REFERENCES WHEN HIT SCAN IS REPARENTED
@export var generated_elements:Array[Node];

@export var knockback_projection:TextureRect;

var current_aoe_projection:Node2D;

enum AnimationType{
	flat,
	directional,
	radial
}

#@export var refresh_projection:bool:
	### idk why this set is called when this enters the tree
	### so we just comment it when not working on projections?
	#set(val):
		#generate_projection_animation()
		#refresh_projection = false

func _ready()->void:
	if source.fighter and source.fighter.ally_team.team_n == 2:
		setup_projection(source.fighter)
	else:
		queue_free()
		## queues free from base otherwise

func setup_projection(fighter:NpcFighter)->void:
	print("setup?")
	## only runs if unit is in enemy team?
	## queues free otherwise?
	fighter.skill_used.connect(play.bind("projection/projection"));
	
	var skill:SkillComponent = source.skill;
	
	#if SkillComponent.Effect.knockback in skill.effects:
		#fighter.skill_used.connect(line_up_knockback_projection.bind(fighter))

func line_up_knockback_projection(fighter:NpcFighter)->void:
	knockback_projection.global_position = fighter.target_fighter.global_position;
	knockback_projection.rotation = fighter.position.angle_to_point(fighter.target.position);

func generate_projection_animation()->void:
	## WILL PLAY WHEN TARGETTING/AOE POSITION IS ALREADY SET
	## FOR THE GIVEN SKILL USE
	## only plays from enemy units
	## only to display AOE areas/knockback trajectories
	clear_elements()
	
	var animation:Animation = Animation.new()
	animation.length = 1;
	
	var skill:SkillComponent = source.skill;
	for effect:SkillComponent.Effect in skill.effects:
		match effect:
			SkillComponent.Effect.aoe_damage:
				generate_aoe_projection();
				generate_aoe_animation.call_deferred(AnimationType.flat);
			SkillComponent.Effect.aoe_status:
				generate_aoe_projection();
				
				var status:Status = source.skill.status;
				var projection_shape:CanvasItem = current_aoe_projection.get_node("shape")
				projection_shape.modulate = status.get_status_color() - Color(0, 0, 0, .6);
				
				generate_aoe_animation.call_deferred(AnimationType.flat)
			SkillComponent.Effect.knockback:
				pass
				#generate_knockback_prjection();
				
			SkillComponent.Effect.aoe_knockback:
				pass
			SkillComponent.Effect.radial_knockback:
				generate_aoe_projection();
				
				var radius:float = source.hit_scan.get_node("shape").shape.radius;
				
				var polygon:Polygon2D = current_aoe_projection.get_node("shape");
				var sprite:Sprite2D = Sprite2D.new();
				
				var expanding_polygon:Polygon2D = polygon.duplicate();
				expanding_polygon.scale = Vector2.ZERO;
				expanding_polygon.name = "expansion"
				
				var target_scale:float = 4/(64/radius);
				sprite.scale = Vector2(target_scale, target_scale)
				sprite.name = "gradient"
				
				sprite.texture = radial_gradient;
				polygon.add_child(sprite);
				polygon.add_child(expanding_polygon)
				polygon.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
				generate_aoe_animation.call_deferred(AnimationType.radial)
				
				
				
	if current_aoe_projection:
		## so i can add children across multiple effect iterations
		add_element(current_aoe_projection, source.hit_scan)
		

func clear_elements()->void:
	for e:Node in generated_elements:
		e.name = "a"
		e.queue_free()
	generated_elements.clear()
	current_aoe_projection = null; 
	## not sure why it evaluates as true at script run?
	
	
	var lib:AnimationLibrary = get_animation_library("projection")
	lib.remove_animation("projection");
	lib.add_animation("projection", Animation.new())
	
	

func add_element(element:CanvasItem, parent:Node)->void:
	parent.add_child(element);
	set_owner_recursive(element)
	
	generated_elements.append(element)
	
		
func generate_aoe_projection()->Node2D:
	## will be added as child of hit_scan so it
	## only needs to match the collisionShape2D's shape
	assert(source.hit_scan)
	if current_aoe_projection:
		## will only need to match the hit scan once 
		## after that just stacks visuals/animation keys
		## and replaces them in property overlap scenarios
		## (of which there are none right now)
		return
	var shape:Shape2D = source.hit_scan.get_node("shape").shape;
	var shape_class:String = shape.get_class()
	current_aoe_projection = Node2D.new();
	current_aoe_projection.modulate.a = 0;
	match shape_class:
		"CircleShape2D":
			## can't change the class explicitly in GDscript
			var polygon:Polygon2D = generate_circle_polygon(shape)
			polygon.name = "shape"
			current_aoe_projection.add_child(polygon)

			
		"RectangleShape2D":
			var rect:RectangleShape2D = shape;
			var sprite:Sprite2D = Sprite2D.new();
			sprite.name = "shape"
			sprite.scale = rect.size;
			sprite.texture = single_pixel_fill
			current_aoe_projection.position.y -= rect.size.y/2

			current_aoe_projection.add_child(sprite);

		"SegmentShape2D":
			pass
		"ConvexPolygon2D":
			pass
	current_aoe_projection.name = "projection"

	return current_aoe_projection;
	
func generate_circle_polygon(shape:CircleShape2D)->Polygon2D:
	const segments = 64;
	var points:PackedVector2Array;
	for i in segments:
		var angle:float = TAU * i/segments;
		var point:Vector2 = Vector2.from_angle(angle)*shape.radius
		points.append(point);
		
	var polygon:Polygon2D = Polygon2D.new();
	polygon.polygon = points;
	return polygon
	
func generate_aoe_animation(type:AnimationType)->void:
	var lib:AnimationLibrary = get_animation_library("projection")
	var animation:Animation = lib.get_animation("projection");
	
	match type:
		AnimationType.flat:
			var track:int = animation.add_track(Animation.TYPE_VALUE)
			var target:Node2D = current_aoe_projection;
			var path:String = get_node(root_node).get_path_to(target)

			animation.track_set_path(track, path+":modulate:a");
			animation.track.insert_key(track, 0, 0)
			animation.track_insert_key(track, .16, .75);
			animation.track_insert_key(track, .4, .3);
			animation.track_insert_key(track, .65, .75);
			animation.track_insert_key(track, .66, 0);
		AnimationType.radial:
			## will overlap keys and be silly if we stack keys for the same objects?
			## always comes with AOE dmg anyway?
			var track:int = animation.add_track(Animation.TYPE_VALUE);
			var polygon:Polygon2D = current_aoe_projection.get_node("shape");
			var expanding_polygon:Polygon2D = polygon.get_node("expansion")
			
			var expansion_path:String = get_node(root_node).get_path_to(expanding_polygon)
			
			animation.track_set_path(track, expansion_path+":scale");
			animation.track_insert_key(track, 0, Vector2.ZERO);
			animation.track_insert_key(track, .65, Vector2.ONE);
			

			
func set_owner_recursive(target:Node)->void:
	target.owner = get_tree().edited_scene_root;
	for c in target.get_children():
		set_owner_recursive(c);

func generate_knockback_prjection()->void:
	## just loosely redoes the reference when refreshing
	## since previous one will be deleted on refresh
	knockback_projection = TextureRect.new();
	knockback_projection.size = Vector2(256, 2);
	knockback_projection.texture = knockback_gradient.duplicate();
	knockback_projection.modulate.a = 0;
	knockback_projection.name = "knockback_projection"
	var container:Node2D = Node2D.new()
	container.name = "kncokback_projection"
	add_element(container, source);


func _on_base_animations_animation_changed(_old_name: StringName, new_name: StringName) -> void:
	if new_name == "fighter_base/skill":
		play("projection/projection")

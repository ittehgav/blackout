@tool
extends AnimationPlayer
class_name SkillProjection;


@export_tool_button("Refresh Projection", "Reload") var refresh_projection:Callable = generate_projection_animation
@export var source:FighterBase;
## keeps track of generated stuff to delete them on refresh
## only "root" of individual elements
## IE the node2D for a projection shape goes in but the polygon itself doesnt

## CHILD OF HITSCAN SO IT KEEPS ITS REFERENCES WHEN HIT SCAN IS REPARENTED
@export var generated_elements:Array[Node];


## if unit doesn't have a hit scan just add as child of base scene
## and make whole scriop work naturally with this

@export var knockback_projection:TextureRect;

var current_aoe_projection:Node2D;

enum AnimationType{
	flat,
	directional,
	radial
}
@export_subgroup("textures")
@export var single_pixel_fill:Texture

@export var knockback_gradient:GradientTexture1D; 
@export var radial_gradient:GradientTexture2D
@export var knockback_arrow:Texture2D
func _ready()->void:
	if Engine.is_editor_hint():return;
	if source and source.fighter and source.fighter.ally_team.team_n == 2:
		setup_projection(source.fighter)
	else:
		queue_free()
		## queues free from base otherwise

func setup_projection(fighter:NpcFighter)->void:
	## only runs if unit is in enemy team?
	## queues free otherwise?

	fighter.skill_used.connect(play.bind("projection/projection"));
	
	var skill:SkillComponent = source.skill;
	
	if SkillComponent.Effect.knockback in skill.effects and SkillComponent.Effect.aoe_knockback not in skill.effects:
		fighter.skill_used.connect(line_up_knockback_projection.bind(fighter))

func line_up_knockback_projection(fighter:NpcFighter)->void:
	knockback_projection.global_position = fighter.target_fighter.global_position;
	knockback_projection.rotation = fighter.position.angle_to_point(fighter.target_fighter.position);

func generate_projection_animation()->void:
	## WILL PLAY WHEN TARGETTING/AOE POSITION IS ALREADY SET
	## FOR THE GIVEN SKILL USE
	## only plays from enemy units
	## only to display AOE areas/knockback trajectories
	clear_elements()
	
	var animation:Animation = Animation.new()
	animation.length = 1;
	
	const fx = SkillComponent.Effect
	
	var skill:SkillComponent = source.skill;
	for effect:fx in skill.effects:
		match effect:
			fx.aoe_damage:
				generate_aoe_projection();
				generate_aoe_animation.call_deferred(AnimationType.flat);
			fx.aoe_status:
				generate_aoe_projection();
				
				var status:Status = source.skill.status;
				var projection_shape:CanvasItem = current_aoe_projection.get_node("shape")
				projection_shape.modulate = status.get_status_color() - Color(0, 0, 0, .6);
				
				generate_aoe_animation.call_deferred(AnimationType.flat)
			fx.knockback:
				if not fx.aoe_knockback in skill.effects\
				and not fx.radial_knockback in skill.effects:
					generate_knockback_projection();
					generate_knockback_animation.call_deferred()
				
			fx.aoe_knockback:
				generate_aoe_projection();
				
				var shape:Node2D = current_aoe_projection.get_node("shape")
				var expanding_shape:Node2D = shape.duplicate()
				if expanding_shape is Polygon2D:
					expanding_shape.scale = Vector2.ZERO;
				else:
					expanding_shape.scale = Vector2(0, 1);
				expanding_shape.name = "expansion"
				shape.add_child(expanding_shape)
				
				generate_aoe_animation.call_deferred(AnimationType.directional)
			fx.radial_knockback:
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

	applied_animations.clear() ## not sure why it seems to persist between refreshes?
	generated_elements.clear()
	current_aoe_projection = null; 
	## not sure why it evaluates as true at script run?
	
	remove_animation_library("projection")
	var lib:AnimationLibrary = AnimationLibrary.new();
	add_animation_library("projection", lib)
	lib.remove_animation("projection");
	lib.add_animation("projection", Animation.new())

func add_element(element:CanvasItem, parent:Node)->void:
	parent.add_child(element);
	set_owner_recursive(element)
	
	generated_elements.append(element)

func set_owner_recursive(target:Node)->void:
	target.owner = get_tree().edited_scene_root;
	for c in target.get_children():
		set_owner_recursive(c);

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
	
	var aoe_shape:CollisionShape2D = source.hit_scan.get_node("shape")
	current_aoe_projection.scale = aoe_shape.scale;
	current_aoe_projection.rotation = aoe_shape.rotation
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
			var seg:SegmentShape2D = shape;
			var sprite:Sprite2D = Sprite2D.new();
			sprite.scale = Vector2(seg.b.x, 1)
			sprite.texture = single_pixel_fill;
			sprite.name = "shape"
			sprite.modulate = Color.RED ## this only applies to sniper rn 
			## because a red flashing beam just fits better
			## and there's no better place to add this colouring
			current_aoe_projection.add_child(sprite)
			
		"ConvexPolygonShape2D":
			var pol:ConvexPolygonShape2D = shape;
			var polygon:Polygon2D = Polygon2D.new();
			polygon.polygon = pol.points
			polygon.name = "shape";
			current_aoe_projection.add_child(polygon)
			
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

var applied_animations:Array[AnimationType]=[]

func generate_aoe_animation(type:AnimationType)->void:

	if type in applied_animations:return
	applied_animations.append(type)
	var lib:AnimationLibrary = get_animation_library("projection")
	var animation:Animation = lib.get_animation("projection");
	
	match type:
		AnimationType.flat:
			var track:int = animation.add_track(Animation.TYPE_VALUE)
			var target:Node2D = current_aoe_projection;
			var path:String = get_node(root_node).get_path_to(target)

			animation.track_set_path(track, path+":modulate:a");
			animation.track_insert_key(track, 0, 0.0)
			animation.track_insert_key(track, .16, .75);
			animation.track_insert_key(track, .4, .3);
			animation.track_insert_key(track, .65, .75);
			animation.track_insert_key(track, .66, 0.0);
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
		AnimationType.directional:

			var track:int = animation.add_track(Animation.TYPE_VALUE);
			var expansion:Node2D = current_aoe_projection.get_node("shape").get_node("expansion");

			var path:String = get_node(root_node).get_path_to(expansion);
			if expansion is Polygon2D:
				animation.track_set_path(track, path+":scale");
				animation.track_insert_key(track, 0, Vector2.ZERO);
				animation.track_insert_key(track, .65, Vector2.ONE);
			else:
				animation.track_set_path(track, path+":scale:x")
				animation.track_insert_key(track, 0, 0.0);
				animation.track_insert_key(track, .65, 1.0);

func generate_knockback_projection()->void:
	## just loosely redoes the reference when refreshing
	## since previous one will be deleted on refresh
	knockback_projection = TextureRect.new();
	knockback_projection.size = Vector2(256, 2);
	knockback_projection.texture = knockback_gradient.duplicate();
	knockback_projection.modulate.a = 0;
	knockback_projection.name = "knockback_projection"
	
	var arrow:TextureRect = TextureRect.new();
	arrow.texture = knockback_arrow;
	arrow.position = Vector2(200, -14)
	arrow.name = "arrow"
	arrow.size = knockback_arrow.get_size()
	arrow.modulate.a = .5;
	arrow.modulate.v = .8
	knockback_projection.add_child(arrow)
	
	var container:Node2D = Node2D.new()
	container.scale.x = source.skill.knockback_strength/5.0
	
	container.name = "kncokback_projection"
	container.add_child(knockback_projection)
	add_element(container, source);

func generate_knockback_animation()->void:
	var lib:AnimationLibrary = get_animation_library("projection")
	var animation:Animation = lib.get_animation("projection");
	
	var track:int = animation.add_track(Animation.TYPE_VALUE);
	var path:String = get_node(root_node).get_path_to(knockback_projection);
	
	animation.track_set_path(track, path+":scale:x");
	animation.track_insert_key(track, 0, 0.0);
	animation.track_insert_key(track, .65, 1.0)
	animation.track_insert_key(track, .655, 0.0)
	
	track = animation.add_track(Animation.TYPE_VALUE);
	animation.track_set_path(track, path+":modulate:a");
	animation.track_insert_key(track, 0, 0.0);
	animation.track_insert_key(track, .65, 1.0)
	animation.track_insert_key(track, .655, 0.0)

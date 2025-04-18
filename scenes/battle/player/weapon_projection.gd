extends Node2D;

@export var current_weapon:Weapon;
var projection_draw_fn:Callable=no_projection;
@onready var default_position = position;

const projection_color:Color = Color(.5, .5, .5, .3)

func _ready():
	current_weapon = Entities.player.equipped_weapon;
	set_weapon_projection()

func _draw():
	projection_draw_fn.call()

func no_projection()->void:
	pass

func set_weapon_projection()->void:
	scale = Vector2(1, 1)
	position = default_position;
	match current_weapon.projection:
		"melee_swing":
			projection_draw_fn = melee_swing_projection
		"gun_shot":
			projection_draw_fn = shoot_projection;
		"cone_aoe":
			projection_draw_fn = cone_projection
		"circle_aoe":
			projection_draw_fn = circle_aoe_projection
		"none":
			projection_draw_fn = no_projection
	queue_redraw()

func _on_equipment_weapon_equipped(weapon: Weapon) -> void:
	current_weapon = weapon;
	set_weapon_projection()
	
func melee_swing_projection()->void:
	draw_arc(Vector2(0, 0), 40, -1.5, 1.5, 100, projection_color, 10 );

func shoot_projection()->void:
	draw_line(Vector2(0, 0), Vector2(2000, 0), projection_color, 5);

func cone_projection()->void:
	var polygon:PackedVector2Array = current_weapon.cone.polygon.polygon;
	scale = current_weapon.cone.scale
	position.x += 80
	draw_polygon(polygon, [projection_color]);

func circle_aoe_projection()->void:
	var weapon = Entities.in_fight_player.equipment.weapon;
	draw_circle(Vector2.ZERO, weapon.aoe_radius, projection_color);

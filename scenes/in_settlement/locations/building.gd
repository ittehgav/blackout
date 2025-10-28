extends Location;
## building will not be all-encopassing enough a word i thinks but its fine for now
class_name Building




## size = thirds of the space the building takes up, a size 3 bulding
## always takes up the whole settlement

## theres gotta be a cleaner way to do this?
@export var front_porch_scene:PackedScene
## FRONT PORCH IS THE DEFAULT INTERIOR
@export var arena_layout_scene:PackedScene
## some (if not most buildings) will just not have inventories or roster, if they
## have no operations that need them to have one;
@export var inventory:ShopInventory;
@export var roster:BuildingRoster;
@export_enum("mechanic", "bodybuilder", "scientist") var evolve_option:String;



func refresh()->void:
	pending_refresh = false;
	refresh_stores()

func refresh_stores()->void:
	if inventory:
		inventory.refresh_inventory();
	if roster:
		roster.refresh_recruits();


func accepts_trade(item:Item)->bool:
	## overrideable
	return item is ResourceContainer;

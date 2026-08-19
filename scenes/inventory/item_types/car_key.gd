@icon("res://assets/visual/editor_ui/IconGodotNode/node_2D/icon_key.png")
class_name CarKey;
extends Item

## CARS:
## (for this implementation)
## rare tiny items that are the keys to cars
## when you get a car you get that much inventory and party space
## when selling or discarding a key get a warning for the losses
## very first car player gets is relatively good
## cars are also what defines hourly fuel cost
## dont even show anything besides the key and the
## effects of them being in the inventory for now

@export var cargo_space:int;
## always a multiplier of 12 so it just adds rows and doesnt mess up the inventory grid
## can eventually add unique spaces 
@export var party_space:int;
@export var fuel_cost:int; 
## FOR EVERY 30 MINUTES

const rarity = 3;

extends Node

class_name SettlementSettings;

@export_subgroup("Basic Features")
@export var trade:bool=true;
@export var recruit_units:bool=true;
@export var listen_around:bool=true;


@export_subgroup("Resource Production")
@export_range(0, 10) var food_production:int;
@export_range(0, 10) var fuel_production:int;


@export_range(0, 10) var juice_production:int;
@export_range(0, 10) var scrap_production:int;
@export_range(0, 10) var chips_production:int;

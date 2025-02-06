extends Node

class_name SettlementSettings;

@export_subgroup("Settlement Data")
@export var faction:String;
@export_range(1.0,5.0) var economy_level:float;
@export_range(1.0, 5.0) var military_level:float;


@export_subgroup("Basic Features")
@export var trade_resources:bool=true;
@export var trade_items:bool = true;
@export var recruit_units:bool=true;
@export var listen_around:bool=true;


@export_subgroup("Resource Production")
@export_range(0, 10) var food_production:int;
@export_range(0, 10) var fuel_production:int;


@export_range(0, 10) var juice_production:int;
@export_range(0, 10) var scrap_production:int;
@export_range(0, 10) var chips_production:int;

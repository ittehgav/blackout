extends Node

@export_subgroup("Settlement Data")
@export var faction:String;
@export_range(1.0,5.0) var economy_level:float;
@export_range(1.0, 5.0) var military_level:float;


@export_subgroup("Basic Features")
@export var resource_trading:bool=true;
@export var recruit_hiring:bool=true;
@export var listen_around:bool=true;


@export_subgroup("Resource Production")
@export_range(0, 10) var food_production:int=3;
@export_range(0, 10) var juice_production:int=3;
@export_range(0, 10) var scrap_production:int=3;
@export_range(0, 10) var fuel_production:int=3;

extends Node


class_name TradeAnomaly;
## trade anomalies are shifts in values on items
## more often than not HIGH IMPACT AND POTENTIALLY WORTHWHILE FOR THE PLAYER TO GO THERE

## for now, simply reduces or increases the supply of a random resource and updates
## the buy/sell price (overadjusts a bit)

var target:Settlement;
var resource:String;
var change:float;
var positive:bool;

const intensity_breakpoints:Array[float] = [2.5, 4]


func generate(settlement:Settlement)->void:
	## roll = 10 - 100% increase or decrese in stock of item
	## CHANGE:
	## may apply to places where the target resource is not for sale,
	## place still buys it for the affected value
	## and can sell it also with the applied change until the end of the day
	## positive: stock *= change, price /= change
	## negative: stock /= change, price *= change
	target = settlement
	change = snapped(randf_range(1.5, 5), .01);
	positive = randf_range(0,1)>.5;
	resource = Index.all_resources.filter(func(r:String)->bool:return r != "money").pick_random();

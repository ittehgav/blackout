extends Memo

## trade anomalies are shifts in values on items
## ALWAYS HIGH IMPACT AND POTENTIALLY WORTHWHILE FOR THE PLAYER TO GO THERE

## for now, simply reduces or increases the supply of a random resource and updates
## the buy/sell price (overadjusts a bit)
class_name TradeAnomaly;

var duration:int;

var resource:String;
var change:float;
var positive:bool;


var anomaly:Dictionary;

func generate():
	## roll = 10 - 100% increase or decrese in stock of item
	change = snapped(randf_range(0, .9), .1);
	positive=randf_range(0,1)>.5;
	resource = ["food", "fuel", "juice", "scrap", "chips"].pick_random();

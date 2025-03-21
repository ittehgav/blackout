extends Memo

## trade anomalies are shifts in values on items
## ALWAYS HIGH IMPACT AND POTENTIALLY WORTHWHILE FOR THE PLAYER TO GO THERE

## for now, simply reduces or increases the supply of a random resource and updates
## the buy/sell price (overadjusts a bit)
class_name TradeAnomaly;

var duration:int;

var target:Settlement;
var resource:String;
var change:float;
var positive:bool;


var anomaly:Dictionary;

func generate(settlement:Settlement):
	## roll = 10 - 100% increase or decrese in stock of item
	target = settlement;
	change = snapped(randf_range(0, .9), .1);
	positive = randf_range(0,1)>.5;
	resource = ["food", "fuel", "juice", "scrap", "chips"].pick_random();


func generate_description()->String:
	var positive_event_highlight_color = "[color=" + Color.GREEN.to_html()+ "]"
	var negative_event_highlight_color = "[color=" + Color.RED.to_html() + "]";
	var string:String = "[color=light_blue]" + target.name + "[/color]"
	
	if positive:
		if change < .3:
			string += " has a"+positive_event_highlight_color + " Slight Surplus[/color] of "\
			 + Meta.resource_colored_name(resource) + "[/color] and is selling it for"+positive_event_highlight_color + " cheaper than usual.";
		elif change < .7:
			string += " has a"+ positive_event_highlight_color + " Surplus[/color] of "\
			+ Meta.resource_colored_name(resource) + "[/color] and prices are"+positive_event_highlight_color+" much lower!"
		else:
			string += " has a"+ positive_event_highlight_color + " Massive Surplus[/color] of "\
			+ Meta.resource_colored_name(resource) + "[/color] and prices are" + positive_event_highlight_color + " drastically lower!"
	else:
		if change < .3:
			string += " has a"+negative_event_highlight_color + " Slight Shortage[/color] of "\
			 + Meta.resource_colored_name(resource) + "[/color] and is buying it for"+negative_event_highlight_color + " more than usual.";
		elif change < .7:
			string += " has a"+ negative_event_highlight_color + " Shortage[/color] of "\
			+ Meta.resource_colored_name(resource) + "[/color] and prices are"+negative_event_highlight_color+" much higher!."
		else:
			string += " has a"+ negative_event_highlight_color + " Massive Shortage[/color] of "\
			+ Meta.resource_colored_name(resource) + "[/color] and prices are" + negative_event_highlight_color + " drastically higher!"
	return string

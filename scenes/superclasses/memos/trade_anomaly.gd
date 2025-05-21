extends Memo

## trade anomalies are shifts in values on items
## ALWAYS HIGH IMPACT AND POTENTIALLY WORTHWHILE FOR THE PLAYER TO GO THERE

## for now, simply reduces or increases the supply of a random resource and updates
## the buy/sell price (overadjusts a bit)
class_name TradeAnomaly;


var target:Settlement;
var resource:String;
var change:float;
var positive:bool;



func generate(settlement:Settlement)->void:
	## roll = 10 - 100% increase or decrese in stock of item
	## 	CHANGE:
	## positive: stock *= change, price /= change
	## negative: stock /= change, price *= change
	target = settlement;
	change = snapped(randf_range(1, 3), .1);
	positive = randf_range(0,1)>.5;
	resource = Index.all_resources.filter(func(r:String)->bool:return r != "money").pick_random();
	generate_gossip_string();



func generate_gossip_string()->void:
	var positive_event_highlight_color: = "[color=" + Color.GREEN.to_html()+ "]"
	var negative_event_highlight_color: = "[color=" + Color.RED.to_html() + "]";
	var string:String = Index.tagged_settlement_name(target)
	
	var breakpoints:Array[float] = [1.5, 2.5];
	if positive:
		if change < breakpoints[0]:
			string += " has a "+positive_event_highlight_color + "Slight Surplus[/color] of "\
			 + Index.resource_colored_name(resource) + " and is selling it for "+positive_event_highlight_color + "cheaper than usual.";
		elif change < breakpoints[1]:
			string += " has a"+ positive_event_highlight_color + " Surplus[/color] of "\
			+ Index.resource_colored_name(resource) + " and prices are "+positive_event_highlight_color+"much lower!"
		else:
			string += " has a"+ positive_event_highlight_color + " Massive Surplus[/color] of "\
			+ Index.resource_colored_name(resource) + " and prices are " + positive_event_highlight_color + "drastically lower!"
	else:
		if change < breakpoints[0]:
			string += " has a"+negative_event_highlight_color + " Slight Shortage[/color] of "\
			 + Index.resource_colored_name(resource) + " and is buying it for "+negative_event_highlight_color + "more than usual.";
		elif change < breakpoints[1]:
			string += " has a"+ negative_event_highlight_color + " Shortage[/color] of "\
			+ Index.resource_colored_name(resource) + " and prices are "+negative_event_highlight_color+"much higher!"
		else:
			string += " has a"+ negative_event_highlight_color + " Massive Shortage[/color] of "\
			+ Index.resource_colored_name(resource) + " and prices are " + negative_event_highlight_color + "drastically higher!"
	gossip = string;

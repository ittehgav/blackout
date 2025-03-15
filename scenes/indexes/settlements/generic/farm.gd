extends Settlement

class_name Farm

const settlement_type_name = "Farm"
const sub_name = "Farm"
var description:String = "Produces and trades " + Meta.get_color_tag("food") + "Food[/color] and some"+Meta.get_color_tag("fuel") +" Fuel[/color]."
var flavor:String = "Settlement formed around patches of fertile land.\nVery little of "+ Meta.get_color_tag("blackout")  + "Pre-Blackout[/color] farming technology is properly understood, yet the demand for food remains ever-growing.";

extends Settlement

class_name Farm

const settlement_type_name = "Farm"
const sub_name = "Farm"
var description:String = "Produces and trades " + Index.resource_colored_name("food") + \
" and some "+Index.resource_colored_name("fuel") +"."
var flavor:String = "Settlement formed around patches of fertile land.\nVery little of "+ Index.get_color_tag("blackout")\
+ "Pre-Blackout[/color] farming technology is properly understood, yet the demand for food remains ever-growing.";

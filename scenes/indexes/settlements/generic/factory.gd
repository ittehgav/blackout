extends Settlement

class_name Factory

const settlement_type_name = "Factory"
const sub_name = "Factory"
var description: String = "Produces and trades mostly " + Index.resource_colored_name("fuel") + ","\
+ Index.resource_colored_name("juice") + " and "+Index.resource_colored_name("scrap") + ".";
var flavor:String = "Region full of manufacturing machinery from "+Index.get_color_tag("blackout") + "Pre-Blackout Civilization[/color], repurposed for production of mechanical and chemical goods.";

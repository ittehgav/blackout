extends LocalEvent;

const action_prompt = "Purchase the mysterious artifact for your party's [u]Cyborgs[/u]";


func generate()->void:
	description = "A merchant in " + location.name + " is selling a mysterious artifact of " + Index.get_color_tag("blackout")+\
	"Pre-Blackout technology[/color], you can " + Index.get_color_tag("money") + \
	"purchase[/color] it for the [u]cyborgs[/u] in your party, [u]greatly improving their stats[/u] and salvaging some " + Index.resource_colored_name("chips") + " from it.";

	gossip = "A merchant in " + Index.tagged_settlement_name(location)\
	 + " is selling a [u]Mysterious Artifact[/u] that can greatly improve the power of [u]cyborgs[/u].";
	
	setup_action_prompt()

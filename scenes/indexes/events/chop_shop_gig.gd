extends LocalEvent;

const action_prompt = "Send your party's [u]Mechanics[/u] to work at the Chop Shop";


func generate()->void:
	description = "The Chop Shop in " + location.name + " is understaffed, you can have the [u]mechanics[/u] in your party work there, gaining some " +\
	Index.resource_colored_name("money") + " and " + Index.resource_colored_name("scrap") + ", as welll as [u]improving some of their stats[/u].";

	gossip = Index.tagged_settlement_name(location) + " is looking for [u]mechanics[/u] to work on the [u]chop shop[/u] in exchange for "\
	+Index.resource_colored_name("money") + " and " + Index.resource_colored_name("scrap") + ".";
	
	setup_action_prompt()
	

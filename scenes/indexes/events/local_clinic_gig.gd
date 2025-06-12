extends LocalEvent

const action_prompt = "Send your party's [u]Doctors[/u] to work in the clinic";

func generate()->void:
	
	description = "The medical clinic in " + location.name + " is understaffed, you can have the [u]doctors[/u] in your party work part-time there to gain some "+\
	Index.resource_colored_name("money") + " and [u]slightly improve their stats[/u].";

	gossip = Index.tagged_settlement_name(location) + " is looking for [u]doctors[/u] to work on their clinic in exchange for " + \
	Index.resource_colored_name("money") + "."
	
	setup_action_prompt()
	

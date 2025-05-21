extends LocalEvent;

const action_prompt = "Send your party's [u]Juggernauts[/u] to work for the festival";

func generate()->void:
	description = location.name + " is holding a festival and is looking for people to work on security, you can have the [u]juggernauts[/u] in your party work there to gain some "+\
	Index.resource_colored_name("money") + " and [u]slightly improve stats[/u].";

	gossip = Index.tagged_settlement_name(location) + " is looking for [u]Juggernauts[/u] to work as security on a festival in exchange for "\
	+ Index.resource_colored_name("money") + ".";

	setup_action_prompt()

extends LocalEvent

const action_prompt = "Send your party's [u]Hunters[/u] in the expedition";

func generate()->void:
	description = "A crew in " + location.name + " is gathering [u]hunters[/u] for an expedition, you can send in your party's [u]hunters[/u] to gain a lot of "+\
	Index.resource_colored_name("food") + " and to [u]slightly improve their stats[/u].";

	gossip = Index.tagged_settlement_name(location) + " is organizing a caravan for [u]hunters[/u] to gather " + Index.resource_colored_name("food") + "."

	setup_action_prompt()

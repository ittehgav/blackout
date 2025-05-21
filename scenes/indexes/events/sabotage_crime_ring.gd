extends LocalEvent

const action_prompt = "Send your [u]Disruptors[/u] to sabotage the crime ring";

func generate()->void:
	description = location.name + " is being extortioned and terrorized by a local crime ring, you may send the [u]disruptors[/u] in your party to sabotage their operation, gaining " +\
	Index.resource_colored_name("money") + " and [u]slightly improving their stats[/u]."

	gossip = "There's a crime ring in " + Index.tagged_settlement_name(location) + " that could be sabotaged by [u]disruptors[/u] for "\
	+ Index.resource_colored_name("money") + "."
	
	setup_action_prompt()

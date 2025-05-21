extends LocalEvent;

const action_prompt = "Sign up your party's [u]Brawlers[/u] in the fighting tournament";


func generate()->void:
	description = location.name + " is hosting a fighting tournament, you can sign up [u]brawlers[/u] from your party to gain "\
	 + Index.resource_colored_name("money") + " and [u]improve their stats[/u].";

	gossip = Index.tagged_settlement_name(location) + " is holding a fighting tournament for where [u]brawlers[/u] can fight for "\
	+ Index.resource_colored_name("money") + ".";
	
	setup_action_prompt()

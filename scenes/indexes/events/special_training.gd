extends LocalEvent;

const action_prompt = "Take special [u]bodybuilder[/u] training";

func generate()->void:
	description= "A famous personal trainer is in " + location.name + ", you can sign up the [u]bodybuilders[/u] in your party for a "+\
	Index.get_color_tag("money") + "fee[/color] and give them special training, [u]greatly improving their stats[/u].";

	gossip = "There's a famous personal trainer in "+ Index.tagged_settlement_name(location) + " offering training for [u]Bodybuilders[/u] for a "\
	+ Index.get_color_tag("money") + "fee[/color], greatly imroving their [u]stats[/u]."

	setup_action_prompt()

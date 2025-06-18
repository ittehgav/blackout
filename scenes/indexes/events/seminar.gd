extends LocalEvent;

const action_prompt = "Have your party's [u]Scientists[/u] attend the seminar"

func generate()->void:
	description= location.name + " is hosting a seminar, you can have the [u]scientists[/u] in your party attend it for a "+\
	Index.get_color_tag("money") + "fee[/color], greatly imrpving their " + Index.stat_colored_name("technique")+".";

	gossip = Index.tagged_settlement_name(location) + " is hosting a seminar where [u]Scientists[/u] can greatly improve their "\
	+ Index.stat_colored_name("technique") + " for a " + Index.get_color_tag("money") + "fee[/color].";

	setup_action_prompt()

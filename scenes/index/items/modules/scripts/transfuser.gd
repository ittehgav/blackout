extends Module

const rairity = 2;
func get_description()->String:
	return "Use to drain HP from the highest HP ally in the party to the lowest HP ally in the party. (may include you)"


const m1_description = "-50% HP removed from highest HP ally.";
const m1_prefix = "Considerate";

const m2_description = "Healing is applied to the 2 lowest HP allies.";
const m2_prefix = "Collectivized"

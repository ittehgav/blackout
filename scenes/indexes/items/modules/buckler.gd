extends Module;

const rarity = 1;

const cooldown = 5;

const description = "Hold to slow movement and take 80% less damage, if you get hit by an enemy immediately after activating Buckler, the enemy becomes stunned for 5 seconds.";

func use()->void:
	print("moduluse ", name)

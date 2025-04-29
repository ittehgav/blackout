extends Consumable;

const rarity = 1;

const description = "Use to gain 5 - 100 food. Likely worth more money while still in the package."

var use_message:String;

func use()->bool:
	var roll:int = randi_range(5, 100);
	Entities.player.inventory.food += roll;
	Entities.player.resource_changed.emit("food", roll);
	use_message = "Gained " + str(roll) + " food!";
	return true;
	

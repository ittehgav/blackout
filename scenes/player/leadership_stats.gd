extends Node

class_name LeadershipStats

@export var charisma:int;
@export var navigation:int;
@export var tactics:int;
@export var logistics:int;

const all_leadership_stats = ["charisma", "navigation", "tactics", "resource_management"]

var trading_traits = [
	"Each level of the charisma skill allows you to sell items for 10% more and buy items for 10% less.",
	"When trading with faction-affiliated traders, gain twice as much relation with that faction.",
	"Allows you to pay a fee to traders to refresh their item inventories once per day.",
	""
] 

const charisma_tooltip = "Charisma improves your trading ability and the rate at which your relationships with factions improve."
const navigation_tooltip = "Navigation improves the speed at which you move in the world map, as well as your line of sight.";
const tactics_tootlip = "Tactics improves the morale management of your party and unlocks special tactical abilities that can be used during combat.";
const logistics_tooltip = "Logistics improves your resource management, reducing upkeep costs and allowing for more resource-efficient navigating.";

extends Trader;

class_name ResourceTrader

## will implement functions for farms/gas stations 
## (and probabty other generic forms eventually)
## can be used alone or with additional functionalities with more scripting
## and/or building generic functionalities

@export var to_trade:Dictionary[String,bool]={
	"food":false,
	"fuel":false,
	"juice":false,
	"scrap":false,
	"chips":false
}

func day_passed()->void:
	daily_reset.emit();
	apply_trade_anomaly();


func apply_trade_anomaly()->void:
	var a:TradeAnomaly = get_parent();

	if a.positive:
		## POSITIVE ANOMALY = SURPLUS = STOCK UP PRICE DOWN
		inventory.resource_buying_prices[a.resource] /= a.change;
		inventory.resource_selling_prices[a.resource] /= a.change
		if inventory[a.resource]:
			inventory[a.resource] *= a.change
	else:
		## NEGATIVE ANOMALY = SHORTAGE = STOCK DOWN PRICE UP
		inventory.resource_buying_prices[a.resource] *= a.change;
		inventory.resource_selling_prices[a.resource] *= a.change
		if inventory[a.resource]:
			inventory[a.resource] /= a.change
	
func accepts_trade(item:Item)->bool:
	## overrideable
	return item is ResourceContainer;

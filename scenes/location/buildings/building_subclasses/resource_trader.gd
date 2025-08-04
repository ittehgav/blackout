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



func accepts_trade(item:Item)->bool:
	## overrideable
	return item is ResourceContainer;

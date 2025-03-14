extends Node

const gendered_settlement_adjacent_names:Array[String] = [
	## the space being in the end or at the start is what determines whether
	## they're suffixes or prefixes
	## change letters based on word genders
	## by default they're female
	" Nova",
	" Velha",
	"Santa ",
	"Querida ",
	" Amada"
	
	
]

const non_gendered_settlement_adjacent_names:Array[String] = [
	" do Sul",
	" do Norte",
	" de Deus",
	" Grande",
	" das Dores",
	" da Verdade"
]

const male_settlement_main_names:Array[String] = [
	"Porto",
	"Rio",
	"Espírito",
	"Santo",
	"Lago",
	"Jesus"
]

const female_settlement_main_names:Array[String] = [
	"Petrópolis",
	"Maria",
	"Terra",
	"Aparecida",
	"Maria"
]

func generate_name()->String:
	var main_name_pool:Array[String] = male_settlement_main_names + female_settlement_main_names;
	var main_name:String = main_name_pool.pick_random();
	
	var adjacent_name_pool:Array[String] = gendered_settlement_adjacent_names + non_gendered_settlement_adjacent_names;
	var adjacent_name:String = adjacent_name_pool.pick_random();
	
	if main_name in male_settlement_main_names and adjacent_name in gendered_settlement_adjacent_names:
		var to_switch:int = adjacent_name.rfind("a");
		adjacent_name[to_switch] = "o";
	
	if adjacent_name[0] == " ":
		return main_name + adjacent_name;
	else:
		return adjacent_name + main_name
		

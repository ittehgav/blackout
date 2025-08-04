extends Node

const gendered_settlement_adjacent_names:Array[String] = [
	## the space being in the end or at the start is what determines whether
	## they're suffixes or prefixes
	## change letters based on word genders
	## by default they're female
	"Nova ",
	" Velha",
	"Santa ",
	" Amada",
	" Segura",
	" Bela",
]

const non_gendered_settlement_adjacent_names:Array[String] = [
	" do Sul",
	" do Norte",
	" Grande",
	" das Dores",
	" da Verdade",
	" de São Pedro",
	" de São Jorge",
	" de Todos os Santos",
	" de Cima"
]

const male_settlement_main_names:Array[String] = [
	"Porto",
	"Rio",
	"Espírito",
	"Santo",
	"Lago",
	"Arroio",
	"Passo",
	"Rosário",
	"Campo",
	"Duque",
	"Ribeirão",
	"Iguatu",
	"Jaburu",
	"Ouro",
	"Monteiro",
	"Estreito",
	"Cacique",
	"Itaquara",
	"Horizonte",
	"Ribeirão"
]

const female_settlement_main_names:Array[String] = [
	"Redenção",
	"Petrópolis",
	"Maria",
	"Terra",
	"Aparecida",
	"Maria",
	"Nazaré",
	"Iemanjá",
	"Palmeira",
	"Chapada",
	"Ressaca",
	"Formosa",
	"Iracema",
	"Vila",
	"Alvorada",
	"Taquara",
	"Bahia"
]

## only really matters when generating the names for the first time
## only names are randomzied when creating new save file?
var taken_names:Array[String] = [];

func generate_name()->String:
	var new_name:String;
	while not new_name or new_name in taken_names:
		var main_name_pool:Array[String] = male_settlement_main_names + female_settlement_main_names;
		var main_name:String = main_name_pool.pick_random();
		
		var adjacent_name_pool:Array[String] = gendered_settlement_adjacent_names + non_gendered_settlement_adjacent_names;
		var adjacent_name:String = adjacent_name_pool.pick_random();
		
		if main_name in male_settlement_main_names and adjacent_name in gendered_settlement_adjacent_names:
			var to_switch:int = adjacent_name.rfind("a");
			adjacent_name[to_switch] = "o";
		
		if adjacent_name[0] == " ":
			new_name = main_name + adjacent_name;
		else:
			new_name = adjacent_name + main_name
	taken_names.append(new_name);
	return new_name
		

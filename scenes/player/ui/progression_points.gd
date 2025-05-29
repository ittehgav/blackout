extends HBoxContainer

@export var acquired_branch_texture:Texture;
@export var available_branch_texture:Texture;
@export var unavailable_branch_texture:Texture;

var skill_btns:Array[Button]=[];
var skill_separators:Array[TextureRect]=[];

func _ready()->void:
	for c in get_children():
		if c is Button:
			skill_btns.append(c);
		elif c is TextureRect:
			skill_separators.append(c)

func refresh_data(stat:String)->void:
	var skill_level:int = Entities.player.leadership_stats[stat];
	for i in skill_level:
		if i:
			skill_separators[i-1].modulate = Color.DARK_GREEN;
			skill_separators[i-1].texture = acquired_branch_texture
		skill_btns[i].modulate = Color.LIGHT_GREEN;
		skill_btns[i].disabled = true;
	
	if Entities.player.leadership_points >= skill_level:
		skill_btns[skill_level].disabled = false;
	else:
		skill_btns[skill_level].disabled = true;
		
	skill_separators[skill_level-1].modulate = Color.YELLOW;
	skill_separators[skill_level-1].texture = available_branch_texture
	skill_btns[skill_level].modulate = Color.YELLOW
	
	for i in range(skill_level+1, 5):
		if i > skill_level:
			skill_separators[i-1].modulate = Color(.05,.05,.05)
			skill_separators[i-1].texture = unavailable_branch_texture;
		var btn:Button = skill_btns[i];
		btn.modulate = Color(.2,0,0,.5)
		skill_btns[skill_level - i].disabled = true;

extends Leader

class_name Player;


## leadership skills will be a special tree that grants a special bonus at each level
## you can win leadership EXP by fighting (based on the amount of units is the party?)
## and by completing quests (auto-generated tasks from settlements?)
var leadership_level:int = 0;
var leadership_exp:int = 0;


## combat exp will be gained in parallel with leadership levels, 
## you win combat EXP when fighting
var combat_level:int = 0;
var combat_exp:int = 0;

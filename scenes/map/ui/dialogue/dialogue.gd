extends Node

class_name Dialogue;

var lines:Array[Array];

## dialogues branch out after prompt, where they can either
## simply end
## do functions that affect anything in the game
## start combats
## move on to other dialogues

const engage_outcome_text = "[color=red](Engage in battle)";
const yield_outcome_text = "[color=dark_red](Lose half of all Food, Money and Fuel)"

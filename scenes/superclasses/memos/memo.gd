extends Node

class_name Memo;

var registered:bool=false;
var register:Control;

var duration:int;
var time_left:int;
var expired:bool = false;

var expiration_day:int;
var expiration_month:int;

var gossip:String;

func register_memo()->void:
	## memos only expire when registered by the player?
	registered = true;
	duration = 2 + randi_range(0, 3);
	time_left = duration;
	Entities.player.new_memo.emit(self);
	## these are bound to settlements so their day passes will be bound to the settlements
	

func expire()->void:
	if registered:
		expired = true;
	else:
		free();
	

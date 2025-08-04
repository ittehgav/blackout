extends UIRoot;

@export var splash:TextureRect;


func _ready()->void:
	super();
	Entities.loading_screen = self;



func fade_in()->Tween:
	return Tweens.ui_fade_in(self);

func fade_out(_arg1:Variant = null, _arg2:Variant = null)->Tween:
	return Tweens.ui_fade_out(self, true, .75);
	
	

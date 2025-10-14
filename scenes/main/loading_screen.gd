extends UIRoot;

class_name LoadingScreen;
@export var splash:TextureRect;


func _ready()->void:
	super();
	Entities.loading_screen = self;



func show_splash()->Tween:
	return Tweens.ui_fade_in(self, .25);

func clear_splash(_arg1:Variant = null, _arg2:Variant = null)->Tween:
	return Tweens.ui_fade_out(self, true, .75);
	
	

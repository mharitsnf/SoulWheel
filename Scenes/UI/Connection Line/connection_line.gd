extends Line2D


func _ready():
	modulate.a = 0


func show():
	$Tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,1),
		0.35, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()


func hide():
	$Tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,0),
		0.35, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()

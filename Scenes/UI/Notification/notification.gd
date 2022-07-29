extends Label


export(Vector2) var offset
export(float) var duration

onready var tween = $Tween


func initialize(amount = 0):
	var text_sign = "+" if amount >= 0 else "-"
	text = text_sign + str(abs(amount)) + "HP"


func _ready():
	tween.interpolate_property(
		self, 
		"rect_position",
		rect_position, rect_position + offset,
		duration, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()
	
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(.2), "timeout")
	
	queue_free()

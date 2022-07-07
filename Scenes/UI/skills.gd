extends Control


export(float) var tween_speed : float

onready var btn_container = $MarginContainer/ButtonContainer


func initialize():
	for btn in btn_container.get_children():
		if btn is Button:
			btn.rect_size = Vector2(40, 40)
			btn.connect("pressed", Globals.player, "_on_skill_button_pressed", [btn.text])
	
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, -rect_size.y),
		tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")

func destroy():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, rect_size.y),
		tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	queue_free()

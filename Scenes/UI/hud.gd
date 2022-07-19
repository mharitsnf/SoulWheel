extends Control


onready var hp_label = $MarginContainer/Label


func _ready():
	Globals.hp_hud = self


func update_health(new_health):
	hp_label.text = "HP: " + str(new_health)


func move_down():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, Globals.hud_move_amount),
		Globals.hud_tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func move_up():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, -Globals.hud_move_amount),
		Globals.hud_tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")

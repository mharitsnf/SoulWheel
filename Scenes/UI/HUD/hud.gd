extends Control


onready var hp_label = $MarginContainer/Label


func _ready():
	Nodes.hp_hud = self


func set_health(new_health):
	hp_label.text = "HP: " + str(new_health)


func move_down():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, Configurations.skill_hud.move_amount),
		Configurations.skill_hud.tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func move_up():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, -Configurations.skill_hud.move_amount),
		Configurations.skill_hud.tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")

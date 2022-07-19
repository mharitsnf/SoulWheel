extends Control


onready var btn_container = $MarginContainer/ButtonContainer


func initialize(_skills):
	for skill in _skills:
		var btn = Button.new()
		btn.text = skill.name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_container.add_child(btn)
		btn.connect("pressed", Round.player, "_on_skill_button_pressed", [btn.get_index()])


func show():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, -Globals.hud_move_amount),
		Globals.hud_tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func hide_and_destroy():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, Globals.hud_move_amount),
		Globals.hud_tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	queue_free()

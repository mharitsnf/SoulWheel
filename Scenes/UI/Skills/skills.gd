extends Control


onready var btn_container = $MarginContainer/ButtonContainer


func initialize(_skills):
	for skill in _skills:
		var btn = Button.new()
		btn.text = skill.name
		btn.size_flags_horizontal = Control.SIZE_FILL
		btn_container.add_child(btn)
		btn.connect("pressed", Round.player, "_on_skill_button_pressed", [btn.get_index()])
		btn.connect("mouse_entered", Round.player, "_on_skill_button_mouse_entered", [skill])
		btn.connect("mouse_exited", Round.player, "_on_skill_button_mouse_exited", [skill])


func disconnect_signals():
	for btn in btn_container.get_children():
		if btn is Button:
			btn.disconnect("mouse_entered", Round.player, "_on_skill_button_mouse_entered")
			btn.disconnect("mouse_exited", Round.player, "_on_skill_button_mouse_exited")


func show():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, -Configurations.skill_hud.move_amount),
		Configurations.skill_hud.tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func hide_and_destroy():
	$Tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + Vector2(0, Configurations.skill_hud.move_amount),
		Configurations.skill_hud.tween_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	queue_free()

extends Control


onready var tween = $Tween
onready var button_container = $HBoxContainer

var offset = Vector2(0, 60)


func initialize(skills):
	for i in range(button_container.get_child_count()):
		var slot = skills[i]
		var button : Button = button_container.get_child(i)
		
		if slot.skill != null:
			button.text = slot.skill.name
		
		else:
			button.disabled = true
		
		var _e = button.connect(
			"pressed", 
			Round.player_manager, 
			"_on_skill_selection_pressed", 
			[slot, button.get_index()]
		)
	
	_show()
	
	yield(tween, "tween_completed")


func destroy():
	_hide()
	yield(tween, "tween_completed")
	queue_free()


func _hide():
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position + offset,
		0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,0),
		0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()


func _show():
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position - offset,
		0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,1),
		0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()

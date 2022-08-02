extends Control


onready var buttons_container = $ButtonsContaner
onready var tween = $Tween


func _init():
	rect_position = Vector2(-16, 30)
	modulate.a = 0


func initialize(slots):
	for i in range(buttons_container.get_children().size()):
		var slot_data = slots[i]
		var button : Button = buttons_container.get_child(i)
		
		if slot_data.possession:
			button.text = slot_data.possession.name
			
			match slot_data.possession.type:
				Possession.Types.ATTACK_SKILL: pass
				Possession.Types.SUPPORT_SKILL: pass
				Possession.Types.MODIFIER:
					button.disabled = true
		
		else:
			button.text = ""
			button.disabled = true
		
		var _e = button.connect("pressed", Round.player, "_on_skill_button_pressed", [button.get_index()])
	
	_show()
	
	yield(tween, "tween_completed")


func destroy():
	_hide()
	yield(tween,"tween_completed")
	queue_free()


func _hide():
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position + Vector2(0, 30),
		0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate", modulate, Color(1,1,1,0), 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()


func _show():
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position - Vector2(0, 30),
		0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate", modulate, Color(1,1,1,1), 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()

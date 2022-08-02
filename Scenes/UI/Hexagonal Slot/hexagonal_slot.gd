extends Control


export(PackedScene) var connection_line_scn

onready var buttons_container = $ButtonsContaner
onready var lines_container = $LinesContainer
onready var tween = $Tween


func _init():
	rect_position = Vector2(-16, 30)
	modulate.a = 0


func initialize(slots):
	var all_line_indexes = [[], [], [], [], [], []]
	
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
			
			for connected_to in slot_data.affected_by:
				var line = connection_line_scn.instance()
				var offset = Vector2(20, 20)
				var next_button = buttons_container.get_child(connected_to)
				
				line.add_point(button.rect_position + offset)
				line.add_point(next_button.rect_position + offset)
				lines_container.add_child(line)
				
				all_line_indexes[i].append(line.get_index())
				all_line_indexes[connected_to].append(line.get_index())
		
		else:
			button.text = ""
			button.disabled = true
		
		var _e = button.connect("pressed", Round.player, "_on_skill_button_pressed", [button.get_index()])
	
	
	for i in range(all_line_indexes.size()):
		var line_indexes = all_line_indexes[i]
		var button = buttons_container.get_child(i)
		
		var _e = button.connect("mouse_entered", self, "_on_button_mouse_entered", [line_indexes])
		_e = button.connect("mouse_exited", self, "_on_button_mouse_exited", [line_indexes])
	
	_show()
	
	yield(tween, "tween_completed")


func destroy():
	for line in lines_container.get_children():
		line.hide()
	
	_hide()
	yield(tween,"tween_completed")
	queue_free()


func _on_button_mouse_entered(indexes):
	for idx in indexes:
		lines_container.get_child(idx).show()


func _on_button_mouse_exited(indexes):
	for idx in indexes:
		lines_container.get_child(idx).hide()


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

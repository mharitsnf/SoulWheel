extends Control


onready var title = $Title
onready var tween = $Tween
onready var use_btn = $UseButton
onready var back_btn = $BackButton
onready var info_btn = $InfoButton

var offset = Vector2(24, 0)


func _init():
	modulate.a = 0


func initialize(slot_data, btn_idx, direction):
	title.text = slot_data.possession.name
	
	use_btn.connect("pressed", Round.player_manager, "_on_skill_confirmed", [btn_idx])
	info_btn.connect("pressed", Round.player_manager, "_on_skill_info_pressed", [slot_data, btn_idx])
	back_btn.connect("pressed", Round.player_manager, "_on_skill_back_pressed", 
		[Round.player_manager.SKILL_CONFIRM, slot_data, btn_idx]
	)
	
	_show(direction)
	yield(tween, "tween_completed")


func destroy(direction):
	_hide(direction)
	yield(tween, "tween_completed")
	queue_free()


func _show(direction):
	tween.interpolate_property(
		self, "rect_position",
		rect_position + (direction * offset), rect_position,
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,1),
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()


func _hide(direction):
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position + (direction * offset),
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,0),
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()

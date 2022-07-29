extends Node


var shake_data = {
	"duration": 0.2,
	"frequency": 25,
	"amplitude": 4
}
var property = ""
var initial_value
var priority = 0
var shake_count = 0

onready var parent = get_parent()


func start(_property, _initial_value, _priority = 0, _shake_data = {}):
	if priority >= self.priority:
		property = _property
		initial_value = _initial_value
		priority = _priority
		
		if _shake_data.has("duration"):
			shake_data.duration = _shake_data.duration
		
		if _shake_data.has("frequency"):
			shake_data.frequency = _shake_data.frequency
		
		if _shake_data.has("amplitude"):
			shake_data.amplitude = _shake_data.amplitude
		
		$Duration.wait_time = shake_data.duration
		$Frequency.wait_time = 1 / float(shake_data.frequency)
		$Duration.start()
		$Frequency.start()
		
		_new_shake()


func _new_shake():
	var new_pos = initial_value
	if shake_count % 2 == 0: new_pos.x += shake_data.amplitude
	else: new_pos.x -= shake_data.amplitude
	
	$Tween.interpolate_property(
		parent,
		property,
		parent.get(property),
		new_pos,
		$Frequency.wait_time,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	$Tween.start()


func _reset():
	$Tween.interpolate_property(
		parent,
		property,
		parent.get(property),
		initial_value,
		$Frequency.wait_time,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	$Tween.start()
	
	shake_data = {
		"duration": 0.2,
		"frequency": 25,
		"amplitude": 4
	}
	property = ""
	initial_value = null
	priority = 0
	shake_count = 0


func _on_Frequency_timeout():
	shake_count += 1
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()

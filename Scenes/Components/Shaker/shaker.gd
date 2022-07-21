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


func start(property, initial_value, priority = 0, shake_data = {}):
	if priority >= self.priority:
		self.property = property
		self.initial_value = initial_value
		self.priority = priority
		
		if shake_data:
			self.shake_data = shake_data
		
		$Duration.wait_time = self.shake_data.duration
		$Frequency.wait_time = 1 / float(self.shake_data.frequency)
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

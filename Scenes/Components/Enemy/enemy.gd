extends Character
class_name Enemy


export var enemy_data_model : Resource

signal input_signal


func _ready():
	assert(enemy_data_model)
	assert(enemy_data_model is EnemyDataModel)

func play_turn():
	print("enemy playing")
	yield(self, "input_signal")

func get_soul_area_data():
	var data = []
	if enemy_data_model is EnemyDataModel:
		data = enemy_data_model.soul_areas
	return data

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("input_signal")

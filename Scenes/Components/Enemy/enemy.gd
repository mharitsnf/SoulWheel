extends Character


export var enemy_data_model : Resource

signal input_signal


func _ready():
	assert(enemy_data_model)
	assert(enemy_data_model is EnemyDataModel)

func play_turn():
	print("enemy playing")
	yield(self, "input_signal")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("input_signal")

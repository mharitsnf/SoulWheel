extends Character


export var player_data_model : Resource

signal input_signal


func _ready():
	assert(player_data_model)
	assert(player_data_model is PlayerDataModel)

func play_turn():
	print("player playing")
	yield(self, "input_signal")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("input_signal")

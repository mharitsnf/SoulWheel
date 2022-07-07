extends Node


func _ready():
	$TurnManager.initialize()
	$TurnManager.play_turn()

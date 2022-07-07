extends Node


func _ready():
	Globals.root = self
	$TurnManager.initialize()
	$TurnManager.play_turn()

extends Node


func _ready():
	Nodes.root = self
	$TurnManager.initialize()
	$TurnManager.play_turn()

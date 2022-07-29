extends Node


func _ready():
	Nodes.root = self
	Nodes.notification_container = $NotificationContainer
	
	$TurnManager.initialize()
	$TurnManager.play_turn()

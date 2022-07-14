extends Node2D
class_name TurnManager


var active_character : Character


func initialize():
	active_character = get_child(0)


func play_turn():
	var result = yield(active_character.play_turn(), "completed")
	
	if result:
		print(active_character, " wins!")
		return
	
	var new_index = (active_character.get_index() + 1) % get_child_count()
	active_character = get_child(new_index)
	
	if active_character is Enemy:
		print("enemy playing")
	
	play_turn()

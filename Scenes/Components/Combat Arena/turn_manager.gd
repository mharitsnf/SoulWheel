extends Node2D
class_name TurnManager


var active_character : Character


func initialize():
	
	# Add player to the tree
	var player : Player = Round.create_player_node()
	add_child(player)
	
	# Add enemies to the tree. Randomization
	# happens here, depending on the level
	var enemy1 = Round.create_enemy_node("res://Resources/Enemies/Enemy1.tres")
	var enemy2 = Round.create_enemy_node("res://Resources/Enemies/Enemy1.tres")
	add_child(enemy1)
	add_child(enemy2)
	
	# Set the player as the first one to move
	active_character = get_child(0)


func play_turn():
	# Let the active character moves
	var wins = yield(active_character.play_turn(), "completed")
	
	# If the current character wins, end the round.
	# Do certain stuff when the player/enemy wins.
	if wins:
		print(active_character, " wins!")
		return
	
	# Get the next character to play
	var new_index = (active_character.get_index() + 1) % get_child_count()
	active_character = get_child(new_index)
	
	# Play turn for the active character. Runs recursively until
	# somebody wins
	play_turn()

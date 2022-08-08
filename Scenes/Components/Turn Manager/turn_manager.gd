extends YSort
class_name TurnManager


var player_manager_scn = preload("res://Scenes/Components/Character Manager/Player Manager/PlayerManager.tscn")
var enemy_manager_scn = preload("res://Scenes/Components/Character Manager/Enemy Manager/EnemyManager.tscn")
var enemy_scn = preload("res://Scenes/Components/Enemy/Enemy.tscn")

var active_manager : CharacterManager
var turn_count = 0


func initialize():
	
	# Add player to the tree
	var player_manager = player_manager_scn.instance()
	add_child(player_manager)
	var player : Player = Round.create_player_node()
	player_manager.add_child(player)
	
	# Add enemies to the tree. Randomization
	# happens here, depending on the level
	var enemy_manager = enemy_manager_scn.instance()
	add_child(enemy_manager)
	for enemy_idx in range(2):
		var enemy = Round.create_enemy_node("res://Resources/Enemies/Enemy1.tres", enemy_idx)
		enemy_manager.add_child(enemy)
	
	# Run first turn setup for both managers
	player_manager.first_turn()
	enemy_manager.first_turn()
	
	# Set the player as the first one to move
	active_manager = get_child(0)


func play_turn():
	# Let the active character moves
	var wins = yield(active_manager.play_turn(), "completed")
	turn_count += 1
	
	# If the current character wins, end the round.
	# Do certain stuff when the player/enemy wins.
	if wins:
		print(active_manager, " wins!")
		return
	
	# Get the next character to play
	var new_index = (active_manager.get_index() + 1) % get_child_count()
	active_manager = get_child(new_index)
	
	# Play turn for the active character. Runs recursively until
	# somebody wins
	play_turn()

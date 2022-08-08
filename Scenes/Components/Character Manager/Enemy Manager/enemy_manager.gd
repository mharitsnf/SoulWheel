extends CharacterManager
class_name EnemyManager



# =============== Public functions ===============
func remove_defeated_enemies():
	for enemy in get_children():
		if enemy is Enemy and enemy.is_defeated:
			enemy.destroy()

# ================================================

# =============== Private functions ===============
func _ready():
	Round.enemy_manager = self

# =================================================

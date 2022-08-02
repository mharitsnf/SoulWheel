extends Resource
class_name EnemyDataModel

export(int) var max_health

# Array of array of dictionary. Each inner array has different behaviors and different areas.
# Purpose is to provide different pattern and behavior to the enemy.
export(Array) var defend_patterns
export(Array) var attack_patterns

export(GDScript) var behaviors


func _init():
	resource_local_to_scene = true

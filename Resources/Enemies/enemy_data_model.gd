extends Resource
class_name EnemyDataModel

export(int) var max_health

# Array of array of dictionary. Each inner array has different behaviors and different areas.
# Purpose is to provide different pattern and behavior to the enemy.
export(Array) var soul_areas
export(Array) var damage_areas

export(GDScript) var behaviors

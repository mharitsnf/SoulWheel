extends Resource
class_name EnemyDataModel

export var enemy_type : int
export var max_health : int
export var soul_areas : Array

onready var current_health = max_health

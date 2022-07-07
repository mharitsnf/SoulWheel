extends Node2D


export var enemy_data_model : Resource


func _ready():
	assert(enemy_data_model)
	assert(enemy_data_model is EnemyDataModel)

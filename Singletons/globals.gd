extends Node

var root : Node
var player : Player

var current_area = 1
var current_round = 1

var saved_areas = []
var saved_arrow = []

var skill_deck := []
var skill_resource_paths = {
	"attack1" : "res://Resources/Attack Skills/Attack1.tres",
	"attack2" : "res://Resources/Attack Skills/Attack2.tres"
}


func attack_loader(path : String):
	var ADM = load(path)
	var attack_object = {}
	
	if ADM is ArrowDataModel:
		attack_object.attack_type = ADM.attack_type
		attack_object.name = ADM.name
		attack_object.data = ADM.data.duplicate()
	
	return attack_object


func enemy_loader(enemy : Enemy):
	var EDM = enemy.enemy_data_model
	var enemy_object = {}
	
	enemy_object.node = enemy
	if EDM is EnemyDataModel:
		enemy_object.enemy_type = EDM.enemy_type
		enemy_object.name = enemy.name
		enemy_object.soul_areas = EDM.soul_areas.duplicate()
	
	return enemy_object


func generate_angles(rot_angle, thickness):
	var start_angle = fmod(-thickness + rot_angle, 360)
	var end_angle = fmod(thickness + 1 + rot_angle, 360)
	
	if start_angle < 0: start_angle += 360
	if end_angle < 0: end_angle += 360
	
	return Vector2(start_angle, end_angle)

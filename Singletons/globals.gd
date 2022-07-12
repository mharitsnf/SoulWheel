extends Node

var root : Node
var player : Player

var current_area = 1
var current_round = 1

var saved_areas = []
var saved_arrow = []

var skill_deck := []
var skill_resource_paths = {
	"basic": "res://Resources/Attack Skills/Basic.tres",
	"double": "res://Resources/Attack Skills/Double.tres",
	"trinity": "res://Resources/Attack Skills/Trinity.tres"
}


func attack_loader(path : String):
	var AS = load(path)
	return AS


func enemy_loader(enemy : Enemy):
	var dm = enemy.enemy_data_model
	var enemy_object = {}
	
	enemy_object.node = enemy
	enemy_object.dm = dm.duplicate(true)
	
	return enemy_object


func generate_angles(rot_angle, thickness):
	var start_angle = fmod(-thickness + rot_angle, 360)
	var end_angle = fmod(thickness + 1 + rot_angle, 360)
	
	if start_angle < 0: start_angle += 360
	if end_angle < 0: end_angle += 360
	
	if start_angle > end_angle: end_angle += 360
	
	return Vector2(start_angle, end_angle)

extends Node

var root : Node
var hp_hud : Control
var player : Player

var hud_move_amount = 56
var hud_tween_speed = 0.4

var current_area = 1
var current_round = 1

var saved_areas = []
var saved_damage_areas = []
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
	# Limit to -359 to 359
	var start_angle = fmod(-thickness + rot_angle, 360)
	var end_angle = fmod(thickness + 1 + rot_angle, 360)
	
	# Limit to 0 to 359
	if start_angle < 0: start_angle += 360
	if end_angle < 0: end_angle += 360
	
	# Handles when start angle > end angle
	if start_angle > end_angle: end_angle += 360
	
	return Vector2(start_angle, end_angle)

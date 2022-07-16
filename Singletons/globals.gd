extends Node

var root : Node
var hp_hud : Control
var player : Player

var hud_move_amount = 56
var hud_tween_speed = 0.4

var current_area = 1
var current_round = 1

var skill_deck := []
var skill_resource_paths = {
	"basic": "res://Resources/Attack Skills/Basic.tres",
}


func attack_loader(path : String):
	var AS : AttackSkill = load(path)
	AS.conditions_ins = AS.conditions.new()
	AS.behaviors_ins = AS.behaviors.new()
	return AS


func enemy_loader(enemy : Enemy):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var enemy_object = {}
	
	enemy_object.node = enemy
	enemy_object.dm = enemy.enemy_data_model.duplicate(true)
	
	enemy_object.dm.behaviors_ins = enemy_object.dm.behaviors.new()
	enemy_object.dm.soul_behavior_idx = rng.randi_range(0, enemy_object.dm.soul_areas.size() - 1)
	enemy_object.dm.damage_behavior_idx = rng.randi_range(0, enemy_object.dm.damage_areas.size() - 1)
	
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

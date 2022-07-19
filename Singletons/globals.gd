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
	"accelerate": "res://Resources/Attack Skills/Accelerate.tres",
}


func attack_loader(path : String):
	var AS : AttackSkill = load(path)
	AS.conditions_ins = AS.conditions.new()
	AS.behaviors_ins = AS.behaviors.new()
	return AS


func enemy_loader(enemy : Enemy):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var enemy_object = {
		"node": enemy
	}
	
	var tmp_dm = enemy.enemy_data_model.duplicate(true)
	tmp_dm.behaviors_ins = tmp_dm.behaviors.new()
	tmp_dm.soul_behavior_idx = rng.randi_range(0, tmp_dm.soul_areas.size() - 1)
	tmp_dm.damage_behavior_idx = rng.randi_range(0, tmp_dm.damage_areas.size() - 1)
	
	enemy_object.dm = tmp_dm
	
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

extends Node


var arrow_template = preload("res://Resources/Arrow/arrow.gd")
var enemy_node = preload("res://Scenes/Components/Enemy/Enemy.tscn")
var player_node = preload("res://Scenes/Components/Player/Player.tscn")

var player = null

var chosen_skill = null


func create_player_node() -> Player:
	var player : Player = player_node.instance()
	return player


func create_enemy_node(path_to_edm : String) -> Enemy:
	var edm = load_enemy_data_model(path_to_edm)
	
	var enemy : Enemy = enemy_node.instance()
	enemy.data_model_path = path_to_edm
	enemy.data_model = edm
	
	return enemy


func load_enemy_data_model(path_to_edm : String):
	var edm = load(path_to_edm).duplicate()
	
	# duplicate soul areas
	var soul_areas = []
	
	for phases in edm.soul_areas:
		var new_phase = []
		for area_path in phases:
			new_phase.append(load(area_path).duplicate())
		soul_areas.append(new_phase)
	
	edm.soul_areas = soul_areas
	
	# duplicate damage areas
	var damage_areas = []
	
	for phases in edm.damage_areas:
		var new_phase = []
		for area_path in phases:
			new_phase.append(load(area_path).duplicate())
		damage_areas.append(new_phase)
	
	edm.damage_areas = damage_areas
	
	# instantiate behavior
	edm.behaviors = edm.behaviors.new()
	
	return edm


func load_skill(path_to_skill : String):
	var skill = load(path_to_skill).duplicate()
	
	# create attack arrows
	var attack_arrows = []

	for phases in skill.attack_arrows:
		var new_phase = []
		for arrow in phases:
			new_phase.append(arrow_template.new(arrow.move_speed, arrow.rot_angle, arrow.thickness, arrow.damage))
		attack_arrows.append(new_phase)

	skill.attack_arrows = attack_arrows
	
	# create defend arrows
	var defend_arrows = []

	for phases in skill.defend_arrows:
		var new_phase = []
		for arrow in phases:
			new_phase.append(arrow_template.new(arrow.move_speed, arrow.rot_angle, arrow.thickness))
		defend_arrows.append(new_phase)

	skill.defend_arrows = defend_arrows
	
	# instantiate behaviors and conditions
	skill.conditions = skill.conditions.new()
	skill.behaviors = skill.behaviors.new()
	
	return skill

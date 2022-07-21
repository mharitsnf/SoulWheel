extends Node


enum WheelPhase {
	SOUL_LOCK,
	SOUL_STRIKE,
	DEFEND
}

var arrow_template = preload("res://Resources/Arrow/arrow.gd")
var area_template = preload("res://Resources/Area/area.gd")

var enemy_node = preload("res://Scenes/Components/Enemy/Enemy.tscn")
var player_node = preload("res://Scenes/Components/Player/Player.tscn")

var player = null

var chosen_skill = null


# Function for creating player node.
# Data model is not duplicated, so all the player information
# will stay there and will be saved if updated
func create_player_node() -> Player:
	var new_player : Player = player_node.instance()
	new_player.position = Nodes.root.get_node("Positions/Player").position
	return new_player


# Function for creating enemy node.
# Accepts path to data model as parameter.
# Data model should be duplicated, as the original
# should only act as the main template.
func create_enemy_node(path_to_edm : String, enemy_idx : int) -> Enemy:
	var edm = load_enemy_data_model(path_to_edm)
	
	var enemy : Enemy = enemy_node.instance()
	enemy.data_model_path = path_to_edm
	enemy.data_model = edm
	enemy.current_health = edm.max_health
	enemy.position = Nodes.root.get_node("Positions/Enemies").get_child(enemy_idx).position
	enemy.color = Configurations.enemy_colors[enemy_idx]
	enemy.radius = 72 - ((enemy_idx * 8))
	
	enemy.get_node("ColorRect").color = enemy.color
	
	return enemy


# Function for loading and duplicating the
# enemy data model.
func load_enemy_data_model(path_to_edm : String):
	var edm = load(path_to_edm).duplicate()
	
	# duplicate soul areas
	var soul_areas = []
	
	for phases in edm.soul_areas:
		var new_phase = []
		for area in phases:
			new_phase.append(area_template.new(
				area.move_speed,
				area.rot_angle,
				area.thickness
			))
		soul_areas.append(new_phase)
	
	edm.soul_areas = soul_areas
	
	# duplicate damage areas
	var damage_areas = []
	
	for phases in edm.damage_areas:
		var new_phase = []
		for area in phases:
			new_phase.append(area_template.new(
				area.move_speed,
				area.rot_angle,
				area.thickness,
				area.damage,
				area.is_damage_percentage
			))
		damage_areas.append(new_phase)
	
	edm.damage_areas = damage_areas
	
	return edm


# Function for loading and duplicating player skills.
# Duplication acts as a way to avoid changing the
# original template of the skill.
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
	
	# instantiate conditions
	skill.conditions = skill.conditions.new()
	skill.behaviors = skill.behaviors.new()
	
	return skill

extends Node


enum WheelPhase {
	SOUL_LOCK,
	SOUL_STRIKE,
	DEFENSE
}

var arrow_template = preload("res://Resources/Arrow/arrow.gd")
var area_template = preload("res://Resources/Area/area.gd")

var enemy_node = preload("res://Scenes/Components/Enemy/Enemy.tscn")
var player_node = preload("res://Scenes/Components/Player/Player.tscn")

var player = null

var player_manager = null
var enemy_manager = null

var chosen_skill = null
var modifiers = []


# Function for creating player node.
# Data model is not duplicated, so all the player information
# will stay there and will be saved if updated
func create_player_node():
	var new_player = player_node.instance()
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
	enemy.radius = 72 - (enemy_idx * 8)
	enemy.area_slots.start = enemy_idx
	enemy.area_slots.end = enemy_idx + 1
	
	return enemy


# Function for loading and duplicating the
# enemy data model.
func load_enemy_data_model(path_to_edm : String):
	# duplicate the data model
	var edm = load(path_to_edm).duplicate()
	
	# duplicate soul areas
	var defense_patterns = []
	
	for phase in edm.defense_patterns:
		var new_phase = phase.duplicate()
		var new_areas = []
		
		for area in phase.areas:
			new_areas.append(area_template.new(
				area.move_speed,
				area.rot_angle,
				area.thickness
			))
		
		new_phase.areas = new_areas
		defense_patterns.append(new_phase)
	
	edm.defense_patterns = defense_patterns
	
	# duplicate damage areas
	var attack_patterns = []
	
	for phase in edm.attack_patterns:
		var new_phase = phase.duplicate()
		var new_areas = []
		
		for area in phase.areas:
			new_areas.append(area_template.new(
				area.move_speed,
				area.rot_angle,
				area.thickness,
				area.damage,
				area.is_damage_percentage
			))
		
		new_phase.areas = new_areas
		attack_patterns.append(new_phase)
	
	edm.attack_patterns = attack_patterns
	
	# return
	return edm


func duplicate_attack_skill(skill):
	# create attack arrows
	var attack_patterns = []

	for phase in skill.attack_patterns:
		var new_phase = phase.duplicate()
		var new_arrows = []

		for arrow in phase.arrows:
			new_arrows.append(arrow_template.new(
				arrow.move_speed,
				arrow.rot_angle,
				arrow.thickness,
				arrow.damage)
			)

		new_phase.arrows = new_arrows
		attack_patterns.append(new_phase)

	skill.attack_patterns = attack_patterns

	# create defense arrows
	var defense_patterns = []

	for phase in skill.defense_patterns:
		var new_phase = phase.duplicate()
		var new_arrows = []

		for arrow in phase.arrows:
			new_arrows.append(arrow_template.new(
				arrow.move_speed,
				arrow.rot_angle,
				arrow.thickness)
			)

		new_phase.arrows = new_arrows
		defense_patterns.append(new_phase)

	skill.defense_patterns = defense_patterns

	# instantiate conditions
	skill.conditions = skill.conditions.new()
	skill.behaviors = skill.behaviors.new()


func reset_elements(pattern : Dictionary):
	var elements = pattern.arrows if pattern.has("arrows") else pattern.areas
	for element in elements:
		element.reset()


func is_hit(object1 : Vector2, object2 : Vector2):
	# when arrow is behind
	if object1.y - object2.x > 360:
		object2.x += 360
		object2.y += 360
	
	# when arrow is in front
	if object2.y - object1.x > 360:
		object1.x += 360
		object1.y += 360
	
	if object1.y >= object2.x and object1.x <= object2.y:
		return true
	
	return false


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

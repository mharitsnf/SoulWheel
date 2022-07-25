extends Node2D
class_name Wheel


export(float) var soul_lock_duration = 5

enum Phases {
	SOUL_LOCK
	SOUL_STRIKE
	DEFEND
}

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()

var process1
var process2

var object1 = [] # can be areas/arrows
var object2 = [] # can be arrows during enemy's turn

var phase = null
var running : bool = false
#var time_elapsed : float = 0
var did_player_act = true

signal stop_running
signal start_running


# ======= PUBLIC FUNCTIONS =======

func initialize(_phase):
	# Set the phase
	phase = _phase
	
	# Randomize RNG
	rng.randomize()
	
	# Set position to center of the screen
	position = Configurations.wheel.position
	
	# Connect signals
	var _e = connect("stop_running", self, "_on_stop_running")
	_e = connect("start_running", self, "_on_start_running")
	
	# Draw the wheel outline
	_draw_outline()


func destroy():
	queue_free()


func draw_areas(pattern, current_enemy):
	for area in pattern.areas:
		var new_area = _create_area(area.rot_angle, current_enemy.color)
		$Areas.add_child(new_area)
		_draw_area(new_area, current_enemy.radius, area.thickness)


func draw_arrows(pattern):
	for arrow in pattern.arrows:
		var arrow_display = _create_arrow(arrow.thickness, arrow.rot_angle)
		$Arrows.add_child(arrow_display)


# _processes: array of process functions
# _objects: array of behaviors
func action(behaviors, patterns, additional_info):
	var result = {
		"patterns": [],
		"did_player_acted": []
	}
	
	for behavior in behaviors:
		Nodes.root.add_child(behavior)
	
	match phase:
		Round.WheelPhase.SOUL_LOCK:
			var result0 = yield(behaviors[0].process.call_func(
				patterns[0],
				$Areas.get_children(),
				additional_info.ebi
			), "completed")
			
			result.patterns.append(result0[0])
			result.did_player_acted.append(result0[1])
		
		Round.WheelPhase.SOUL_STRIKE:
			var result0 = yield(behaviors[0].process_a.call_func(
				patterns[0],
				$Arrows.get_children(),
				additional_info.phase_number
			), "completed")
			
			result.patterns.append(result0[0])
			result.did_player_acted.append(result0[1])
		
		Round.WheelPhase.DEFEND:
			var player_thread = Thread.new()
			var player_data = {
				"behavior": behaviors[1],
				"params": [patterns[1], $Arrows.get_children(), additional_info.phase_number]
			}
			
			player_thread.start(self, "_player_process_d", player_data, 0)
			
			var result0 = yield(behaviors[0].process.call_func(
				patterns[0],
				$Areas.get_children(),
				additional_info.ebi
			), "completed")
			
			var result1 = yield(player_thread.wait_to_finish(), "completed")
			
			result.patterns.append(result0[0])
			result.patterns.append(result1[0])
			
			result.did_player_acted.append(result0[1])
			result.did_player_acted.append(result1[1])
	
	for behavior in behaviors:
		Nodes.root.remove_child(behavior)
	
	return result


func draw_locked_areas(characters):
	for character in characters:
		if character is Enemy:
			if character.is_locked:
				
				var area_container = Node2D.new()
				var defend_pattern = character.data_model.defend_patterns[character.behavior_idx]
				
				for area in defend_pattern.areas:
					var saved_area = _create_area(area.rot_angle, character.color, true)
					area_container.add_child(saved_area)
					_draw_area(saved_area, character.radius, area.thickness)
				
				$SavedAreas.add_child(area_container)

# ================================

# ======= PRIVATE FUNCTIONS =======

func _player_process_d(player_data):
	return yield(player_data.behavior.process_d.call_func(
		player_data.params[0],
		player_data.params[1],
		player_data.params[2]
	), "completed")


func _process(delta):
	pass
#	if running:
#		var is_finished = false
#
#		match phase:
#			Round.WheelPhase.SOUL_LOCK:
#				# Update data
#				var result = process1.call_func(
#					object1,
#					delta,
#					additional_info.ebi
#				)
#				object1 = result[0]
#				is_finished = result[1]
#
#				# Update visuals
#				for i in range(object1.areas.size()):
#					$Areas.get_child(i).rotation_degrees = object1.areas[i].rot_angle
#
#			Round.WheelPhase.SOUL_STRIKE:
#				var result = process1.call_func(
#					object1,
#					delta,
#					additional_info.phase_number
#				)
#				object1 = result[0]
#				is_finished = result[1]
#
#				for i in range(object1.arrows.size()):
#					$Arrows.get_child(i).rotation_degrees = object1.arrows[i].rot_angle
#
#			Round.WheelPhase.DEFEND:
#				# enemy's attack pattern (areas)
#				var result1 = process1.call_func(
#					object1,
#					delta,
#					additional_info.ebi
#				)
#				object1 = result1[0]
#
#				# player's defend pattern (arrows)
#				var result2 = process2.call_func(
#					object2,
#					delta,
#					additional_info.phase_number
#				)
#				object2 = result2[0]
#
#				# finish based on the player's pattern
#				is_finished = result2[1]
#
#				# update visuals
#				for i in range(object1.areas.size()):
#					$Areas.get_child(i).rotation_degrees = object1.areas[i].rot_angle
#
#				for i in range(object2.arrows.size()):
#					$Arrows.get_child(i).rotation_degrees = object2.arrows[i].rot_angle
#
##		time_elapsed += delta
#
#		if Input.is_action_pressed("ui_accept"):
#			did_player_act = true
#			emit_signal("stop_running")
#
#		if is_finished:
#			did_player_act = false
#			emit_signal("stop_running")


# Function for drawing the wheel's outline.
func _draw_outline():
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		outer_line.add_point(_calculate_point_on_circle(radian, 80))
	
#	for i in range(0, 361):
#		var radian = deg2rad(1.0 * i)
#		inner_line.add_point(_calculate_point_on_circle(radian, 64))


func _calculate_point_on_circle(radian: float, radius: float) -> Vector2:
	var s = sin(radian)
	var c = cos(radian)
	var point = Vector2(s * radius, c * radius)
	
	return point


func _create_area(rot_angle, color, is_locked = false):
	var area : Line2D = Line2D.new()
	area.width = 6
	area.rotation_degrees = rot_angle
	
	match phase:
		Round.WheelPhase.DEFEND: area.default_color = Color(1, 1, 1, 1)
		_:
			if is_locked: color.a = .5
			else: color.a = .5
			area.default_color = color
	
	return area


func _draw_area(line_node: Line2D, radius: float, thickness : int) -> void:
	for i in range(-thickness, thickness + 1):
		var radian = deg2rad(1.0 * i)
		line_node.add_point(_calculate_point_on_circle(radian, radius))


func _create_arrow(thickness: int, rot_angle : int):
	var new_polygon = Polygon2D.new()
	new_polygon.color = Color(1, 1, 1, 1)
	new_polygon.rotation_degrees = rot_angle
	var points = [Vector2.ZERO]
	
	for i in range(-thickness, thickness + 1):
		var radian = deg2rad(1.0 * i)
		points.append(_calculate_point_on_circle(radian, 80))
	
	new_polygon.polygon = points
	return new_polygon


func _on_start_running():
	running = true


func _on_stop_running():
	running = false
#	time_elapsed = 0

# ================================

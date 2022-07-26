extends Node2D
class_name Wheel


export(float) var soul_lock_duration = 5

enum { AREAS, ARROWS }

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()

var phase = null
var is_running : bool = false
var did_player_acted = false

signal action_ended

# ======= PUBLIC FUNCTIONS =======

func initialize(_phase):
	# Set the phase
	phase = _phase
	
	# Randomize RNG
	rng.randomize()
	
	# Set position to center of the screen
	position = Configurations.wheel.position
	
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
	
	for behavior in behaviors:
		Nodes.root.add_child(behavior)
	
	is_running = true
	
	match phase:
		Round.WheelPhase.SOUL_LOCK:
			behaviors[0].process.call_func(
				patterns[0],
				$Areas.get_children(),
				additional_info.ebi
			)
			
			yield(self, "action_ended")
			
			behaviors[0].stop_tween()
			_synchronize(AREAS, patterns[0], $Areas.get_children())
			
		Round.WheelPhase.SOUL_STRIKE:
			behaviors[0].process_a.call_func(
				patterns[0],
				$Arrows.get_children(),
				additional_info.phase_number
			)
			
			yield(self, "action_ended")
			
			behaviors[0].stop_tween()
			_synchronize(ARROWS, patterns[0], $Arrows.get_children())
			
		Round.WheelPhase.DEFEND:
			behaviors[0].process.call_func(
				patterns[0],
				$Areas.get_children(),
				additional_info.ebi
			)
			
			behaviors[1].process_d.call_func(
				patterns[1],
				$Arrows.get_children(),
				additional_info.phase_number
			)
			
			yield(self, "action_ended")
			
			behaviors[0].stop_tween()
			_synchronize(AREAS, patterns[0], $Areas.get_children())
			
			behaviors[1].stop_tween()
			_synchronize(ARROWS, patterns[1], $Arrows.get_children())
	
	is_running = false
	
	for behavior in behaviors:
		Nodes.root.remove_child(behavior)
	
	return did_player_acted


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

func _synchronize(flag, pattern, visuals):
	match flag:
		AREAS:
			for i in range(visuals.size()):
				pattern.areas[i].rot_angle = visuals[i].rotation_degrees
		
		ARROWS:
			for i in range(visuals.size()):
				pattern.arrows[i].rot_angle = visuals[i].rotation_degrees

func _player_process_d(player_data):
	return yield(player_data.behavior.process_d.call_funcv(player_data.params), "completed")


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

# ================================

func _input(event):
	if event.is_action_pressed("ui_accept") and is_running:
		did_player_acted = true
		emit_signal("action_ended")

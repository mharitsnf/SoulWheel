extends Node2D
class_name Wheel


export(float) var soul_lock_duration = 5

enum Phases {
	SOUL_LOCK
	SOUL_STRIKE
	ENEMY
}

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()

var process
var additional_info

var object1 = [] # can be areas/arrows
var object2 = [] # can be arrows during enemy's turn

var phase = null
var running : bool = false
var time_elapsed : float = 0

signal stop_running
signal start_running


func _process(delta):
	if running:
		
		match phase:
			Phases.SOUL_LOCK:
				# Update data
				object1 = process.call_func(
					object1,
					delta,
					additional_info.ebi
				)
				
				# Update visuals
				for i in range(object1.size()):
					$Areas.get_child(i).rotation_degrees = object1[i].rot_angle
			
			Phases.SOUL_STRIKE:
				object1 = process.call_func(
					object1,
					delta,
					additional_info.phase_number
				)
				
				for i in range(object1.size()):
					$Arrows.get_child(i).rotation_degrees = object1[i].rot_angle
		
#		if phase == "lock":
#			areas = area_behavior.call_func(delta, areas, enemy_behavior_idx)
#
#			# Update visuals
#			for i in range(areas.size()):
#				$Areas.get_child(i).rotation_degrees = areas[i].rot_angle
#
#		elif phase == "strike":
#			arrows = arrow_behavior.call_func(delta, arrows, skill_data)
#
#			# Update visuals
#			for i in range(arrows.size()):
#				$Arrows.get_child(i).rotation_degrees = arrows[i].rot_angle
#
#		else:
#			areas = area_behavior.call_func(delta, areas, enemy_behavior_idx)
#			arrows = arrow_behavior.call_func(delta, arrows, skill_data)
#
#			# Update area visuals
#			for i in range(areas.size()):
#				$Areas.get_child(i).rotation_degrees = areas[i].rot_angle
#
#			# Update visuals
#			for i in range(arrows.size()):
#				$Arrows.get_child(i).rotation_degrees = arrows[i].rot_angle
		
		time_elapsed += delta
		
		if time_elapsed > soul_lock_duration or Input.is_action_pressed("ui_accept"):
			emit_signal("stop_running")


func initialize(_phase):
	# Set the phase
	phase = _phase
	
	# Randomize RNG
	rng.randomize()
	
	# Set position to center of the screen
	position = Configurations.wheel_center
	
	# Connect signals
	var _e = connect("stop_running", self, "_on_stop_running")
	_e = connect("start_running", self, "_on_start_running")
	
	# Draw the wheel outline
	_draw_outline()


func destroy():
	queue_free()


func draw_areas(_areas):
	for area in _areas:
		var new_area = _create_area(area.rot_angle)
		$Areas.add_child(new_area)
		_draw_area(new_area, 72, area.thickness)


func draw_arrows(_arrows):
	for arrow in _arrows:
		var arrow_display = _create_arrow(arrow.thickness, arrow.rot_angle)
		$Arrows.add_child(arrow_display)


func action(_process, _objects, _additional_info):
	process = _process
	additional_info = _additional_info
	
	match phase:
		Phases.SOUL_LOCK:
			object1 = _objects[0]
		Phases.SOUL_STRIKE:
			object1 = _objects[0]
		Phases.ENEMY:
			object1 = _objects[0]
			object2 = _objects[1]
	
	
	emit_signal("start_running")
	yield(self, "stop_running")
	
	match phase:
		Phases.SOUL_LOCK: return object1
		Phases.SOUL_STRIKE: return object1
		Phases.ENEMY: return [object1, object2]
	
#
#	if phase == "lock":
#		return areas
#
#	elif phase == "strike":
#		return [arrows, skill_data]
#
#	else:
#		return [areas, arrows, skill_data]


# Function for drawing the wheel's outline.
func _draw_outline():
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		outer_line.add_point(_calculate_point_on_circle(radian, 80))
	
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		inner_line.add_point(_calculate_point_on_circle(radian, 64))


func _draw_area(line_node: Line2D, radius: float, thickness : int) -> void:
	for i in range(-thickness, thickness + 1):
		var radian = deg2rad(1.0 * i)
		line_node.add_point(_calculate_point_on_circle(radian, radius))


func draw_locked_areas(characters):
	for character in characters:
		if character is Enemy:
			if character.is_locked:
				
				var area_container = Node2D.new()
				var soul_areas = character.data_model.soul_areas[character.behavior_idx]
				
				for area in soul_areas:
					var saved_area = _create_area(area.rot_angle)
					area_container.add_child(saved_area)
					_draw_area(saved_area, 72, area.thickness)
				
				$SavedAreas.add_child(area_container)


func _calculate_point_on_circle(radian: float, radius: float) -> Vector2:
	var s = sin(radian)
	var c = cos(radian)
	var point = Vector2(s * radius, c * radius)
	
	return point


func _create_area(rot_angle):
	var area : Line2D = Line2D.new()
	area.width = 8
	area.rotation_degrees = rot_angle
	
	match phase:
		Phases.ENEMY: area.default_color = Color(1, 0, 0, 1)
		_: area.default_color = Color(1, 1, 1, .5)
	
	return area


func _create_arrow(thickness: int, rot_angle : int):
	var new_polygon = Polygon2D.new()
	new_polygon.color = Color(0, 1, 1, 1)
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
	time_elapsed = 0

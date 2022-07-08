extends Node2D


export(float) var soul_lock_duration = 3

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()
var enemy : Enemy = null
var soul_area_data : Array = []
var running : bool = false
var time_elapsed : float = 0

signal stop_running
signal start_running


func _process(delta):
	if running:
		
		for i in range($Areas.get_child_count()):
			$Areas.get_child(i).rotation_degrees += delta * soul_area_data[i].move_speed * soul_area_data[i].rot_direction
		
		time_elapsed += delta
		
		if time_elapsed > soul_lock_duration or Input.is_action_pressed("ui_accept"):
			emit_signal("stop_running")


func initialize():
	yield(get_tree(), "idle_frame")
	
	rng.randomize()
	
	position = Configurations.wheel_center
	
	var _e = connect("stop_running", self, "_on_stop_running")
	_e = connect("start_running", self, "_on_start_running")
	
	_draw_outline()
	_draw_saved_areas()


func destroy():
	yield(get_tree(), "idle_frame")
	queue_free()


func set_enemy_data(_enemy, _soul_area_data):
	enemy = _enemy
	soul_area_data = _soul_area_data
	
	for soul_area in soul_area_data:
		soul_area.move_speed += rng.randf_range(-20, 20)
		soul_area.start_rot_angle += rng.randf_range(-5, 5)
		soul_area.rot_direction = (rng.randi_range(0, 1) * 2) - 1


func draw_new_areas():
	yield(get_tree(), "idle_frame")
	
	for single_data in soul_area_data:
		var new_area = _create_area(single_data.start_rot_angle)
		$Areas.add_child(new_area)
		_draw_area(new_area, 72, single_data.start_angle, single_data.end_angle)


func soul_lock():
	emit_signal("start_running")
	yield(self, "stop_running")


# Function for drawing the wheel's outline.
func _draw_outline():
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		outer_line.add_point(_calculate_point_on_circle(radian, 80))
	
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		inner_line.add_point(_calculate_point_on_circle(radian, 64))


func _draw_saved_areas():
	pass


func _draw_area(line_node: Line2D, radius: float, start_angle: int, end_angle: int) -> void:
	for i in range(start_angle, end_angle + 1):
		var radian = deg2rad(1.0 * i)
		line_node.add_point(_calculate_point_on_circle(radian, radius))


func _calculate_point_on_circle(radian: float, radius: float) -> Vector2:
	var s = sin(radian)
	var c = cos(radian)
	var point = Vector2(s * radius, c * radius)
	
	return point


func _create_area(rot_angle):
	var area = Line2D.new()
	area.width = 8
	area.rotation_degrees = rot_angle
	return area


func _on_start_running():
	running = true


func _on_stop_running():
	running = false
	time_elapsed = 0
	
	var locked_areas = []
	for i in range($Areas.get_child_count()):
		var locked_area = soul_area_data[i]
		locked_area.current_rotation = $Areas.get_child(i).rotation_degrees
		locked_areas.append(locked_area)
	
	WheelSingleton.saved_areas[enemy.get_instance_id()] = locked_areas

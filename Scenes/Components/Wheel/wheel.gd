extends Node2D


export(float) var soul_lock_duration = 5

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()

var enemy = null
var arrows := {}

var phase = null
var running : bool = false
var time_elapsed : float = 0

signal stop_running
signal start_running


func _process(delta):
	if running:
		
		if phase == "lock":
			for i in range(enemy.soul_areas.size()):
				enemy.soul_areas[i].rot_angle += delta * enemy.soul_areas[i].move_speed
				enemy.soul_areas[i].rot_angle = fmod(enemy.soul_areas[i].rot_angle, 360)
				$Areas.get_child(i).rotation_degrees = enemy.soul_areas[i].rot_angle
				
				if i == 0: print(enemy.soul_areas[i].rot_angle)
		
		elif phase == "strike":
			for i in range(arrows.data.size()):
				arrows.data[i].rot_angle += delta * arrows.data[i].move_speed
				arrows.data[i].rot_angle = fmod(arrows.data[i].rot_angle, 360)
				$Arrows.get_child(i).rotation_degrees = arrows.data[i].rot_angle
				
		
		time_elapsed += delta
		
		if time_elapsed > soul_lock_duration or Input.is_action_pressed("ui_accept"):
			emit_signal("stop_running")


func initialize(_phase):
	yield(get_tree(), "idle_frame")
	
	phase = _phase
	
	rng.randomize()
	
	position = Configurations.wheel_center
	
	var _e = connect("stop_running", self, "_on_stop_running")
	_e = connect("start_running", self, "_on_start_running")
	
	_draw_outline()
	_draw_saved_area()


func destroy():
	yield(get_tree(), "idle_frame")
	queue_free()


func set_enemy(_enemy):
	yield(get_tree(), "idle_frame")
	
	var processed_souls = []
		
	for soul in _enemy.soul_areas:
		var tmp_soul = soul.duplicate()
		tmp_soul.thickness = _thickness_preprocess(tmp_soul.thickness)
		tmp_soul.move_speed += rng.randf_range(-20, 20)
		tmp_soul.rot_angle += rng.randf_range(-180, 180)
		if tmp_soul.rot_angle < 0: tmp_soul.rot_angle += 360
		processed_souls.append(tmp_soul)
	
	_enemy.soul_areas = processed_souls
	
	enemy = _enemy


func set_arrows(_arrows):
	yield(get_tree(), "idle_frame")
	
	var processed_arrows = []
	
	for arrow in _arrows.data:
		var tmp_arrow = arrow.duplicate()
		tmp_arrow.thickness = _thickness_preprocess(tmp_arrow.thickness)
		processed_arrows.append(tmp_arrow)
	
	_arrows.data = processed_arrows
	arrows = _arrows


func draw_areas():
	yield(get_tree(), "idle_frame")
	
	for soul in enemy.soul_areas:
		var new_area = _create_area(soul.rot_angle)
		$Areas.add_child(new_area)
		_draw_area(new_area, 72, soul.thickness)


func draw_arrows():
	yield(get_tree(), "idle_frame")
	
	for arrow in arrows.data:
		var arrow_display = _create_arrow(arrow.thickness, arrow.rot_angle)
		$Arrows.add_child(arrow_display)


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


func _draw_area(line_node: Line2D, radius: float, thickness : int) -> void:
	for i in range(-thickness, thickness + 1):
		var radian = deg2rad(1.0 * i)
		line_node.add_point(_calculate_point_on_circle(radian, radius))


func _draw_saved_area():
	for enemy in Globals.saved_areas:
		for area in enemy.soul_areas:
			var saved_area = _create_area(area.rot_angle)
			$SavedAreas.add_child(saved_area)
			_draw_area(saved_area, 72, area.thickness)


func _calculate_point_on_circle(radian: float, radius: float) -> Vector2:
	var s = sin(radian)
	var c = cos(radian)
	var point = Vector2(s * radius, c * radius)
	
	return point


func _create_area(rot_angle):
	var area : Line2D = Line2D.new()
	area.width = 8
	area.rotation_degrees = rot_angle
	area.default_color.a = 0.5
	return area


func _create_arrow(thickness : int, rot_angle : int):
	thickness = _thickness_preprocess(thickness)
	
	var new_polygon = Polygon2D.new()
	new_polygon.color = Color(1, 0, 0, 1)
	new_polygon.rotation_degrees = rot_angle
	
	var origin_point = Vector2.ZERO
	var points = [Vector2.ZERO]
	
	for i in range(-thickness, thickness + 1):
		var radian = deg2rad(1.0 * i)
		var point = _calculate_point_on_circle(radian, 80)
		points.append(point)
	
	new_polygon.polygon = points
	
	return new_polygon


func _thickness_preprocess(thickness):
	thickness = fmod(abs(thickness), 361)
	thickness = floor(clamp(thickness, 2, 360) / 2)
	return thickness


func _on_start_running():
	running = true


func _on_stop_running():
	running = false
	time_elapsed = 0
	
	if phase == "lock":
		Globals.saved_areas.append(enemy)
	elif phase == "strike":
		Globals.saved_arrow = arrows

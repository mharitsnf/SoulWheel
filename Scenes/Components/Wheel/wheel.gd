extends Node2D


export(float) var soul_lock_duration = 5

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()

var area_behavior = null
var arrow_behavior = null

var enemy_behavior_idx = 0
var areas = []
var arrows = []

var phase = null
var running : bool = false
var time_elapsed : float = 0

signal stop_running
signal start_running


func _process(delta):
	if running:
		
		if phase == "lock":
			areas = area_behavior.call_func(delta, areas, enemy_behavior_idx)
			
			# Update visuals
			for i in range(areas.size()):
				$Areas.get_child(i).rotation_degrees = areas[i].rot_angle
		
		elif phase == "strike":
			arrows = arrow_behavior.call_func(delta, arrows)
			
			# Update visuals
			for i in range(arrows.size()):
				$Arrows.get_child(i).rotation_degrees = arrows[i].rot_angle
		
		else:
			areas = area_behavior.call_func(delta, areas, enemy_behavior_idx)
			arrows = arrow_behavior.call_func(delta, arrows)
			
			# Update area visuals
			for i in range(areas.size()):
				$Areas.get_child(i).rotation_degrees = areas[i].rot_angle
			
			# Update visuals
			for i in range(arrows.size()):
				$Arrows.get_child(i).rotation_degrees = arrows[i].rot_angle
		
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


func destroy():
	yield(get_tree(), "idle_frame")
	queue_free()


func set_enemy_behavior_index(_ebi):
	enemy_behavior_idx = _ebi


func set_area_behavior(_area_behavior):
	area_behavior = _area_behavior


func set_arrow_behavior(_arrow_behavior):
	arrow_behavior = _arrow_behavior


# Put ready-to-process area data in this node. Will be returned later after the action
# has been done
func set_area(_areas, preprocessor):
	areas = preprocessor.call_func(_areas, enemy_behavior_idx)


# Put ready-to-process arrow data in this node. Will be returned later after the action
# has been done
func set_arrows(attack_phase, preprocessor):
	arrows = preprocessor.call_func(attack_phase)


func draw_areas():
	for area in areas:
		var new_area = _create_area(area.rot_angle)
		$Areas.add_child(new_area)
		_draw_area(new_area, 72, area.thickness)


func draw_arrows():
	for arrow in arrows:
		var arrow_display = _create_arrow(arrow.thickness, arrow.rot_angle)
		$Arrows.add_child(arrow_display)


func action():
	emit_signal("start_running")
	yield(self, "stop_running")
	
	if phase == "lock":
		return areas
	
	elif phase == "strike":
		return arrows
	
	else:
		return [areas, arrows]


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


func draw_soul_areas(processed_enemies):
	for cur_enemy in processed_enemies:
		var area_container = Node2D.new()
		area_container.modulate.a = 0.5
		
		for area in cur_enemy.dm.soul_areas[cur_enemy.dm.soul_behavior_idx]:
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
	
	if phase == "enemy_attack":
		area.default_color = Color(1, 0, 0, 1)
	
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

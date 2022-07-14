extends Node2D


export(float) var soul_lock_duration = 5

onready var outer_line = $OuterLine
onready var inner_line = $InnerLine

var rng = RandomNumberGenerator.new()

var enemy = null
var arrows = []

var phase = null
var running : bool = false
var time_elapsed : float = 0

signal stop_running
signal start_running


func _process(delta):
	if running:
		
		if phase == "lock":
			for i in range(enemy.dm.soul_areas.size()):
				var new_rot_angle = _rotate(
					enemy.dm.soul_areas[i].rot_angle,
					enemy.dm.soul_areas[i].move_speed,
					delta
				)
				
				enemy.dm.soul_areas[i].rot_angle = new_rot_angle
				$Areas.get_child(i).rotation_degrees = new_rot_angle
		
		elif phase == "strike":
			for i in range(arrows.size()):
				var new_rot_angle = _rotate(
					arrows[i].rot_angle,
					arrows[i].move_speed,
					delta
				)
				
				arrows[i].rot_angle = new_rot_angle
				$Arrows.get_child(i).rotation_degrees = new_rot_angle
		
		else:
			for i in range(enemy.dm.damage_areas.size()):
				var new_rot_angle = _rotate(
					enemy.dm.damage_areas[i].rot_angle,
					enemy.dm.damage_areas[i].move_speed,
					delta
				)
				
				enemy.dm.damage_areas[i].rot_angle = new_rot_angle
				$DamageAreas.get_child(i).rotation_degrees = new_rot_angle
			
			for i in range(arrows.size()):
				var new_rot_angle = _rotate(
					arrows[i].rot_angle,
					arrows[i].move_speed,
					delta
				)
				
				arrows[i].rot_angle = new_rot_angle
				$Arrows.get_child(i).rotation_degrees = new_rot_angle
		
		time_elapsed += delta
		
		if time_elapsed > soul_lock_duration or Input.is_action_pressed("ui_accept"):
			emit_signal("stop_running")


func _rotate(rot_angle, move_speed, delta):
	var new_rot_angle = rot_angle
	
	new_rot_angle += delta * move_speed
	
	new_rot_angle = fmod(new_rot_angle, 360)
	if new_rot_angle < 0: new_rot_angle += 360
	
	return new_rot_angle


func initialize(_phase):
	yield(get_tree(), "idle_frame")
	
	phase = _phase
	
	rng.randomize()
	
	position = Configurations.wheel_center
	
	var _e = connect("stop_running", self, "_on_stop_running")
	_e = connect("start_running", self, "_on_start_running")
	
	_draw_outline()
	
	if phase != "enemy_attack":
		_draw_saved_area()


func destroy():
	yield(get_tree(), "idle_frame")
	queue_free()


func set_enemy(_enemy):
	yield(get_tree(), "idle_frame")
	
	if phase == "lock":
		var processed_souls = []
			
		for soul in _enemy.dm.soul_areas:
			var tmp_soul = soul.duplicate()
			tmp_soul.thickness = _thickness_preprocess(tmp_soul.thickness)
			
			tmp_soul.move_speed += rng.randf_range(-20, 20)
			tmp_soul.move_speed = max(10, tmp_soul.move_speed)
			
			tmp_soul.rot_angle += rng.randf_range(-180, 180)
			tmp_soul.rot_angle = fmod(tmp_soul.rot_angle, 360)
			if tmp_soul.rot_angle < 0: tmp_soul.rot_angle += 360
			
			processed_souls.append(tmp_soul)
		
		_enemy.dm.soul_areas = processed_souls
	
	else:
		var processed_damage_areas = []
		
		var angle_variation = rng.randf_range(-180, 180)
		
		for damage in _enemy.dm.damage_areas:
			var tmp_damage = damage.duplicate()
			tmp_damage.thickness = _thickness_preprocess(tmp_damage.thickness)
			tmp_damage.rot_angle += angle_variation
			processed_damage_areas.append(tmp_damage)
		
		_enemy.dm.damage_areas = processed_damage_areas
	
	enemy = _enemy


func set_arrows(_arrows):
	yield(get_tree(), "idle_frame")
	
	if phase == "strike":
		var processed_arrows = []
		
		var rot_angle_variation = rng.randf_range(-180, 180)
		var move_speed_variation = rng.randf_range(-20, 20)
		
		for arrow in _arrows:
			var tmp_arrow = arrow.duplicate()
			tmp_arrow.thickness = _thickness_preprocess(tmp_arrow.thickness)
			tmp_arrow.rot_angle += rot_angle_variation
			tmp_arrow.move_speed += move_speed_variation
			processed_arrows.append(tmp_arrow)
		
		_arrows = processed_arrows
	
	else:
		var processed_arrows = []
		
		var rot_angle_variation = rng.randf_range(-180, 180)
		var move_speed_variation = rng.randf_range(-20, 20)
		
		for arrow in _arrows:
			var tmp_arrow = arrow.duplicate()
			tmp_arrow.thickness = _thickness_preprocess(tmp_arrow.thickness)
			tmp_arrow.rot_angle += rot_angle_variation
			tmp_arrow.move_speed += move_speed_variation
			processed_arrows.append(tmp_arrow)
		
		_arrows = processed_arrows
	
	arrows = _arrows


func draw_areas():
	yield(get_tree(), "idle_frame")
	
	if phase == "lock":
		for soul in enemy.dm.soul_areas:
			var new_area = _create_area(soul.rot_angle)
			$Areas.add_child(new_area)
			_draw_area(new_area, 72, soul.thickness)
	
	else:
		for damage in enemy.dm.damage_areas:
			var new_damage_area = _create_area(damage.rot_angle)
			$DamageAreas.add_child(new_damage_area)
			_draw_area(new_damage_area, 72, damage.thickness)


func draw_arrows():
	yield(get_tree(), "idle_frame")
	
	for arrow in arrows:
		var arrow_display = _create_arrow(arrow.thickness, arrow.rot_angle)
		$Arrows.add_child(arrow_display)


func action():
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
	for cur_enemy in Globals.saved_areas:
		var area_container = Node2D.new()
		area_container.modulate.a = 0.5
		
		for area in cur_enemy.dm.soul_areas:
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


func _thickness_preprocess(thickness):
	thickness = fmod(abs(thickness), 360)
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
		for arrow in arrows:
			Globals.saved_arrow.append(arrow)
	
	else:
		Globals.saved_areas.append(enemy)
		
		for arrow in arrows:
			Globals.saved_arrow.append(arrow)
	

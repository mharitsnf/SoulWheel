extends Node2D


onready var outer_line = $OuterLine
onready var inner_line = $InnerLine


func initialize():
	yield(get_tree(), "idle_frame")
	position = Configurations.wheel_center
	draw_outline()


func destroy():
	yield(get_tree(), "idle_frame")
	queue_free()


# Function for drawing the wheel's outline.
func draw_outline():
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		outer_line.add_point(_calculate_point_on_circle(radian, 80))
	
	for i in range(0, 361):
		var radian = deg2rad(1.0 * i)
		inner_line.add_point(_calculate_point_on_circle(radian, 64))


func draw_area(line_node: Line2D, radius: float, start_angle: int, end_angle: int) -> void:
	for i in range(start_angle, end_angle + 1):
		var radian = deg2rad(1.0 * i)
		line_node.add_point(_calculate_point_on_circle(radian, radius))


func _calculate_point_on_circle(radian: float, radius: float) -> Vector2:
	var s = sin(radian)
	var c = cos(radian)
	var point = Vector2(s * radius, c * radius)
	
	return point

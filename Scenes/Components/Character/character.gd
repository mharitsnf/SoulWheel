extends Node2D
class_name Character


export(PackedScene) var wheel : PackedScene

var turn_count : int = 0
var is_hit = null
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

enum Behavior {
	ATTACK
	DEFEND
}
var current_behavior = 0

onready var turn_manager : Node2D = get_parent()
onready var root : Node = get_parent().get_parent()


func _ready():
	is_hit = funcref(self, '_is_hit')
	rng.randomize()


func _summon_wheel(phase):
	Nodes.wheel = wheel.instance()
	Nodes.root.add_child(Nodes.wheel)
	Nodes.wheel.initialize(phase)


func _destroy_wheel():
	Nodes.wheel.destroy()
	Nodes.wheel = null


func _is_hit(arrow : Vector2, area : Vector2):
	# when arrow is behind
	if arrow.y - area.x > 360:
		area.x += 360
		area.y += 360
	
	# when arrow is in front
	if area.y - arrow.x > 360:
		arrow.x += 360
		arrow.y += 360
	
	if arrow.y >= area.x and arrow.x <= area.y:
		return true
	
	return false

func _generate_angles(rot_angle, thickness):
	# Limit to -359 to 359
	var start_angle = fmod(-thickness + rot_angle, 360)
	var end_angle = fmod(thickness + 1 + rot_angle, 360)
	
	# Limit to 0 to 359
	if start_angle < 0: start_angle += 360
	if end_angle < 0: end_angle += 360
	
	# Handles when start angle > end angle
	if start_angle > end_angle: end_angle += 360
	
	return Vector2(start_angle, end_angle)


func select_behavior(behavior):
	current_behavior = behavior


func take_damage(_damage):
	pass


func _start_turn():
	pass


func _end_turn():
	turn_count += 1


func play_turn():
	pass

extends Resource


var move_speed
var initial_move_speed
var rot_angle
var thickness
var damage

var rot_angle_displacement = 0
var enemies_struck = []
var struck_by = []


func _init(_move_speed = 0, _rot_angle = 0, _thickness = 2, _damage = 0):
	move_speed = _move_speed
	initial_move_speed = _move_speed
	rot_angle = _rot_angle
	thickness = floor(clamp(_thickness, 2, 360) / 2)
	damage = _damage

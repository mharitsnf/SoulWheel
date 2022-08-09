extends Resource


var move_speed
var initial_move_speed

var damage
var initial_damage

var rot_angle
var thickness

var rot_angle_displacement = 0
var enemies_struck = []
var struck_by = []


func _init(_move_speed = 0, _rot_angle = 0, _thickness = 2, _damage = 0):
	move_speed = _move_speed
	initial_move_speed = _move_speed
	
	damage = _damage
	initial_damage = _damage
	
	rot_angle = _rot_angle
	thickness = floor(clamp(_thickness, 2, 360) / 2)


func reset():
	move_speed = initial_move_speed
	damage = initial_damage
	enemies_struck = []
	struck_by = []


func clamp_rot_angle():
	rot_angle = fmod(rot_angle, 360)
	if rot_angle < 0: rot_angle += 360

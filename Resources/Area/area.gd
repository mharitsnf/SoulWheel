extends Resource


var move_speed
var initial_move_speed

var damage
var initial_damage

var rot_angle
var thickness
var is_damage_percentage

var rot_angle_displacement = 0
var is_visible = true


func _init(_move_speed = 0, _rot_angle = 0, _thickness = 0, _damage = 0, _is_damage_percentage = false):
	move_speed = _move_speed
	initial_move_speed = _move_speed
	
	damage = _damage
	initial_damage = _damage
	
	rot_angle = _rot_angle
	thickness = floor(clamp(_thickness, 2, 360) / 2)
	is_damage_percentage = _is_damage_percentage

func reset():
	move_speed = initial_move_speed
	damage = initial_damage

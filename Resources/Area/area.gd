extends Resource


var move_speed
var rot_angle
var thickness
var damage
var is_damage_percentage
var is_visible = true


func _init(_move_speed = 0, _rot_angle = 0, _thickness = 0, _damage = 0, _is_damage_percentage = false):
	move_speed = _move_speed
	rot_angle = _rot_angle
	thickness = _thickness
	damage = _damage
	is_damage_percentage = _is_damage_percentage

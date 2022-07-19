extends Resource


var move_speed
var rot_angle
var thickness
var damage

var enemies_struck = []
var struck_by = []


func _init(_move_speed = 0, _rot_angle = 0, _thickness = 2, _damage = 0):
	move_speed = _move_speed
	rot_angle = _rot_angle
	thickness = _thickness
	damage = _damage

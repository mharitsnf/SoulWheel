extends Node2D
class_name Character


export(PackedScene) var wheel : PackedScene

var wheel_ins : Node2D = null
var turn_count : int = 0

onready var turn_manager : Node2D = get_parent()


func _summon_wheel(phase):
	wheel_ins = wheel.instance()
	Globals.root.add_child(wheel_ins)
	yield(wheel_ins.initialize(phase), "completed")


func _destroy_wheel():
	yield(wheel_ins.destroy(), "completed")
	wheel_ins = null


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


func take_damage(_damage):
	pass


func _end_turn():
	turn_count += 1


func play_turn():
	pass

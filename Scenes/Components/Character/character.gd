extends Node2D
class_name Character


export(PackedScene) var wheel : PackedScene
var wheel_ins : Node2D = null


func _summon_wheel(phase):
	wheel_ins = wheel.instance()
	Globals.root.add_child(wheel_ins)
	yield(wheel_ins.initialize(phase), "completed")


func _destroy_wheel():
	yield(wheel_ins.destroy(), "completed")
	wheel_ins = null


func _end_turn():
	pass


func play_turn():
	pass

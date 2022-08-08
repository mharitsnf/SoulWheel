extends Node2D
class_name CharacterManager


export(PackedScene) var wheel

onready var turn_manager = get_parent()

var turn_count = 0

signal turn_finished

# ===== Turn Management =====
func first_turn():
	pass


func _start_turn():
	pass


func play_turn():
	yield(get_tree(), "idle_frame")
	return false


func _end_turn():
	pass


func final_turn():
	pass
# ===========================


# ===== Wheel Functions =====
func _summon_wheel(phase):
	Nodes.wheel = wheel.instance()
	Nodes.root.add_child(Nodes.wheel)
	Nodes.wheel.initialize(phase)


func _destroy_wheel():
	Nodes.wheel.destroy()
	Nodes.wheel = null
# ===========================

extends Node2D
class_name Character


export(PackedScene) var wheel : PackedScene

var turn_count : int = 0
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

onready var turn_manager : Node2D = get_parent()
onready var root : Node = get_parent().get_parent()


func _ready():
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


func take_damage(_damage):
	# pop up notification
	hp_notification(-_damage)
	
	# Shake animation
	$Shaker.start("position", position, 1)


func hp_notification(amount):
	var notification_ins = load("res://Scenes/UI/Notification/Notification.tscn").instance()
	notification_ins.initialize(amount)
	notification_ins.rect_position = position + Vector2(-15, -30)
	Nodes.notification_container.add_child(notification_ins)
	yield(notification_ins, "tree_exited")


func _start_turn():
	pass


func _end_turn():
	turn_count += 1


func play_turn():
	pass

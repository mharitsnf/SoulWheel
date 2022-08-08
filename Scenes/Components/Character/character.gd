extends Node2D
class_name Character


export(PackedScene) var notification_scn

var rng : RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	rng.randomize()


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


func take_damage(damage):
	# pop up notification
	hp_notification(-damage)
	
	# Shake animation
	$Shaker.start("position", position, 1)


func hp_notification(amount):
	var notification_ins = notification_scn.instance()
	notification_ins.initialize(amount)
	notification_ins.rect_position = position + Vector2(-15, -30)
	Nodes.notification_container.add_child(notification_ins)
	yield(notification_ins.tween, "tween_completed")



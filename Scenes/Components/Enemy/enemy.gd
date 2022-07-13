extends Character
class_name Enemy


export var enemy_data_model : Resource

onready var current_health = enemy_data_model.max_health

signal input_signal


func _ready():
	assert(enemy_data_model)
	assert(enemy_data_model is EnemyDataModel)


func play_turn():
	print("enemy playing")
	
	var current_enemy = Globals.enemy_loader(self)
	
	for arrow_phase in Globals.player.player_data_model.player_soul_arrows:
		yield(_summon_wheel("enemy_attack"), "completed")
		yield(wheel_ins.set_enemy(current_enemy), "completed")
		yield(wheel_ins.set_arrows(arrow_phase), "completed")
		yield(wheel_ins.draw_areas(), "completed")
		yield(wheel_ins.draw_arrows(), "completed")
		yield(wheel_ins.action(), "completed")
		yield(_destroy_wheel(), "completed")
		
		_check_result()
		
		Globals.saved_arrow = []
		
		_end_turn()
		
		yield(get_tree().create_timer(1), "timeout")


func _check_result():
	if !Globals.saved_areas.empty() and !Globals.saved_arrow.empty():
		for enemy in Globals.saved_areas:
			for arrow in Globals.saved_arrow:
				var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)
				
				for area in enemy.dm.damage_areas:
					var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)
					
					if _is_hit(arrow_angle, area_angle):
						print("player is hit by: ", enemy.node)


func _end_turn():
	Globals.saved_areas = []


func get_soul_area_data():
	var data = []
	if enemy_data_model is EnemyDataModel:
		data = enemy_data_model.soul_areas
	return data


func take_damage(damage):
	var new_health = current_health - damage
	current_health = max(0, new_health)
	
	if new_health <= 0:
		return true
	
	return false


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("input_signal")

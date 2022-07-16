extends Character
class_name Enemy


export var enemy_data_model : Resource

onready var current_health = enemy_data_model.max_health

var enemies_to_process = []
var arrows_to_process = []

signal input_signal


func _ready():
	._ready()
	
	assert(enemy_data_model)
	assert(enemy_data_model is EnemyDataModel)


func play_turn():
	print("enemy playing")
	
	var current_enemy = Globals.enemy_loader(self)
	
	for arrow_phase in Globals.player.player_data_model.player_soul_arrows:
		yield(_summon_wheel("enemy_attack"), "completed")
		
		wheel_ins.set_enemy(current_enemy)
		wheel_ins.set_arrows(arrow_phase)
		wheel_ins.draw_areas()
		wheel_ins.draw_arrows()
		
		var result = yield(wheel_ins.action(), "completed")
		enemies_to_process.append(result[0])
		arrows_to_process = result[1]
		
		yield(_destroy_wheel(), "completed")
		
		var is_player_defeated = _check_result()
		
		arrows_to_process = []
		
		if is_player_defeated:
			_end_turn()
			return true
		
		yield(get_tree().create_timer(1), "timeout")
	
	_end_turn()
	return false


func _check_result():
	for enemy in enemies_to_process:
		for arrow in arrows_to_process:
			var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)
			
			for area in enemy.dm.damage_areas:
				var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)
				
				if _is_hit(arrow_angle, area_angle):
					var is_player_defeated = Globals.player.take_damage(area.damage)
					print("player is hit by: ", self, " current player HP: ", Globals.player.player_data_model.current_health)
					
					if is_player_defeated:
						return true
	
	return false


func _end_turn():
	enemies_to_process = []
	
	._end_turn()


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

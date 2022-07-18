extends Character
class_name Enemy


export var enemy_data_model : Resource

onready var current_health = enemy_data_model.max_health

var is_defeated = false

signal input_signal


func _ready():
	._ready()
	
	assert(enemy_data_model)
	assert(enemy_data_model is EnemyDataModel)


func play_turn():
	print("enemy playing")
	
	var current_enemy = Globals.enemy_loader(self)
	var ebi = current_enemy.dm.damage_behavior_idx
	var chosen_skill = Globals.player.chosen_skill
	
	for defend_phase in chosen_skill.defend_arrows:
		yield(_summon_wheel("enemy_attack"), "completed")
		
		# Setting enemy's damage areas
		wheel_ins.set_enemy_behavior_index(ebi)
		wheel_ins.set_area_behavior(current_enemy.dm.behaviors_ins.attack_behavior)
		wheel_ins.set_area(current_enemy.dm.damage_areas[ebi], current_enemy.dm.behaviors_ins.randomize_defend)
		
		# Setting player's defend arrows
		wheel_ins.set_arrows(defend_phase, chosen_skill.behaviors_ins.randomize_defend)
		wheel_ins.set_arrow_behavior(chosen_skill.behaviors_ins.defend_behavior)
		
		# Draw arrows and areas
		wheel_ins.draw_areas()
		wheel_ins.draw_arrows()
		
		var result = yield(wheel_ins.action(), "completed")
		current_enemy.dm.damage_areas[ebi] = result[0]
		var processed_arrows = result[1]
		
		_check_result(current_enemy.dm.damage_areas[ebi], processed_arrows)
		if chosen_skill.conditions_ins.second_condition(processed_arrows):
			print("gained ", chosen_skill.hp_bonus," hp!")
			Globals.player.add_hp(chosen_skill.hp_bonus)
		
		if _deal_damage(processed_arrows):
			yield(_destroy_wheel(), "completed")
			_end_turn()
			return true
		
		yield(get_tree().create_timer(.5), "timeout")
		yield(_destroy_wheel(), "completed")
		yield(get_tree().create_timer(.5), "timeout")
		
	_end_turn()
	return false


func _check_result(areas, arrows):
	for area in areas:
		var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)
		
		for arrow in arrows:
			var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)
			
			if _is_hit(arrow_angle, area_angle):
				arrow.struck_by.append(area)


func _deal_damage(arrows):
	for arrow in arrows:
		for area in arrow.struck_by:
			if Globals.player.take_damage(area.damage): return true
	
	return false


func _end_turn():
	._end_turn()


func take_damage(damage):
	var new_health = current_health - damage
	current_health = max(0, new_health)
	
	if new_health <= 0:
		return true
	
	return false


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("input_signal")

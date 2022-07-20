extends Character
class_name Enemy


onready var current_health = data_model.max_health

var data_model = null
var data_model_path = null

var is_defeated = false
var is_locked = false

var behavior_idx = 0

signal input_signal


func _ready():
	._ready()
	
	assert(data_model != null)


func play_turn():
	yield(get_tree(), "idle_frame")
	print("enemy playing")
	
#	var current_enemy = Globals.enemy_loader(self)
#	var ebi = current_enemy.dm.damage_behavior_idx
#	var chosen_skill = Globals.player.chosen_skill
#	var skill_data = Globals.player.skill_data
	
#	for defend_phase in chosen_skill.defend_arrows:
#		yield(_summon_wheel("enemy_attack"), "completed")
#
#		# Setting enemy's damage areas
#		wheel_ins.set_area_behavior(current_enemy.dm.behaviors_ins.attack_behavior)
#		wheel_ins.set_enemy_behavior_index(ebi)
#
#		# Setting player's defend arrows
#		wheel_ins.set_arrow_behavior(chosen_skill.behaviors_ins.defend_behavior)
#		wheel_ins.set_skill_data(skill_data)
#
#		# Set the actual areas and arrows
#		wheel_ins.set_area(current_enemy.dm.damage_areas[ebi], current_enemy.dm.behaviors_ins.randomize_attack)
#		wheel_ins.set_arrows(defend_phase, chosen_skill.behaviors_ins.randomize_defend)
#
#		# Draw arrows and areas
#		wheel_ins.draw_areas()
#		wheel_ins.draw_arrows()
#
#		var result = yield(wheel_ins.action(), "completed")
#		current_enemy.dm.damage_areas[ebi] = result[0]
#		var processed_arrows = result[1]
#		skill_data = result[2]
#
#		_check_result(current_enemy.dm.damage_areas[ebi], processed_arrows)
#		if chosen_skill.conditions_ins.second_condition(processed_arrows, skill_data):
#			print("gained ", chosen_skill.hp_bonus," hp!")
#			Globals.player.add_hp(chosen_skill.hp_bonus)
#
#		if _deal_damage(processed_arrows):
#			yield(_destroy_wheel(), "completed")
#			_end_turn()
#			return true
#
#		yield(get_tree().create_timer(.5), "timeout")
#		yield(_destroy_wheel(), "completed")
#		yield(get_tree().create_timer(.5), "timeout")
		
	_end_turn()
	return false


func select_behavior(behavior):
	.select_behavior(behavior)
	
	match current_behavior:
		Behavior.ATTACK: behavior_idx = rng.randi_range(0, data_model.damage_areas.size() - 1)
		Behavior.DEFEND: behavior_idx = rng.randi_range(0, data_model.soul_areas.size() - 1)
	
	data_model.behaviors = data_model.behaviors.new(current_behavior)


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


func reset_data_model():
	var new_dm = Round.load_enemy_data_model(data_model_path)
	data_model = new_dm


func _end_turn():
	reset_data_model()
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

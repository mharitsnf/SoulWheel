extends Character
class_name Enemy


onready var current_health = data_model.max_health

var color
var radius

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
	print("enemy playing")
	
	for phase_number in range(Round.chosen_skill.defend_arrows.size()):
		
		# summon wheel with defend phase for the player
		_summon_wheel(Round.WheelPhase.DEFEND)
		
		# select behavior for attack.
		select_behavior(Behavior.ATTACK)
		
		# set temporary variables
		var attack_pattern = data_model.attack_patterns[behavior_idx].duplicate(true)
		var arrows = Round.chosen_skill.defend_arrows[phase_number].duplicate(true)
		
		# preprocess the areas and arrows
		attack_pattern = data_model.behaviors.preprocess.call_func(
			attack_pattern,
			behavior_idx
		)
		arrows = Round.chosen_skill.behaviors.preprocess_d.call_func(
			arrows,
			phase_number
		)
		
		# draw the areas and arrows
		wheel_ins.draw_areas(attack_pattern, self)
		wheel_ins.draw_arrows(arrows)
		
		# process the areas and arrows
		var result = yield(wheel_ins.action(
			[data_model.behaviors.process, Round.chosen_skill.behaviors.process_d],
			[attack_pattern, arrows],
			{ "ebi": behavior_idx, "phase_number": phase_number }
		), "completed")
		attack_pattern = result[0]
		arrows = result[1]
		
		# postprocess the areas and arrows
		attack_pattern = data_model.behaviors.postprocess.call_func(
			attack_pattern,
			behavior_idx
		)
		arrows = Round.chosen_skill.behaviors.postprocess_d.call_func(
			arrows,
			phase_number
		)
		
		# check result
		_check_and_append_result(attack_pattern, arrows)
		
		# deal damage to the player and return if the player is defeated
		if _deal_damage(arrows):
			yield(get_tree().create_timer(.5), "timeout")
			_destroy_wheel()
			
			_end_turn()
			return true
		
		# assess second condition
		var fc_res = Round.chosen_skill.conditions.second_condition.call_func(arrows, phase_number)
		if fc_res:
			Round.player.add_hp(Round.chosen_skill.hp_bonus)
		
		# reset the arrows struck by array
		for arrow in arrows:
			arrow.struck_by = []
		
		# destroy wheel
		yield(get_tree().create_timer(.5), "timeout")
		_destroy_wheel()
		
	_end_turn()
	return false


# Select between two behaviors: attack and defend.
# Select a random behavior for the processing turn as well
func select_behavior(behavior):
	.select_behavior(behavior)
	
	match current_behavior:
		Behavior.ATTACK: behavior_idx = rng.randi_range(0, data_model.attack_patterns.size() - 1)
		Behavior.DEFEND: behavior_idx = rng.randi_range(0, data_model.defend_patterns.size() - 1)
	
	data_model.behaviors = data_model.behaviors.new(current_behavior)


func _check_and_append_result(pattern, arrows):
	for area in pattern.areas:
		var area_angle : Vector2 = _generate_angles(area.rot_angle, area.thickness)
		
		for arrow in arrows:
			var arrow_angle : Vector2 = _generate_angles(arrow.rot_angle, arrow.thickness)
			
			if _is_hit(arrow_angle, area_angle):
				arrow.struck_by.append(area)


func _deal_damage(arrows):
	for arrow in arrows:
		for area in arrow.struck_by:
			if Round.player.take_damage(area.damage): return true
	
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
	$Shaker.start("position", position, 1)
	
	if new_health <= 0:
		return true
	
	return false


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("input_signal")

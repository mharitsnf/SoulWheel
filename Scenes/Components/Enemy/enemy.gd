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
	
	for phase_number in range(Round.chosen_skill.defend_patterns.size()):
		
		# summon wheel with defend phase for the player
		_summon_wheel(Round.WheelPhase.DEFEND)
		
		# select behavior for attack.
		select_behavior(Behavior.ATTACK)
		
		# set temporary variables
		var attack_pattern = data_model.attack_patterns[behavior_idx].duplicate(true)
		var defend_pattern = Round.chosen_skill.defend_patterns[phase_number].duplicate(true)
		
		# preprocess the areas and arrows
		data_model.behaviors.preprocess.call_func(
			attack_pattern,
			behavior_idx
		)
		Round.chosen_skill.behaviors.preprocess_d.call_func(
			defend_pattern,
			phase_number
		)
		
		# draw the areas and arrows
		Nodes.wheel.draw_areas(attack_pattern, self)
		Nodes.wheel.draw_arrows(defend_pattern)
		
		# process the areas and arrows
		var _did_player_acted = yield(Nodes.wheel.action(
			[data_model.behaviors, Round.chosen_skill.behaviors],
			[attack_pattern, defend_pattern],
			{ "ebi": behavior_idx, "phase_number": phase_number }
		), "completed")
		
		# postprocess the areas and arrows
		data_model.behaviors.postprocess.call_func(
			attack_pattern,
			behavior_idx
		)
		Round.chosen_skill.behaviors.postprocess_d.call_func(
			defend_pattern,
			phase_number
		)
		
		# check result
		_check_and_append_result(attack_pattern, defend_pattern)
		
		# deal damage to the player and return if the player is defeated
		if _deal_damage(defend_pattern):
			yield (get_tree().create_timer(.5), "timeout")
			_destroy_wheel()
			
			_end_turn()
			return true
		
		# assess second condition
		var sc_res = Round.chosen_skill.conditions.second_condition.call_func(defend_pattern, phase_number)
		if sc_res:
			Round.player.add_hp(Round.chosen_skill.hp_bonus)
		
		# reset the arrows struck by array
		for arrow in defend_pattern.arrows:
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


func _check_and_append_result(enemy_pattern, player_pattern):
	for area in enemy_pattern.areas:
		var area_angle : Vector2 = Round.generate_angles(area.rot_angle, area.thickness)
		
		for arrow in player_pattern.arrows:
			var arrow_angle : Vector2 = Round.generate_angles(arrow.rot_angle, arrow.thickness)
			
			if Round.is_hit(arrow_angle, area_angle):
				arrow.struck_by.append(area)


func _deal_damage(pattern):
	for arrow in pattern.arrows:
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

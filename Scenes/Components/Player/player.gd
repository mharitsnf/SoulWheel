extends Character
class_name Player


export(PackedScene) var skill_hud : PackedScene
var skill_hud_ins : Control = null

export var data_model : Resource

signal skill_button_pressed


func _ready():
	._ready()
	
	assert(data_model)
	assert(data_model is PlayerDataModel)
	rng.randomize()
	
	Round.player = self
	
	_update_hp_hud()


func take_damage(damage):
	var new_health = data_model.current_health - damage
	data_model.current_health = max(0, new_health)
	$Shaker.start("position", position, 1)
	
	_update_hp_hud()
	
	if new_health <= 0:
		return true
	
	return false


func play_turn():
	print("player playing")
	
	# PHASE 0: Reset previous round status
	_start_turn()
	
	# PHASE 1: Skill selection
	yield(_summon_skill_hud(), "completed")
	yield(self, "skill_button_pressed") # Wait for player to select a skill
	yield(_destroy_skill_hud(), "completed")
	
	# PHASE 2: Soul lock phase
	for character in turn_manager.get_children():
		if character is Enemy:
			
			# summon the wheel and draw the outlines
			_summon_wheel(Round.WheelPhase.SOUL_LOCK)
			
			# draw locked areas
			wheel_ins.draw_locked_areas(turn_manager.get_children())
			
			# set the enemy current behavior for defend (soul areas)
			character.select_behavior(Character.Behavior.DEFEND)
			
			# set temporary variables
			var defend_pattern = character.data_model.defend_patterns[character.behavior_idx].duplicate(true)
			var enemy_behavior_idx = character.behavior_idx
			
			# preprocess the areas
			defend_pattern = character.data_model.behaviors.preprocess.call_func(defend_pattern, enemy_behavior_idx)
			
			# draw the areas
			wheel_ins.draw_areas(defend_pattern, character)
			
			# process the areas
			var result = yield(wheel_ins.action(
				[character.data_model.behaviors],
				[defend_pattern],
				{ "ebi": enemy_behavior_idx }
			), "completed")
			defend_pattern = result.patterns[0]
			
			# postprocess the areas (if any)
			defend_pattern = character.data_model.behaviors.postprocess.call_func(
				defend_pattern,
				enemy_behavior_idx
			)
			
			# set the updated soul areas to the enemy data model
			character.data_model.defend_patterns[character.behavior_idx] = defend_pattern
			character.is_locked = true
			
			# Destroy
			_destroy_wheel()
			
			yield(get_tree().create_timer(1), "timeout")
	
	# PHASE 3: Soul Strike phase
	# Loop for each attacking phases
	for phase_number in range(Round.chosen_skill.attack_patterns.size()):
		
		# summon the wheel and draw the outlines
		_summon_wheel(Round.WheelPhase.SOUL_STRIKE)
		
		# draw locked areas
		wheel_ins.draw_locked_areas(turn_manager.get_children())
		
		# set temporary variables
		var pattern = Round.chosen_skill.attack_patterns[phase_number].duplicate(true)
		
		# preprocess the arrows for each round
		pattern = Round.chosen_skill.behaviors.preprocess_a.call_func(
			pattern,
			phase_number
		)
		
		# draw the arrows
		wheel_ins.draw_arrows(pattern)
		
		# process the arrows
		var result = yield(wheel_ins.action(
			[Round.chosen_skill.behaviors],
			[pattern],
			{ "phase_number" : phase_number }
		), "completed")
		pattern = result.patterns[0]
		
		# postprocess the arrows (if any)
		pattern = Round.chosen_skill.behaviors.postprocess_a.call_func(
			pattern,
			phase_number
		)
		
		# set the updated arrows to the chosen skill attack arrows
		Round.chosen_skill.attack_patterns[phase_number] = pattern
		
		# check overlapping areas between arrows and areas for each enemies
		for character in turn_manager.get_children():
			if character is Enemy:
				var enemy_defend_pattern = character.data_model.defend_patterns[character.behavior_idx]
				_check_and_append_result(character, enemy_defend_pattern, pattern)
		
		# deal damage to the enemies
		_deal_damage(pattern)
		
		# assess first condition
		var fc_res = Round.chosen_skill.conditions.first_condition.call_func(pattern, phase_number)
		if fc_res:
			add_hp(Round.chosen_skill.hp_cost)
		
		# remove defeated enemies
		yield(_remove_defeated_enemies(turn_manager.get_children()), "completed")
		
		# if all the enemies are defeated
		if turn_manager.get_child_count() == 1 and turn_manager.get_child(0) == self:
			yield(get_tree().create_timer(0.5), "timeout")
			_destroy_wheel()
			_end_turn()
			return true
		
		# destroy wheel
		yield(get_tree().create_timer(0.5), "timeout")
		_destroy_wheel()
	
	_end_turn()
	return false


# Append enemies struck by an arrow into the arrow's list
func _check_and_append_result(enemy, enemy_pattern, player_pattern):
	for area in enemy_pattern.areas:
		var area_angle : Vector2 = _generate_angles(area.rot_angle, area.thickness)

		for arrow in player_pattern.arrows:
			var arrow_angle : Vector2 = _generate_angles(arrow.rot_angle, arrow.thickness)

			if _is_hit(arrow_angle, area_angle):
				arrow.enemies_struck.append(enemy)


# Deal damage based on the updated arrow's list
func _deal_damage(pattern):
	for arrow in pattern.arrows:
		for enemy in arrow.enemies_struck:
			enemy.is_defeated = enemy.take_damage(arrow.damage)
			print(arrow, " struck ", enemy.name, "! enemy health: ", enemy.current_health)


func _remove_defeated_enemies(characters):
	yield(get_tree(), "idle_frame")
	for character in characters:
		if character is Enemy and character.is_defeated:
				yield(_defeat_enemy(character), "completed")


func _defeat_enemy(enemy):
	enemy.queue_free()
	yield(get_tree(), "idle_frame")


func _start_turn():
	._start_turn()
	
	Round.chosen_skill = null
	data_model.skills = []
	
	for skill_path in data_model.skill_paths:
		data_model.skills.append(Round.load_skill(skill_path))


func _end_turn():
	# Reset any values that were updated this round,
	# most notably the soul areas, damage areas, etc.
	for character in turn_manager.get_children():
		if character is Enemy:
			character.is_locked = false
			character.reset_data_model()
	
	._end_turn()


func _summon_skill_hud():
	skill_hud_ins = skill_hud.instance()
	Nodes.root.add_child(skill_hud_ins)
	skill_hud_ins.initialize(data_model.skills)
	
#	Globals.hp_hud.move_up()
	yield(skill_hud_ins.show(), "completed")


func _destroy_skill_hud():
#	Globals.hp_hud.move_down()
	yield(skill_hud_ins.hide_and_destroy(), "completed")
	skill_hud_ins = null


func _wager_hp(amount):
	data_model.current_health = max(1, data_model.current_health - amount)
	_update_hp_hud()


func add_hp(amount):
	data_model.current_health += amount
	_update_hp_hud()


func _update_hp_hud():
	Nodes.hp_hud.update_health(data_model.current_health)


func _on_skill_button_pressed(btn_idx):
	# choose the skill
	Round.chosen_skill = data_model.skills[btn_idx]
	
	# wager the HP
	_wager_hp(Round.chosen_skill.hp_cost)
	
	# emit the signal button is pressed
	emit_signal("skill_button_pressed")

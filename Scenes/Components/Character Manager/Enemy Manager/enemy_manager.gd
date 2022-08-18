extends CharacterManager
class_name EnemyManager



# =============== Turn management ===============
func first_turn():
	pass


func _start_turn():
	pass


func play_turn():
	_start_turn()
	
	# summon wheel
	_summon_wheel(Round.WheelPhase.DEFENSE)
	
	for phase_number in range(Round.chosen_skill.defense_patterns.size()):
		
		# --- setup player data ---
		var defense_pattern = Round.chosen_skill.defense_patterns[phase_number].duplicate(true)
		
		# reset arrows
		Round.player.reset_arrows(defense_pattern)
		
		# preprocess the arrows
		Round.chosen_skill.behaviors.preprocess_d.call_func(
			defense_pattern,
			phase_number
		)
		
		# draw ther arrows
		Nodes.wheel.draw_arrows(defense_pattern)
		
		# --- setup enemy data for all enemies ---
		var behaviors = []
		var attack_patterns = []
		var ebis = []
		var indexes = []
		for enemy in get_children():
			if enemy is Enemy:
				# select behavior
				enemy.select_behavior(Enemy.Behavior.ATTACK)
				
				var attack_pattern = enemy.data_model.attack_patterns[enemy.behavior_idx].duplicate(true)
				
				# reset the areas
				enemy.reset_areas(attack_pattern)
				
				# preprocess the areas
				enemy.data_model.behaviors.preprocess.call_func(
					attack_pattern,
					enemy.behavior_idx
				)
				
				behaviors.append(enemy.data_model.behaviors)
				attack_patterns.append(attack_pattern)
				ebis.append(enemy.behavior_idx)
				indexes.append(enemy.get_index())
				
				# draw the areas in the wheel
				Nodes.wheel.draw_areas(attack_pattern, enemy)
		
		# process the areas and arrows
		var _did_player_acted = yield(Nodes.wheel.action(
			[behaviors, Round.chosen_skill.behaviors],
			[attack_patterns, defense_pattern],
			{ "ebi": ebis, "phase_number": phase_number, "index": indexes }
		), "completed")
		
		# postprocess player arrows
		Round.chosen_skill.behaviors.postprocess_d.call_func(
			defense_pattern,
			phase_number
		)
		
		for enemy in get_children():
			if enemy is Enemy:
				
				# postprocess enemy pattern
				var attack_pattern = enemy.data_model.attack_patterns[enemy.behavior_idx].duplicate(true)
				enemy.data_model.behaviors.postprocess.call_func(
					attack_pattern,
					enemy.behavior_idx
				)
				
				enemy.check_overlaps(attack_pattern, defense_pattern)
		
		# accumulate the damage from the areas
		Round.player.accumulate_damage(defense_pattern)
		
		# if player is dead
		if Round.player.take_damage():
			yield(get_tree().create_timer(.5), "timeout")
			
			# destroy wheel and end turn, still fighting
			_destroy_wheel()
			_end_turn()
			return true
	
		# assess second condition
		var sc = Round.chosen_skill.conditions.sc(defense_pattern)
		if sc:
			Round.player.add_hp(Round.chosen_skill.hp_bonus)
	
	
	yield(get_tree().create_timer(.5), "timeout")
	
	# destroy wheel and end turn, still fighting
	_destroy_wheel()
	_end_turn()
	return false


func _end_turn():
	for enemy in get_children():
		enemy.reset()
	

func final_turn():
	pass

# ===============================================

# =============== Public functions ===============
func remove_defeated_enemies():
	for enemy in get_children():
		if enemy is Enemy and enemy.is_defeated:
			enemy.destroy()

# ================================================

# =============== Private functions ===============
func _ready():
	Round.enemy_manager = self

# =================================================

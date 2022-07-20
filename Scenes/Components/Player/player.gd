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
			_summon_wheel(Wheel.Phases.SOUL_LOCK)
			
			# draw locked areas
			wheel_ins.draw_locked_areas(turn_manager.get_children())
			
			# set the enemy current behavior for defend (soul areas)
			character.select_behavior(Character.Behavior.DEFEND)
			
			# set temporary variables
			var soul_areas = character.data_model.soul_areas[character.behavior_idx]
			var enemy_behavior_idx = character.behavior_idx
			
			# preprocess the areas
			soul_areas = character.data_model.behaviors.preprocess.call_func(soul_areas, enemy_behavior_idx)
			
			# draw the areas
			wheel_ins.draw_areas(soul_areas)
			
			# process the areas
			soul_areas = yield(wheel_ins.action(
				character.data_model.behaviors.process,
				[soul_areas],
				{ "ebi": enemy_behavior_idx }
			), "completed")
			
			# postprocess the areas (if any)
			soul_areas = character.data_model.behaviors.postprocess.call_func(soul_areas, enemy_behavior_idx)
			
			# set the updated soul areas to the enemy data model
			character.data_model.soul_areas[character.behavior_idx] = soul_areas
			character.is_locked = true
			
			# Destroy
			_destroy_wheel()
			
			yield(get_tree().create_timer(1), "timeout")
	
	# PHASE 3: Soul Strike phase
	# Loop for each attacking phases
	for phase_number in range(Round.chosen_skill.attack_arrows.size()):
		
		# summon the wheel and draw the outlines
		_summon_wheel(Wheel.Phases.SOUL_STRIKE)
		
		# draw locked areas
		wheel_ins.draw_locked_areas(turn_manager.get_children())
		
		# set the current player behavior for attack
		select_behavior(Behavior.ATTACK)
		
		# set temporary variables
		var arrows = Round.chosen_skill.attack_arrows[phase_number]
		
		# preprocess the arrows for each round
		arrows = Round.chosen_skill.behaviors.preprocess.call_func(
			arrows,
			phase_number
		)
		
		# draw the arrows
		wheel_ins.draw_arrows(arrows)
		
		# process the arrows
		arrows = yield(wheel_ins.action(
			Round.chosen_skill.behaviors.process,
			[arrows],
			{ "phase_number": phase_number }
		), "completed")
		
		# postprocess the arrows (if any)
		arrows = Round.chosen_skill.behaviors.postprocess.call_func(
			arrows,
			phase_number
		)
		
		# check overlapping areas between arrows and areas for each enemies
		for character in turn_manager.get_children():
			if character is Enemy:
				var areas = character.data_model.soul_areas[character.behavior_idx]
				_check_and_append_result(character, areas, arrows)
		
		# deal damage to the enemies
		_deal_damage(arrows)
		
		# remove defeated enemies
		yield(_remove_defeated_enemies(turn_manager.get_children()), "completed")
		
		if turn_manager.get_child_count() == 1 and turn_manager.get_child(0) == self:
			yield(get_tree().create_timer(0.5), "timeout")
			_destroy_wheel()
			_end_turn()
			return true
		
		# destroy wheel
		yield(get_tree().create_timer(0.5), "timeout")
		_destroy_wheel()
	
	# Soul strike phase
#	var _i = 0
#	for attack_phase in chosen_skill.attack_arrows:
#		pass 
		
#		yield(_summon_wheel("strike"), "completed")
#
#		wheel_ins.draw_soul_areas(enemies_to_process)
#
#		wheel_ins.set_arrow_behavior(chosen_skill.behaviors_ins.attack_behavior)
#		wheel_ins.set_skill_data(chosen_skill.skill_data)
#
#		wheel_ins.set_arrows(attack_phase, chosen_skill.behaviors_ins.randomize_attack)
#		wheel_ins.draw_arrows()
#
#		var result = yield(wheel_ins.action(), "completed")
#		var processed_arrows = result[0]
#		skill_data = result[1]
#
#		for enemy in enemies_to_process:
#			var areas_to_check = enemy.dm.soul_areas[enemy.dm.soul_behavior_idx]
#			_check_result(enemy, areas_to_check, processed_arrows)
#
#		_deal_damage(processed_arrows)
#
#		if chosen_skill.conditions_ins.first_condition(processed_arrows, skill_data): add_hp(chosen_skill.hp_cost)
#
#		yield(_remove_defeated_enemies(), "completed")
#
#		if turn_manager.get_child_count() == 1 and turn_manager.get_child(0) == self:
#			yield(get_tree().create_timer(0.5), "timeout")
#			yield(_destroy_wheel(), "completed")
#			_end_turn()
#			return true
#
#		yield(get_tree().create_timer(0.5), "timeout")
#		yield(_destroy_wheel(), "completed")
#
#		_i += 1
	
	_end_turn()
	return false


func select_behavior(behavior):
	.select_behavior(behavior)
	Round.chosen_skill.behaviors = Round.chosen_skill.behaviors.new(current_behavior)


# Append enemies struck by an arrow into the arrow's list
func _check_and_append_result(enemy, areas, arrows):
	for area in areas:
		var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)

		for arrow in arrows:
			var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)

			if _is_hit(arrow_angle, area_angle):
				arrow.enemies_struck.append(enemy)


# Deal damage based on the updated arrow's list
func _deal_damage(arrows):
	for arrow in arrows:
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


func _put_card_on_deck(path):
	Globals.skill_deck.append(Globals.attack_loader(path))


func _summon_skill_hud():
	skill_hud_ins = skill_hud.instance()
	Globals.root.add_child(skill_hud_ins)
	skill_hud_ins.initialize(data_model.skills)
	
	Globals.hp_hud.move_up()
	yield(skill_hud_ins.show(), "completed")


func _destroy_skill_hud():
	Globals.hp_hud.move_down()
	yield(skill_hud_ins.hide_and_destroy(), "completed")
	skill_hud_ins = null


func _wager_hp(amount):
	data_model.current_health = max(1, data_model.current_health - amount)
	_update_hp_hud()


func add_hp(amount):
	data_model.current_health += amount
	_update_hp_hud()


func _update_hp_hud():
	Globals.hp_hud.update_health(data_model.current_health)


func _on_skill_button_pressed(btn_idx):
	Round.chosen_skill = data_model.skills[btn_idx]
	
#	chosen_skill = Globals.skill_deck[btn_idx]
#	skill_data = chosen_skill.skill_data.duplicate(true)
#
#	_wager_hp(chosen_skill.hp_cost)
#
#	print("skill costs ", chosen_skill.hp_cost, " hp!")

	emit_signal("skill_button_pressed")

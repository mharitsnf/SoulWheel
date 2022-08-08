extends Character
class_name Player


var arrow_template = preload("res://Resources/Arrow/arrow.gd")

export var data_model : Resource


# =============== Public functions ===============
func reset_skill():
	Round.chosen_skill = null
	Modify.clear_modifications()
	data_model.reset_slots()


func load_slots():
	# Load skills
	for i in range(data_model.slot_paths.size()):
		var path = data_model.slot_paths[i]
	
		if path:
			var possession = load(path).duplicate()
		
			match possession.type:
				Possession.Types.ATTACK_SKILL:
					_duplicate_attack_skill(possession)
				
				Possession.Types.SUPPORT_SKILL:
					pass
				
				Possession.Types.MODIFIER:
					for modification in possession.modifications:
						for idx in modification.rel_idxs:
							data_model.slots[(i + idx) % 6].affected_by.append(i)
		
			data_model.slots[i].possession = possession


func choose_skill(btn_idx):
	var slot_data = data_model.slots[btn_idx]
	
	# set the chosen skill
	Round.chosen_skill = slot_data.possession
	
	# from the affected by array, get the modifications and add it to be
	# applied in the next turn
	for index in slot_data.affected_by:
		for mod in data_model.slots[index].possession.modifications:
			Modify.add_modifications(mod)


func reset_arrows(pattern):
	for arrow in pattern.arrows:
		arrow.reset()


func update_hp_hud():
	Nodes.hp_hud.set_health(data_model.health)


func wager_hp(amount):
	yield(hp_notification(-amount), "completed")
	data_model.health = max(1, data_model.health - amount)
	update_hp_hud()


func add_hp(amount):
	hp_notification(amount)
	data_model.health += amount
	update_hp_hud()


func deal_damage(pattern):
	for arrow in pattern.arrows:
		for enemy in arrow.enemies_struck:
			if !enemy.is_damage_dealt:
				var damage = arrow.damage * arrow.enemies_struck.count(enemy)
				enemy.is_defeated = enemy.take_damage(damage)
				enemy.is_damage_dealt = true


# Append enemies struck by an arrow into the arrow's list
func check_overlaps(enemy, enemy_pattern, player_pattern):
	for area in enemy_pattern.areas:
		var area_angle : Vector2 = Round.generate_angles(area.rot_angle, area.thickness)

		for arrow in player_pattern.arrows:
			var arrow_angle : Vector2 = Round.generate_angles(arrow.rot_angle, arrow.thickness)

			if Round.is_hit(arrow_angle, area_angle):
				arrow.enemies_struck.append(enemy)

# ================================================


# =============== Private functions ===============
func _ready():
	._ready()

	assert(data_model)
	assert(data_model is PlayerDataModel)

	Round.player = self

	update_hp_hud()


func _duplicate_attack_skill(skill):
	# create attack arrows
	var attack_patterns = []

	for phase in skill.attack_patterns:
		var new_phase = phase.duplicate()
		var new_arrows = []

		for arrow in phase.arrows:
			new_arrows.append(arrow_template.new(
				arrow.move_speed,
				arrow.rot_angle,
				arrow.thickness,
				arrow.damage)
			)

		new_phase.arrows = new_arrows
		attack_patterns.append(new_phase)

	skill.attack_patterns = attack_patterns

	# create defend arrows
	var defend_patterns = []

	for phase in skill.defend_patterns:
		var new_phase = phase.duplicate()
		var new_arrows = []

		for arrow in phase.arrows:
			new_arrows.append(arrow_template.new(
				arrow.move_speed,
				arrow.rot_angle,
				arrow.thickness)
			)

		new_phase.arrows = new_arrows
		defend_patterns.append(new_phase)

	skill.defend_patterns = defend_patterns

	# instantiate conditions
	skill.conditions = skill.conditions.new()
	skill.behaviors = skill.behaviors.new()

# =================================================

#
#enum {
#	SKILL_HEXAGON,
#	SKILL_CONFIRM,
#	SKILL_CARD
#}
#
#export(PackedScene) var hexagonal_slot_scn
#export(PackedScene) var skill_confirmation_scn
#export(PackedScene) var skill_card_scn
#var skill_hud
#
#export var data_model : Resource
#
#signal skill_button_pressed
#
#
#func _ready():
#	._ready()
#
#	assert(data_model)
#	assert(data_model is PlayerDataModel)
#	rng.randomize()
#
#	Round.player = self
#
#	_update_hp_hud()
#
#
#func take_damage(damage):
#	.take_damage(damage)
#
#	var new_health = data_model.current_health - damage
#	data_model.current_health = max(0, new_health)
#
#	_update_hp_hud()
#
#	if new_health <= 0:
#		return true
#
#	return false
#
#
#func play_turn():
#	# PHASE 0: Reset previous round status
#	_start_turn()
#
#	# PHASE 1: Skill selection
#	yield(_summon_skill_hud(SKILL_HEXAGON), "completed")
#	yield(self, "skill_button_pressed")
#	yield(_destroy_skill_hud(1), "completed")
#
#	yield(_wager_hp(Round.chosen_skill.hp_cost), "completed")
#
#	# PHASE 2: Soul lock phase
#	for character in turn_manager.get_children():
#		if character is Enemy:
#
#			# summon the wheel and draw the outlines
#			_summon_wheel(Round.WheelPhase.SOUL_LOCK)
#
#			# draw locked areas
#			Nodes.wheel.draw_locked_areas(turn_manager.get_children())
#
#			# set the enemy current behavior for defend (soul areas)
#			character.select_behavior(Enemy.Behavior.DEFEND)
#
#			# set temporary variables
#			var defend_pattern = character.data_model.defend_patterns[character.behavior_idx].duplicate(true)
#			var enemy_behavior_idx = character.behavior_idx
#
#			# reset areas
#			Round.reset_elements(defend_pattern)
#
#			# preprocess the areas
#			character.data_model.behaviors.preprocess.call_func(defend_pattern, enemy_behavior_idx)
#
#			# draw the areas
#			Nodes.wheel.draw_areas(defend_pattern, character)
#
#			# process the areas
#			var _did_player_acted = yield(Nodes.wheel.action(
#				[character.data_model.behaviors],
#				[defend_pattern],
#				{ "ebi": enemy_behavior_idx, "index": character.get_index() }
#			), "completed")
#
#			# postprocess the areas (if any)
#			character.data_model.behaviors.postprocess.call_func(
#				defend_pattern,
#				enemy_behavior_idx
#			)
#
#			# set the updated soul areas to the enemy data model
#			character.is_locked = true
#
#			# Destroy
#			_destroy_wheel()
#
#			yield(get_tree().create_timer(.5), "timeout")
#
#	yield(get_tree().create_timer(.5), "timeout")
#
#	# PHASE 3: Soul Strike phase
#	# Loop for each attacking phases
#	for phase_number in range(Round.chosen_skill.attack_patterns.size()):
#
#		# summon the wheel and draw the outlines
#		_summon_wheel(Round.WheelPhase.SOUL_STRIKE)
#
#		# draw locked areas
#		Nodes.wheel.draw_locked_areas(turn_manager.get_children())
#
#		# set temporary variables
#		var pattern = Round.chosen_skill.attack_patterns[phase_number].duplicate(true)
#
#		# reset arrows
#		Round.reset_elements(pattern)
#
#		# preprocess the arrows for each round
#		Round.chosen_skill.behaviors.preprocess_a.call_func(
#			pattern,
#			phase_number
#		)
#
#		# draw the arrows
#		Nodes.wheel.draw_arrows(pattern)
#
#		# process the arrows
#		var _did_player_acted = yield(Nodes.wheel.action(
#			[Round.chosen_skill.behaviors],
#			[pattern],
#			{ "phase_number" : phase_number }
#		), "completed")
#
#		# postprocess the arrows (if any)
#		Round.chosen_skill.behaviors.postprocess_a.call_func(
#			pattern,
#			phase_number
#		)
#
#		# apply modifiers
#		Modify.apply_modifiers(pattern, Modify.TYPE_ARROW)
#
#		# check overlapping areas between arrows and areas for each enemies
#		for character in turn_manager.get_children():
#			if character is Enemy:
#				var enemy_defend_pattern = character.data_model.defend_patterns[character.behavior_idx]
#				_check_and_append_result(character, enemy_defend_pattern, pattern)
#
#		# deal damage to the enemies
#		_deal_damage(pattern)
#
#		# assess first condition
#		var fc_res = Round.chosen_skill.conditions.first_condition.call_func(pattern, phase_number)
#		if fc_res:
#			add_hp(Round.chosen_skill.hp_cost)
#
#		# remove defeated enemies
#		yield(_remove_defeated_enemies(turn_manager.get_children()), "completed")
#
#		# if all the enemies are defeated
#		if turn_manager.get_child_count() == 1 and turn_manager.get_child(0) == self:
#			yield(get_tree().create_timer(0.5), "timeout")
#			_destroy_wheel()
#			_end_turn()
#			return true
#
#		# destroy wheel
#		yield(get_tree().create_timer(0.5), "timeout")
#		_destroy_wheel()
#
#	_end_turn()
#	return false
#
#
## Append enemies struck by an arrow into the arrow's list
#func _check_and_append_result(enemy, enemy_pattern, player_pattern):
#	for area in enemy_pattern.areas:
#		var area_angle : Vector2 = Round.generate_angles(area.rot_angle, area.thickness)
#
#		for arrow in player_pattern.arrows:
#			var arrow_angle : Vector2 = Round.generate_angles(arrow.rot_angle, arrow.thickness)
#
#			if Round.is_hit(arrow_angle, area_angle):
#				arrow.enemies_struck.append(enemy)
#
#
## Deal damage based on the updated arrow's list
#func _deal_damage(pattern):
#	for arrow in pattern.arrows:
#		for enemy in arrow.enemies_struck:
#			if !enemy.is_damage_dealt:
#				var damage = arrow.damage * arrow.enemies_struck.count(enemy)
#				enemy.is_defeated = enemy.take_damage(damage)
#				enemy.is_damage_dealt = true
#
#
#func _remove_defeated_enemies(characters):
#	yield(get_tree(), "idle_frame")
#	for character in characters:
#		if character is Enemy and character.is_defeated:
#				yield(_defeat_enemy(character), "completed")
#
#
#func _defeat_enemy(enemy):
#	enemy.queue_free()
#	yield(get_tree(), "idle_frame")
#
#
#func _start_turn():
#	._start_turn()
#
#	Round.chosen_skill = null
#	Modify.clear_modifications()
#	data_model.reset_slots()
#
#	# Load skills
#	for i in range(data_model.slot_paths.size()):
#		var path = data_model.slot_paths[i]
#
#		if path:
#			var possession = load(path).duplicate()
#
#			match possession.type:
#				Possession.Types.ATTACK_SKILL: Round.duplicate_attack_skill(possession)
#				Possession.Types.SUPPORT_SKILL: pass
#
#			data_model.slots[i].possession = possession
#
#
#	# Load modifiers
#	for i in range(data_model.slot_paths.size()):
#		var path = data_model.slot_paths[i]
#
#		if path:
#			var possession = load(path).duplicate()
#
#			if possession.type == Possession.Types.MODIFIER:
#				for modification in possession.modifications:
#					for idx in modification.rel_idxs:
#						data_model.slots[(i + idx) % 6].affected_by.append(i)
#
#
#func _end_turn():
#	# Reset any values that were updated this round,
#	# most notably the soul areas, damage areas, etc.
#	for character in turn_manager.get_children():
#		if character is Enemy:
#			character.is_locked = false
#			character.is_damage_dealt = false
#			character.reset_data_model()
#
#	._end_turn()
#
#
#func _wager_hp(amount):
#	yield(hp_notification(-amount), "completed")
#	data_model.current_health = max(1, data_model.current_health - amount)
#	_update_hp_hud()
#
#
#func add_hp(amount):
#	hp_notification(amount)
#	data_model.current_health += amount
#	_update_hp_hud()
#
#
#func _update_hp_hud():
#	Nodes.hp_hud.update_health(data_model.current_health)
#
#
#func _compile_permanent_modifiers(slots, indexes):
#	for index in indexes:
#		for mod in slots[index].possession.modifications:
#			var key = mod.key
#
#			if !Modify.modifications.has(key):
#				Modify.modifications[key] = {
#					"amount": 0
#				}
#
#			Modify.modifications[key].amount += mod.amount
#
#
#func _summon_skill_hud(type, args = []):
#	match type:
#		SKILL_HEXAGON: yield(_summon_hexagonal_slot(), "completed")
#		SKILL_CONFIRM: yield(_summon_skill_confirmation(args[0], args[1], args[2]), "completed")
#		SKILL_CARD: yield(_summon_skill_card(args[0], args[1]), "completed")
#
#
#func _destroy_skill_hud(direction = -1):
#	if skill_hud.name == "SkillConfirmation":
#		yield(skill_hud.destroy(direction), "completed")
#	else:
#		yield(skill_hud.destroy(), "completed")
#	skill_hud = null
#
#
#func _summon_hexagonal_slot():
#	skill_hud = hexagonal_slot_scn.instance()
#	Nodes.root.add_child(skill_hud)
#	yield(skill_hud.initialize(data_model.slots), "completed")
#
#func _summon_skill_confirmation(slot_data, btn_idx, direction):
#	skill_hud = skill_confirmation_scn.instance()
#	Nodes.root.add_child(skill_hud)
#	yield(skill_hud.initialize(slot_data, btn_idx, direction), "completed")
#
#
#func _summon_skill_card(slot_data, btn_idx):
#	skill_hud = skill_card_scn.instance()
#	Nodes.root.add_child(skill_hud)
#	yield(skill_hud.initialize(slot_data, btn_idx), "completed")
#
#
#func _on_hexagon_button_pressed(slot_data, btn_idx):
#	yield(_destroy_skill_hud(), "completed")
#	yield(_summon_skill_hud(SKILL_CONFIRM, [slot_data, btn_idx, -1]), "completed")
#
#
#func _on_skill_confirmed(btn_idx):
#	# choose the skill
#	Round.chosen_skill = data_model.slots[btn_idx].possession
#	_compile_permanent_modifiers(data_model.slots, data_model.slots[btn_idx].affected_by)
#
#	# emit the signal button is pressed
#	emit_signal("skill_button_pressed")
#
#
#func _on_skill_info_pressed(slot_data, btn_idx):
#	yield(_destroy_skill_hud(1), "completed")
#	yield(_summon_skill_hud(SKILL_CARD, [slot_data, btn_idx]), "completed")
#
#
#func _on_skill_back_pressed(type, slot_data, btn_idx):
#	yield(_destroy_skill_hud(), "completed")
#
#	match type:
#		SKILL_CONFIRM: yield(_summon_skill_hud(SKILL_HEXAGON), "completed")
#		SKILL_CARD: yield(_summon_skill_hud(SKILL_CONFIRM, [slot_data, btn_idx, 1]), "completed")
#

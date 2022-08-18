extends CharacterManager
class_name PlayerManager


enum {
	SKILL_HEXAGON,
	SKILL_CONFIRM,
	SKILL_CARD
}

export(PackedScene) var hexagonal_slot
export(PackedScene) var skill_confirmation
export(PackedScene) var skill_card
var skill_hud

var player : Player

signal skill_confirmed


# =============== Turn management ===============
func first_turn():
	player = get_child(0)


func _start_turn():
	._start_turn()
	player.reset_skill()
	player.load_slots()


func play_turn():
	yield(get_tree(), "idle_frame")
	
	# Setup turn before starting
	_start_turn()

	# Skill selection phase
	yield(_summon_skill_hud(SKILL_HEXAGON), "completed")
	yield(self, "skill_confirmed")
	yield(_destroy_skill_hud(1), "completed")

	yield(player.wager_hp(Round.chosen_skill.hp_cost), "completed")

	# Soul lock phase
	_summon_wheel(Round.WheelPhase.SOUL_LOCK)

	for character in Round.enemy_manager.get_children():
		if character is Enemy:
			# select enemy behavior
			character.select_behavior(Enemy.Behavior.DEFENSE)
			
			var defense_pattern = character.data_model.defense_patterns[character.behavior_idx].duplicate(true)
			var enemy_behavior_idx = character.behavior_idx
			
			# preprocess the areas
			character.reset_areas(defense_pattern)
			character.data_model.behaviors.preprocess.call_func(defense_pattern, enemy_behavior_idx)
			
			# draw the areas
			Nodes.wheel.draw_areas(defense_pattern, character)
			
			# process the areas
			var _did_player_acted = yield(Nodes.wheel.action(
				[character.data_model.behaviors],
				[defense_pattern],
				{ "ebi": enemy_behavior_idx, "index": character.get_index() }
			), "completed")
			
			# postprocess the areas
			character.data_model.behaviors.postprocess.call_func(
				defense_pattern,
				enemy_behavior_idx
			)
			
			# enemy done processing
			character.is_locked = true
			
			yield(get_tree().create_timer(.25), "timeout")
	
	# Soul strike phase
	Nodes.wheel.change_phase(Round.WheelPhase.SOUL_STRIKE)

	for phase_number in range(Round.chosen_skill.attack_patterns.size()):
		var pattern = Round.chosen_skill.attack_patterns[phase_number].duplicate(true)
		
		# reset the arrows
		player.reset_arrows(pattern)
		Round.chosen_skill.behaviors.preprocess_a.call_func(
			pattern,
			phase_number
		)
		
		# draw the arrows
		Nodes.wheel.draw_arrows(pattern)
		
		# process the arrows
		var _did_player_acted = yield(Nodes.wheel.action(
			[Round.chosen_skill.behaviors],
			[pattern],
			{ "phase_number" : phase_number }
		), "completed")
		
		# postprocess the arrows
		Round.chosen_skill.behaviors.postprocess_a.call_func(
			pattern,
			phase_number
		)
		
		# apply modifier to the arrows
		Modify.apply_modifiers(pattern, Modify.TYPE_ARROW)
		
		# check for overlaps between the arrows and areas
		for character in Round.enemy_manager.get_children():
			if character is Enemy:
				var enemy_defense_pattern = character.data_model.defense_patterns[character.behavior_idx]
				player.check_overlaps(character, enemy_defense_pattern, pattern)
		
		# deal damage to the enemies
		player.deal_damage(pattern)
		
		# check the first condition
		var fc = Round.chosen_skill.conditions.fc(pattern)
		if fc:
			player.add_hp(Round.chosen_skill.hp_cost)
		
		# remove defeated enemies
		Round.enemy_manager.remove_defeated_enemies()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	# destroy the wheel
	_destroy_wheel()
	
	# Setup turn after finishing
	_end_turn()
	
	# return true if the player won the round
	if Round.enemy_manager.get_child_count() == 0:
		return true
	
	# return true if there are still enemies around
	return false


func _end_turn():
	._end_turn()
	
	for enemy in Round.enemy_manager.get_children():
		enemy.reset()


func final_turn():
	pass

# ===============================================

# =============== Skill selection ===============
# Helper function for summoning skill HUD
func _summon_skill_hud(type, args = []):
	match type:
		SKILL_HEXAGON: yield(_summon_hexagonal_slot(), "completed")
		SKILL_CONFIRM: yield(_summon_skill_confirmation(args[0], args[1], args[2]), "completed")
		SKILL_CARD: yield(_summon_skill_card(args[0], args[1]), "completed")


# Summoning the hexagonal slot
func _summon_hexagonal_slot():
	skill_hud = hexagonal_slot.instance()
	Nodes.root.add_child(skill_hud)
	yield(skill_hud.initialize(player.data_model.slots), "completed")


# Summoning the skill confirmation UI
func _summon_skill_confirmation(slot_data, btn_idx, direction):
	skill_hud = skill_confirmation.instance()
	Nodes.root.add_child(skill_hud)
	yield(skill_hud.initialize(slot_data, btn_idx, direction), "completed")


# Summoning the skill card information UI
func _summon_skill_card(slot_data, btn_idx):
	skill_hud = skill_card.instance()
	Nodes.root.add_child(skill_hud)
	yield(skill_hud.initialize(slot_data, btn_idx), "completed")


# Helper function for destroying skill HUD
func _destroy_skill_hud(direction = -1):
	match skill_hud.name:
		"SkillConfirmation": yield(skill_hud.destroy(direction), "completed")
		_: yield(skill_hud.destroy(), "completed")
	
	skill_hud = null


func _on_skill_back_pressed(type, slot_data, btn_idx):
	yield(_destroy_skill_hud(), "completed")

	match type:
		SKILL_CONFIRM: yield(_summon_skill_hud(SKILL_HEXAGON), "completed")
		SKILL_CARD: yield(_summon_skill_hud(SKILL_CONFIRM, [slot_data, btn_idx, 1]), "completed")


func _on_hexagon_button_pressed(slot_data, btn_idx):
	yield(_destroy_skill_hud(), "completed")
	yield(_summon_skill_hud(SKILL_CONFIRM, [slot_data, btn_idx, -1]), "completed")


func _on_skill_confirmed(btn_idx):
	# choose the skill
	player.choose_skill(btn_idx)

	# emit the signal button is pressed
	emit_signal("skill_confirmed")


func _on_skill_info_pressed(slot_data, btn_idx):
	yield(_destroy_skill_hud(1), "completed")
	yield(_summon_skill_hud(SKILL_CARD, [slot_data, btn_idx]), "completed")


# ===============================================

# =============== Private functions ===============
func _ready():
	Round.player_manager = self

# =================================================

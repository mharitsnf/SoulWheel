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
	# Setup turn before starting
	_start_turn()
	
	# Skill selection phase
	yield(_summon_skill_hud(SKILL_HEXAGON), "completed")
	yield(self, "skill_confirmed")
	yield(_destroy_skill_hud(1), "completed")
	
	# Soul lock phase
#	yield(_summon_wheel(Round.WheelPhase.SOUL_LOCK), "completed")
#
#	for character in Round.enemy_manager.get_children():
#		if character is Enemy:
#			character.select_behavior(Enemy.Behavior.DEFEND)
#
#			var defend_pattern = character.data_model.defend_patterns[character.behavior_idx].duplicate(true)
#			var enemy_behavior_idx = character.behavior_idx
#
#			character.reset_areas(defend_pattern)
#			character.data_model.behaviors.preprocess.call_func(defend_pattern, enemy_behavior_idx)
#
#
	
	# Soul strike phase
	
	# Setup turn after finishing
	_end_turn()


func _end_turn():
	._end_turn()


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

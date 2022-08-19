extends Panel


onready var description = $TabContainer/Description/MarginContainer/Description
onready var hp_cost = $TabContainer/Description/MarginContainer2/VBoxContainer/HPCost
onready var hp_bonus = $TabContainer/Description/MarginContainer2/VBoxContainer/HPBonus
onready var damage = $TabContainer/Description/MarginContainer2/VBoxContainer/Damage
onready var fc = $TabContainer/Conditions/FCContainer/VBoxContainer/Description
onready var sc = $TabContainer/Conditions/SCContainer/VBoxContainer/Description
onready var title = $SkillTitle
onready var tween = $Tween
onready var exit_button = $ExitButton

var description_text = ""
var hp_cost_text = ""
var hp_bonus_text = ""
var damage_text = ""
var fc_text = ""
var sc_text = ""
var title_text = ""

var offset = Vector2(30, 0)


func _init():
	modulate.a = 0


func initialize(skill_data, _btn_idx):
	_set_title_text(skill_data.skill.name)
	_set_description_text(skill_data.skill.description)
	_set_hp_cost_text(skill_data.skill.hp_cost)
	_set_hp_bonus_text(skill_data.skill.hp_bonus)
	_set_damage_text(skill_data.skill.attack_patterns)
	_set_fc_text(skill_data.skill.first_condition)
	_set_sc_text(skill_data.skill.second_condition)
	
	exit_button.connect("pressed", Round.player_manager, "_on_skill_back_pressed",
		[Round.player_manager.SKILL_CARD, skill_data, _btn_idx]
	)
	
	_show()
	yield(tween, "tween_completed")


func destroy():
	_hide()
	yield(tween, "tween_completed")
	queue_free()


func _show():
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position + offset,
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,1),
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()


func _hide():
	tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position - offset,
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, "modulate",
		modulate, Color(1,1,1,0),
		0.2, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()


func _set_description_text(value):
	description_text = value
	description.text = value


func _set_hp_cost_text(value):
	hp_cost_text = str(value)
	hp_cost.text = "HP Wagered: " + str(value)


func _set_hp_bonus_text(value):
	hp_bonus_text = str(value)
	hp_bonus.text = "HP Bonus: " + str(value)


func _set_damage_text(patterns):
	var result = ""
	for phase_nr in range(patterns.size()):
		result += "Phase " + str(phase_nr + 1) + "\n"
		
		for arrow_nr in range(patterns[phase_nr].arrows.size()):
			var arrow = patterns[phase_nr].arrows[arrow_nr]
			result += "Arrow " + str(arrow_nr + 1) + " - " + str(arrow.damage) + " DMG \n"
	
	damage_text = result
	damage.text = result


func _set_fc_text(value):
	fc_text = value
	fc.text = value


func _set_sc_text(value):
	sc_text = value
	sc.text = value


func _set_title_text(value):
	title_text = value
	title.text = value

extends Resource
class_name AttackSkill


var arrow_template = preload("res://Resources/Arrow/arrow.gd")

export(String) var name

# Array of integers. The array's length represents the number of phases, and
# each element represents the number of arrows in the respective phase
export(Array) var attack_arrows

# Only contains one phase, so Array of arrows.
export(Array) var defend_arrows

# How much HP will be wagered and is it a percentage based on the player's current
# health?
export(int) var hp_cost
export(bool) var is_cost_percentage

# How much bonus HP will the player receive if they manage to avoid the damage areas?
# And is it a percentage based on the player's max health?
export(int) var hp_bonus
export(bool) var is_bonus_percentage

# Script that handles the first condition
export(GDScript) var conditions

# Script that handles the behavior of the attack and defend arrows.
export(GDScript) var behaviors


func _init():
	# Setup attack arrows
	var new_attack_arrows = []
	
	for phases in attack_arrows:
		var new_phase = []
		for arrow in phases:
			new_phase.append(arrow_template.new(arrow.move_speed, arrow.rot_angle, arrow.thickness, arrow.damage))
		new_attack_arrows.append(phases)
	
	attack_arrows = new_attack_arrows
	
	# Setup defend arrows
	var new_defend_arrows = []
	
	for phases in defend_arrows:
		var new_phase = []
		for arrow in phases:
			new_phase.append(arrow_template.new(arrow.move_speed, arrow.rot_angle, arrow.thickness))
		new_defend_arrows.append(phases)
	
	defend_arrows = new_defend_arrows

extends Possession


var arrow_template = preload("res://Resources/Arrow/arrow.gd")

# Array of array of dictionaries. The array's length represents the number of phases, and
# each element represents the number of arrows in the respective phase
export(Array) var attack_patterns

# Only contains one phase, so Array of arrows.
export(Array) var defense_patterns

# How much HP will be wagered and is it a percentage based on the player's current
# health?
export(int) var hp_cost
var hp_reclaim

# How much bonus HP will the player receive if they manage to avoid the damage areas?
# And is it a percentage based on the player's max health?
export(int) var hp_bonus


# Script that handles the first condition
export(GDScript) var conditions

# Script that handles the behavior of the attack and defend arrows.
export(GDScript) var behaviors

export(String, MULTILINE) var description
export(String, MULTILINE) var first_condition
export(String, MULTILINE) var second_condition


func _init():
	._init()
	type = Types.ATTACK_SKILL
	
	hp_reclaim = hp_cost

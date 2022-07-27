extends Resource
class_name AttackSkill


var arrow_template = preload("res://Resources/Arrow/arrow.gd")

export(String) var name

# Array of array of dictionaries. The array's length represents the number of phases, and
# each element represents the number of arrows in the respective phase
export(Array) var attack_patterns

# Only contains one phase, so Array of arrows.
export(Array) var defend_patterns

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

export(String, MULTILINE) var description

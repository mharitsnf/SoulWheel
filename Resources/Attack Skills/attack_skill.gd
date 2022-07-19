extends Resource
class_name AttackSkill

export(String) var name

# Array of arrays. The inner array contains the actual arrows. Structured like this
# to accommodate multiple attack phases.
export(Array) var attack_arrows

# Only contains one phase, so Array of arrows.
export(Array) var defend_arrows

# The amount of damage it deals to the enemy
export(int) var damage

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
var conditions_ins = null

# Script that handles the behavior of the attack and defend arrows.
export(GDScript) var behaviors
var behaviors_ins = null

export(Dictionary) var skill_data

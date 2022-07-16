extends Resource
class_name AttackSkill

export(String) var name
export(Array) var data
export(int) var damage

export(int) var hp_cost
export(bool) var is_cost_percentage
export(int) var hp_bonus
export(bool) var is_bonus_percentage

export(int) var time_alive
export(GDScript) var conditions

var conditions_ins = null

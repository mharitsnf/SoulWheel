extends Node


enum {
	TYPE_ARROW,
	TYPE_AREA
}

var modifications = {}


func apply_modifiers(pattern, type):
	for key in modifications:
		match key:
			"damage_mul": _apply_damage_mul(modifications[key], pattern, type)


func add_modifications(modification):
	var key = modification.key
	
	if !modifications.has(key):
		modifications[key] = {
			"amount": 0
		}
	
	modifications[key].amount += modification.amount


func clear_modifications():
	modifications = {}


func _apply_damage_mul(mod_data, pattern, type):
	var elements = pattern.arrows if type == TYPE_ARROW else pattern.areas
	
	for element in elements:
		element.damage *= mod_data.amount

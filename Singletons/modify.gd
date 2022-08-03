extends Node


enum {
	TYPE_ARROW,
	TYPE_AREA
}

var modifications = []


func apply_modifiers(pattern, type):
	for modification in modifications:
		
		match modification.path:
			"damage": _apply_damage(modification, pattern, type)


func reset_modifiers(pattern, type):
	var elements = pattern.arrows if type == TYPE_ARROW else pattern.areas
	
	for element in elements:
		element.reset()


func _apply_damage(modification, pattern, type):
	var elements = pattern.arrows if type == TYPE_ARROW else pattern.areas
	
	for element in elements:
		match modification.operation:
			"mul": element.damage += element.initial_damage * modification.amount
			"add": element.damage += element.initial_damage + modification.amount

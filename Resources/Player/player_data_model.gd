extends Resource
class_name PlayerDataModel


export var initial_health : int

var health = 30

var paths = [
	{ "skill": "res://Resources/Possessions/Attack Skills/Basic.tres", "mods": [] },
	{ "skill": "res://Resources/Possessions/Attack Skills/Accelerate.tres", "mods": [] },
	{ "skill": "res://Resources/Possessions/Attack Skills/Clock.tres", "mods": [] },
	{ "skill": null, "mods": [] }
]

var skills = [
	{ "skill": null, "mods": [] },
	{ "skill": null, "mods": [] },
	{ "skill": null, "mods": [] },
	{ "skill": null, "mods": [] }
]

func reset_slots():
	skills = [
		{ "skill": null, "affected_by": [] },
		{ "skill": null, "affected_by": [] },
		{ "skill": null, "affected_by": [] },
		{ "skill": null, "affected_by": [] }
	]

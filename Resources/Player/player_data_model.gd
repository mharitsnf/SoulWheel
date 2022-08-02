extends Resource
class_name PlayerDataModel


export var initial_health : int

var current_health = 30

var skill_paths = [
	"res://Resources/Possessions/Attack Skills/Basic.tres",
	"res://Resources/Possessions/Attack Skills/Accelerate.tres",
	"res://Resources/Possessions/Attack Skills/Clock.tres"
]
var skills = []

var slot_paths = [
	null,
	"res://Resources/Possessions/Attack Skills/Basic.tres",
	"res://Resources/Possessions/Modifiers/DoubleDamage.tres",
	"res://Resources/Possessions/Attack Skills/Basic.tres",
	null,
	null
]

# [{ "possession": "...", "modified_by": [...] }]
var slots = [
	{ "possession": null, "affected_by": [] },
	{ "possession": null, "affected_by": [] },
	{ "possession": null, "affected_by": [] },
	{ "possession": null, "affected_by": [] },
	{ "possession": null, "affected_by": [] },
	{ "possession": null, "affected_by": [] }
]

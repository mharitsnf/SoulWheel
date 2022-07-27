extends Resource
class_name PlayerDataModel


export var initial_health : int

var current_health = 30

var skill_paths = [
	"res://Resources/Attack Skills/Basic.tres",
	"res://Resources/Attack Skills/Accelerate.tres",
	"res://Resources/Attack Skills/Clock.tres"
]
var skills = []

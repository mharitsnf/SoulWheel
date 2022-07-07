extends Character
class_name Player


export var player_data_model : Resource
export(PackedScene) var wheel : PackedScene
export(PackedScene) var skill_hud : PackedScene

var skill_hud_ins : Control = null
var wheel_ins : Node2D = null

onready var root : Node = get_parent().get_parent()

signal skill_button_pressed


func _ready():
	assert(player_data_model)
	assert(player_data_model is PlayerDataModel)
	Globals.player = self

func play_turn():
	print("player playing")
	
	# Skill selection phase
	yield(_summon_skill_hud(), "completed")
	yield(self, "skill_button_pressed") # Wait for player to select a skill
	yield(_destroy_skill_hud(), "completed")
	
	# Soul lock phase
	yield(_summon_wheel(), "completed")
	yield(get_tree().create_timer(1), "timeout")
	yield(_destroy_wheel(), "completed")
	
	
	# Soul strike phase
	
	# Deal damage animation

func _summon_wheel():
	wheel_ins = wheel.instance()
	Globals.root.add_child(wheel_ins)
	yield(wheel_ins.initialize(), "completed")

func _destroy_wheel():
	yield(wheel_ins.destroy(), "completed")
	wheel_ins = null

func _summon_skill_hud():
	skill_hud_ins = skill_hud.instance()
	Globals.root.add_child(skill_hud_ins)
	yield(skill_hud_ins.initialize(), "completed")

func _destroy_skill_hud():
	yield(skill_hud_ins.destroy(), "completed")
	skill_hud_ins = null

func _on_skill_button_pressed(btn_text):
	print(btn_text)
	emit_signal("skill_button_pressed")

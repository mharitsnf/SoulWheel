extends Panel
class_name SkillCard


onready var title_node = $HeaderContainer/HBoxContainer/Title
onready var description_node = $DescriptionContainer/RichTextLabel
onready var fc_node = $FCContainer/RichTextLabel
onready var sc_node = $SCContainer/RichTextLabel
onready var hp_cost_node = $FooterContainer/HBoxContainer/HPCost
onready var hp_bonus_node = $FooterContainer/HBoxContainer/HPBonus

var title = "" setget _set_title
var description = "" setget _set_description
var fc = "" setget _set_fc
var sc = "" setget _set_sc
var hp_cost = 0 setget _set_hp_cost
var hp_bonus = 0 setget _set_hp_bonus


func show():
	$AnimationPlayer.play("show")


func hide():
	$AnimationPlayer.play("hide")
	yield($AnimationPlayer, "animation_finished")


func _set_title(value):
	title = value
	title_node.text = value


func _set_description(value):
	description = value
	description_node.text = value


func _set_fc(value):
	fc = value
	fc_node.text = value


func _set_sc(value):
	sc = value
	sc_node = value


func _set_hp_cost(value):
	hp_cost = value
	hp_cost_node.text = "-" + str(value)


func _set_hp_bonus(value):
	hp_bonus = value
	hp_bonus_node.text = "+" + str(value)


func _ready():
	Nodes.skill_card = self
	modulate.a = 0

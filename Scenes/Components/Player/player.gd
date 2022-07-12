extends Character
class_name Player


export var player_data_model : Resource
export(PackedScene) var wheel : PackedScene
export(PackedScene) var skill_hud : PackedScene

var rng = RandomNumberGenerator.new()
var skills := []
var chosen_skill = null

var skill_hud_ins : Control = null
var wheel_ins : Node2D = null

onready var root : Node = get_parent().get_parent()
onready var turn_manager : Node2D = get_parent()

signal skill_button_pressed


func _ready():
	assert(player_data_model)
	assert(player_data_model is PlayerDataModel)
	Globals.player = self
	rng.randomize()
	
	if Globals.current_area == 1 and Globals.current_round == 1:
		_load_deck(Globals.skill_resource_paths.attack1)

func play_turn():
	print("player playing")
	
	# Randomize current skills
	var skill_limit = Globals.skill_deck.size() if Globals.skill_deck.size() <= 4 else 4
	for i in range(skill_limit):
		var chosen_skill_idx = rng.randi_range(0, skill_limit - 1)
		var skill = Globals.skill_deck[chosen_skill_idx]
		skills.append(skill)
	
	# Skill selection phase
	yield(_summon_skill_hud(), "completed")
	yield(self, "skill_button_pressed") # Wait for player to select a skill
	yield(_destroy_skill_hud(), "completed")
	
	# Soul lock phase
	for character in turn_manager.get_children(): 
		if character is Enemy:
			var current_enemy = Globals.enemy_loader(character)
			yield(_summon_wheel("lock"), "completed")
			yield(wheel_ins.set_enemy(current_enemy), "completed")
			yield(wheel_ins.draw_areas(), "completed")
			yield(wheel_ins.soul_lock(), "completed")
			yield(_destroy_wheel(), "completed")
			
			# TODO: Add transition
			yield(get_tree().create_timer(1), "timeout")
	
	# Soul strike phase
#	print(skills[chosen_skill])
	yield(_summon_wheel("strike"), "completed")
	yield(wheel_ins.set_arrows(skills[chosen_skill]), "completed")
	yield(wheel_ins.draw_arrows(), "completed")
	yield(wheel_ins.soul_lock(), "completed")
	yield(_destroy_wheel(), "completed")
	
	# Deal damage
	yield(_check_result(), "completed")
	
	_end_turn()


func _check_result():
	yield(get_tree(), "idle_frame")
	
	if !Globals.saved_areas.empty() and !Globals.saved_arrow.empty():
		
		for enemy in Globals.saved_areas:
			var hit_count = 0
			
			for arrow in Globals.saved_arrow.data:
				var arrow_angle : Vector2 = _generate_angles(arrow.rot_angle, arrow.thickness)
				
				for area in enemy.soul_areas:
					var area_angle : Vector2 = _generate_angles(area.rot_angle, area.thickness)
					
					print(arrow_angle, ' ', area_angle)
					
					if _is_hit(arrow_angle, area_angle):
						hit_count += 1
						break
			
			print(enemy.node, " is hit ", hit_count, " times.")


func _generate_angles(rot_angle, thickness):
	var start_angle = -thickness
	var end_angle = thickness + 1
	return Vector2(fmod(start_angle + rot_angle, 360), fmod(end_angle + rot_angle, 360))


func _is_hit(arrow : Vector2, area : Vector2):
	if arrow.y >= area.x and arrow.x <= area.y:
		return true
	
	return false


func _end_turn():
	skills = []
	Globals.saved_areas = []
	Globals.saved_arrow = {}


func _load_deck(path):
	Globals.skill_deck.append(Globals.attack_loader(path))


func _summon_wheel(phase):
	wheel_ins = wheel.instance()
	Globals.root.add_child(wheel_ins)
	yield(wheel_ins.initialize(phase), "completed")


func _destroy_wheel():
	yield(wheel_ins.destroy(), "completed")
	wheel_ins = null


func _summon_skill_hud():
	skill_hud_ins = skill_hud.instance()
	Globals.root.add_child(skill_hud_ins)
	yield(skill_hud_ins.initialize(skills), "completed")


func _destroy_skill_hud():
	yield(skill_hud_ins.destroy(), "completed")
	skill_hud_ins = null


func _on_skill_button_pressed(btn_idx):
	chosen_skill = btn_idx
	emit_signal("skill_button_pressed")

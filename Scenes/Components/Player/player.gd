extends Character
class_name Player


export var player_data_model : Resource
export(PackedScene) var skill_hud : PackedScene

var skill_hud_ins : Control = null

var rng = RandomNumberGenerator.new()
var chosen_skill : AttackSkill = null

var enemies_to_process = []

onready var root : Node = get_parent().get_parent()

signal skill_button_pressed


func _ready():
	assert(player_data_model)
	assert(player_data_model is PlayerDataModel)
	
	Globals.player = self
	player_data_model.current_health = player_data_model.max_health
	
	rng.randomize()
	
	if Globals.current_area == 1 and Globals.current_round == 1:
		_put_card_on_deck(Globals.skill_resource_paths.basic)
		_put_card_on_deck(Globals.skill_resource_paths.double)
		_put_card_on_deck(Globals.skill_resource_paths.trinity)


func take_damage(damage):
	var new_health = player_data_model.current_health - damage
	player_data_model.current_health = max(0, new_health)
	
	Globals.hp_hud.hp_label.text = "HP: " + str(new_health)
	
	if new_health <= 0:
		return true
	
	return false


func play_turn():
	print("player playing")
	
	# Skill selection phase
	yield(_summon_skill_hud(), "completed")
	yield(self, "skill_button_pressed") # Wait for player to select a skill
	yield(_destroy_skill_hud(), "completed")
	
	# Soul lock phase
	for character in turn_manager.get_children(): 
		if character is Enemy:
			var current_enemy = Globals.enemy_loader(character)
			
			yield(_summon_wheel("lock", enemies_to_process), "completed")
			yield(wheel_ins.set_enemy(current_enemy), "completed")
			yield(wheel_ins.draw_areas(), "completed")
			
			current_enemy = yield(wheel_ins.action(), "completed")
			enemies_to_process.append(current_enemy)
			
			yield(_destroy_wheel(), "completed")
			
			# TODO: Add transition
			yield(get_tree().create_timer(1), "timeout")
	
	# Soul strike phase
	for wheel_phase in chosen_skill.data:
		yield(_summon_wheel("strike", enemies_to_process), "completed")
		yield(wheel_ins.set_arrows(wheel_phase), "completed")
		yield(wheel_ins.draw_arrows(), "completed")
		
		var processed_arrows = yield(wheel_ins.action(), "completed")
		
		# TODO: Add transition
		var defeateds = _check_result(processed_arrows)
		for enemy in defeateds:
			yield(_defeat_enemy(enemy), "completed")
		
		if turn_manager.get_child_count() == 1 and turn_manager.get_child(0) == self:
			yield(get_tree().create_timer(0.5), "timeout")
			yield(_destroy_wheel(), "completed")
			_end_turn()
			return true
		
		yield(get_tree().create_timer(0.5), "timeout")
		yield(_destroy_wheel(), "completed")
		yield(get_tree().create_timer(0.5), "timeout")
	
	_end_turn()
	return false


func _check_result(processed_arrows):
	var defeated_enemies = []
	
	for enemy in enemies_to_process:
		for arrow in processed_arrows:
			var arrow_angle : Vector2 = Globals.generate_angles(arrow.rot_angle, arrow.thickness)

			for area in enemy.dm.soul_areas:
				var area_angle : Vector2 = Globals.generate_angles(area.rot_angle, area.thickness)

				if _is_hit(arrow_angle, area_angle):
					var is_defeated = enemy.node.take_damage(chosen_skill.damage)
					print(enemy.node, " hit! health: ", enemy.node.current_health)
					
					if is_defeated and !defeated_enemies.has(enemy): defeated_enemies.append(enemy)
						
	return defeated_enemies


func _defeat_enemy(enemy_data):
	enemies_to_process.erase(enemy_data)
	enemy_data.node.queue_free()
	yield(get_tree(), "idle_frame")


func _end_turn():
	enemies_to_process = []
	
	._end_turn()


func _put_card_on_deck(path):
	Globals.skill_deck.append(Globals.attack_loader(path))


func _summon_skill_hud():
	skill_hud_ins = skill_hud.instance()
	Globals.root.add_child(skill_hud_ins)
	skill_hud_ins.initialize(Globals.skill_deck)
	
	Globals.hp_hud.move_up()
	yield(skill_hud_ins.show(), "completed")


func _destroy_skill_hud():
	Globals.hp_hud.move_down()
	yield(skill_hud_ins.hide_and_destroy(), "completed")
	skill_hud_ins = null


func _on_skill_button_pressed(btn_idx):
	chosen_skill = Globals.skill_deck[btn_idx]
	emit_signal("skill_button_pressed")

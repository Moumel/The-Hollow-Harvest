extends Node2D

@onready var menu_main = $BattleUI/Panel
@onready var menu_sub = $BattleUI/SubMenuPanel
@onready var container_sub = $BattleUI/SubMenuPanel/VBoxContainer
@onready var info_label = $BattleUI/InfoLabel
@onready var cutscene_layer = $CutsceneLayer
@onready var frame_display = $CutsceneLayer/FrameDisplay
@onready var cutscene_bg = $CutsceneLayer/Background
@onready var cutscene_label = $CutsceneLayer/Label

var f1 = preload("res://helpassets/rescuehand1.png")
var f2 = preload("res://helpassets/rescuehand2.png")
var f3 = preload("res://helpassets/rescuehand3.png")
var f4 = preload("res://helpassets/rescuehand4.png")

var boss_health = 100
var player_hp = 100
var act_count = 0
var can_spare = false
var is_player_turn = true

# Status Effects
var boss_is_tripped = false 
var boss_cant_reach = false 
var pride_is_listening = false
var pride_is_doubting = false
var is_processing : bool = false

func _ready():
	MusicController.play_music(preload("res://msuic/boss.mp3"))

	cutscene_layer.hide()
	$ShieldAnim.hide()
	menu_sub.hide()
	menu_main.show()
	update_battle_text("Pride stands before you.")
	await wait_for_input()

# ---  Visual Health Bar ---
func get_hp_string(label: String, current: int, max_val: int) -> String:
	var bar_length = 10
	var filled_blocks = int(float(current) / max_val * bar_length)
	var empty_blocks = bar_length - filled_blocks
	
	var bar = ""
	for i in range(filled_blocks): bar += "■"
	for i in range(empty_blocks): bar += "□"
	
	return label + ": " + bar + " (" + str(current) + "/" + str(max_val) + ")"

# ---  Update Text with Status ---
func update_battle_text(message: String):
	var boss_bar = get_hp_string("Pride", boss_health, 100)
	var player_bar = get_hp_string("YOU ", player_hp, 100)
	
	info_label.text = boss_bar + "\n" + player_bar + "\n\n" + message + "\n[Press E]"

func wait_for_input():
	await get_tree().create_timer(0.1).timeout 
	while not Input.is_action_just_pressed("interact"): 
		await get_tree().process_frame

# --- Main Buttons ---
func _on_attack_button_pressed():
	if is_player_turn and not is_processing: # Use the lock here
		show_sub_menu(["Head", "Body", "Arms", "Legs"])

func _on_act_button_pressed():
	if not is_player_turn or is_processing: return
	if act_count == 0: show_sub_menu(["Peer into Cracks", "Mention the Dust", "Laughter"])
	elif act_count == 1: show_sub_menu(["Ask of the Empty Pedestal", "Pity Him", "Whisper a Secret"])
	elif act_count == 2: show_sub_menu(["Grant Permission to Fall", "Silence", "Mockery"])
	else: show_sub_menu(["Spare", "Final Words"])

# --- Choices ---
func handle_choice(choice):
	is_processing = true
	menu_sub.hide()
	
	match choice:
		"Head":
			play_head_shield_anim() 
			update_battle_text("His pride is too high! You cannot reach his head.")
			await get_tree().create_timer(1.0).timeout
			player_hp -= 15
			update_battle_text("He reflects the attack! You take 15 DMG.")
			start_boss_turn() 
			return
		"Body":
			boss_health -= 10
			update_battle_text("Direct hit to the chest! He looks insulted.")
		"Arms":
			boss_health -= 5
			boss_cant_reach = true
			update_battle_text("You strike his arms. He can't reach you for one turn!")
		"Legs":
			boss_health -= 5
			boss_is_tripped = true
			update_battle_text("You sweep his legs! He falls and skips a turn.")
			
		
		"Peer into Cracks", "Mention the Dust":
			if act_count == 0:
				update_battle_text("He brushes his shoulder frantically. The gold feels heavier.")
				act_count = 1
			else:
				update_battle_text("He is already looking at his flaws. You must go deeper.")
				start_boss_turn()
				return

		"Ask of the Empty Pedestal", "Pity Him":
			if act_count == 1:
				update_battle_text("His aura flickers. You see the tired man beneath the shine.")
				act_count = 2
			else:
				update_battle_text("He ignores your pity. 'I am a GOD!'")
				start_boss_turn()
				return

		"Grant Permission to Fall", "Silence":
			if act_count == 2:
				update_battle_text("The golden shell fractures. [SPARE UNLOCKED]")
				act_count = 3
				can_spare = true
			else:
				update_battle_text("He laughs. Your silence doesn't move him yet.")
				start_boss_turn()
				return

		"Laughter", "Whisper a Secret":
			
			update_battle_text("He ENRAGES! 'You dare mock perfection?'")
			act_count = 0
			can_spare = false
			start_boss_turn()
			return

		"Spare":
			if can_spare:
				
				update_battle_text("The Dagger pulses... You cannot bring yourself to Spare.")
			else:
				update_battle_text("He is still fighting. There is no mercy here.")
			await wait_for_input()
			start_boss_turn()
			return


	await wait_for_input()
	check_health_and_continue()

func check_health_and_continue():
	if boss_health <= 40 or player_hp <= 20: 
		trigger_npc_rescue()
	else:
		start_boss_turn()

func trigger_npc_rescue():
	is_processing = true
	is_player_turn = false
	menu_main.hide()
	menu_sub.hide()
	info_label.hide() 
	
	# 1. Start the sequence
	cutscene_layer.show()
	Global.has_met_pride = true
	
	
	cutscene_bg.color = Color.BLACK
	frame_display.texture = f1
	# Use update_cutscene_text here! (false = white text)
	update_cutscene_text("Suddenly, a shadow blurs across the screen!", false)
	await wait_for_input()
	
	
	frame_display.texture = f2
	update_cutscene_text("Stop! You're throwing your life away!", false)
	await wait_for_input()
	
	
	cutscene_bg.color = Color.WHITE
	frame_display.texture = f3
	
	update_cutscene_text("A blinding light fills the room...", true)
	await wait_for_input()
	
	
	frame_display.texture = f4
	update_cutscene_text("He pulls you through the rift!", true)
	await wait_for_input()

	# 2. THE TRANSITION
	Global.trigger_rescue_cutscene = true
	
	var fade = create_tween().set_parallel(true)
	fade.tween_property(frame_display, "modulate:a", 0, 1.0)
	fade.tween_property(cutscene_label, "modulate:a", 0, 1.0)
	
	await fade.finished
	
	print("Attempting to change scene to hub...")
	get_tree().change_scene_to_file("res://hub.tscn")
	
func update_cutscene_text(msg: String, use_black_text: bool = false):
	var cutscene_label = $CutsceneLayer/Label
	cutscene_label.show()
	cutscene_label.modulate.a = 1.0 # Ensure it's not transparent
	
	
	if use_black_text:
		cutscene_label.add_theme_color_override("font_color", Color.BLACK)
	else:
		cutscene_label.add_theme_color_override("font_color", Color.WHITE)
		
	cutscene_label.text = msg + "\n[Press E]"    
	
# --- Boss Turn Logic ---
func start_boss_turn():
	is_player_turn = false
	
	if boss_is_tripped:
		update_battle_text("Pride is still on the ground! He skips his turn.")
		boss_is_tripped = false 
		await wait_for_input()
		start_player_turn()
		return

	update_battle_text("Pride prepares a golden strike...")
	await wait_for_input()
	
	if boss_cant_reach:
		update_battle_text("He tries to grab you, but his arms are too weak! MISS!")
		boss_cant_reach = false 
	else:
		
		var boss_node = $pride
		var original_b_scale = boss_node.scale 
		var attack_b_scale = original_b_scale * 1.2 

		var b_tween = get_tree().create_tween().set_parallel(true)
		b_tween.tween_property(boss_node, "modulate", Color(10, 10, 10, 1), 0.1)
		b_tween.tween_property(boss_node, "scale", attack_b_scale, 0.1)
		
		b_tween.chain().tween_property(boss_node, "modulate", Color(1, 1, 1, 1), 0.2)
		b_tween.parallel().tween_property(boss_node, "scale", original_b_scale, 0.2)
		
		# --- PLAYER HIT ANIMATION ---
		var p_node = $player_fight 
		var p_tween = get_tree().create_tween()
		p_tween.tween_property(p_node, "modulate", Color.RED, 0.05)
		p_tween.tween_property(p_node, "position:x", p_node.position.x + 10, 0.05)
		p_tween.tween_property(p_node, "position:x", p_node.position.x - 10, 0.05)
		p_tween.tween_property(p_node, "position:x", p_node.position.x, 0.05)
		p_tween.tween_property(p_node, "modulate", Color.WHITE, 0.05)
		
		player_hp -= 15
		update_battle_text("A beam of light hits you! You take 15 DMG.")
	
	await wait_for_input()
	
	if player_hp <= 20 and player_hp > 0: 
		trigger_npc_rescue()
		return
	
	if player_hp <= 0:
		get_tree().reload_current_scene()
	else:
		start_player_turn()

func start_player_turn():
	is_processing = false
	is_player_turn = true
	menu_main.show()
	update_battle_text("What will you do?")

func finish_fight(_spared: bool):
	menu_main.hide()
	menu_sub.hide()
	
	# --- BOSS DEATH/EXIT ANIMATION ---
	var d_tween = get_tree().create_tween().set_parallel(true)
	# Fade out
	d_tween.tween_property($pride, "modulate:a", 0, 1.5)
	# Sink down
	d_tween.tween_property($pride, "position:y", $pride.position.y + 50, 1.5)
	
	var msg = ""
	if _spared:
		msg = "YOU SPARED PRIDE.\nHe gives you a 'Golden Ribbon'."
		Global.inventory.append("Golden Ribbon")
	else:
		msg = "PRIDE HAS FALLEN.\nYou absorb his essence. NEW ABILITY: PRIDE!"
		Global.has_pride_dash = true

	update_battle_text(msg + "\n[Press E to return to Hub]")
	await wait_for_input()
	
	Global.bosses_defeated += 1
	get_tree().change_scene_to_file("res://hub.tscn")

# ---  menu  ---
func show_sub_menu(options: Array):
	for child in container_sub.get_children(): child.queue_free()
	menu_main.hide()
	menu_sub.show()
	for option in options:
		var btn = Button.new()
		btn.text = option
		btn.pressed.connect(handle_choice.bind(option))
		container_sub.add_child(btn)
func play_head_shield_anim():
	var shield = $ShieldAnim 
	var boss = $pride
	
	
	var original_scale = boss.scale 
	var target_scale = original_scale * 1.1 
	
	shield.show()
	shield.modulate.a = 1.0
	shield.play("block")
	
	
	var b_tween = create_tween()
	b_tween.tween_property(boss, "scale", target_scale, 0.1)
	b_tween.chain().tween_property(boss, "scale", original_scale, 0.1) # Returns to normal
	
	await get_tree().create_timer(0.6).timeout
	
	var f_tween = create_tween()
	f_tween.tween_property(shield, "modulate:a", 0, 0.3)
	await f_tween.finished
	
	shield.stop()
	shield.hide()

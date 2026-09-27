extends Control



@onready var ui_panel = $CanvasLayer/ui_root/Panel

@onready var ui_label = $CanvasLayer/ui_root/Panel/Label


@onready var fade_overlay = $FadeOverlay 

@onready var player_node = $player

@onready var npc_node = $npc

@onready var ui_root = $CanvasLayer/ui_root

var is_waiting_for_input = false

func _ready():
	player_node.get_node("AnimatedSprite2D").play("walk_down")
	$CutsceneSprite.hide()
	ui_panel.hide()

	if Global.trigger_rescue_cutscene:
		if Global.current_soul_count == 2:
			run_mc2_victory_return() 
		else:
			run_hub_arrival_cutscene() 
			
		
		Global.trigger_rescue_cutscene = false 
	else:
		
		if fade_overlay: fade_overlay.hide()
		MusicController.play_music(preload("res://msuic/hub.mp3"))

func run_hub_arrival_cutscene():

	

	fade_overlay.show()

	fade_overlay.modulate.a = 1.0

	ui_panel.hide()


	player_node.position = Vector2(520, 50)

	npc_node.position = Vector2(480, 55)


	player_node.set_physics_process(false)

	

	

	await get_tree().create_timer(0.3).timeout


	var tween = create_tween().set_parallel(true)

	

	tween.tween_property(fade_overlay, "modulate:a", 0, 2.0)



	tween.tween_property(player_node, "position", Vector2(520, 420), 4.0).set_trans(Tween.TRANS_SINE)

	tween.tween_property(npc_node, "position", Vector2(480, 420), 4.0).set_trans(Tween.TRANS_SINE)



	if player_node.has_node("AnimatedSprite2D"):

		player_node.get_node("AnimatedSprite2D").play("walk_down")

	if npc_node.has_node("AnimatedSprite2D"):

		npc_node.get_node("AnimatedSprite2D").play("walk_down")


	await tween.finished


	if player_node.has_node("AnimatedSprite2D"):

		player_node.get_node("AnimatedSprite2D").play("walk_down")

	if npc_node.has_node("AnimatedSprite2D"):

		npc_node.get_node("AnimatedSprite2D").play("walk_down")

	
	fade_overlay.hide()
	$CanvasLayer.show()
	ui_root.show()
	ui_panel.show()


	var full_text = "...And stay down. You're lucky I was nearby.'"
	ui_label.text = full_text
	
	
	ui_label.visible_characters = 0
	

	var text_tween = create_tween()
	
	text_tween.tween_property(ui_label, "visible_characters", full_text.length(), 3.5)
	
	
	await text_tween.finished
	
	
	ui_label.text += "\n[Press E]"

	
	is_waiting_for_input = true
	while is_waiting_for_input:
		if Input.is_action_just_pressed("interact"): 
			is_waiting_for_input = false
		await get_tree().process_frame 

	
	ui_panel.hide()
	player_node.set_physics_process(true)
	MusicController.play_music(preload("res://msuic/hub.mp3"))
	Global.trigger_rescue_cutscene = false

func run_mc2_victory_return():
	
	player_node.get_node("AnimatedSprite2D").play("walk_down")
	fade_overlay.show()
	fade_overlay.modulate.a = 1.0
	ui_panel.hide()
	$CutsceneSprite.hide() 
	
	
	player_node.position = Vector2(520, 50)
	player_node.set_physics_process(false)
	
	await get_tree().create_timer(0.5).timeout
	
	var walk_tween = create_tween().set_parallel(true)
	walk_tween.tween_property(fade_overlay, "modulate:a", 0, 2.0)
	walk_tween.tween_property(player_node, "position", Vector2(520, 390), 6.0).set_trans(Tween.TRANS_SINE)
	
	if player_node.has_node("AnimatedSprite2D"):
		player_node.get_node("AnimatedSprite2D").play("walk_down")
	
	await walk_tween.finished
	
	
	if player_node.has_node("AnimatedSprite2D"):
		player_node.get_node("AnimatedSprite2D").stop()


	var sprite = $CutsceneSprite
	$CutsceneSprite.show()
	var frame_delay = 1.2 # How long each frame stays
	sprite.region_enabled = true
	var frame_width = 640

	
	$CutsceneSprite.region_rect = Rect2(0, 0, 640, 480)
	await get_tree().create_timer(frame_delay).timeout
	

	$CutsceneSprite.region_rect = Rect2(640, 0, 640, 480)
	await get_tree().create_timer(frame_delay).timeout
	
	
	$CutsceneSprite.region_rect = Rect2(1280, 0, 640, 480)
	await get_tree().create_timer(frame_delay).timeout
	
	$CutsceneSprite.hide()

	
	if player_node.has_node("AnimatedSprite2D"):
		# Use the name of your ready animation (e.g., "death" or "fall")
		player_node.get_node("AnimatedSprite2D").play("death") 
	

	await get_tree().create_timer(1.5).timeout

	
	var npc_portrait = $CanvasLayer/ui_root/Panel/TextureRect
	

	npc_portrait.texture = load("res://map_assets/npchubalt.png")
	ui_panel.show()
	var npc_text = "You actually did it... but at what cost?"
	ui_label.text = ""
	
	var text_tween = create_tween()
	text_tween.tween_property(ui_label, "visible_characters", npc_text.length(), 2.5)
	ui_label.text = npc_text
	
	await text_tween.finished
	ui_label.text += "\n[Press E]"

	
	is_waiting_for_input = true
	while is_waiting_for_input:
		if Input.is_action_just_pressed("interact"):
			is_waiting_for_input = false
		await get_tree().process_frame

	ui_panel.hide()
	
	print("MC2 has fallen. End of Chapter.")
	
	
	fade_overlay.show()
	fade_overlay.modulate.a = 0 
	
	var final_fade = create_tween()
	final_fade.tween_property(fade_overlay, "modulate:a", 1.0, 3.0) # Slow 3-second fade
	
	
	var music_fade = create_tween()
	
	
	var m_node = MusicController.get_node("AudioStreamPlayer")
	
	if m_node:
		music_fade.tween_property(m_node, "volume_db", -80, 3.0)

	
	await final_fade.finished
	

	print("Changing to Credits...")
	get_tree().change_scene_to_file("res://scene/void_interrogation.tscn") # Make sure this path is correct!



func _on_button_pressed():

	ui_panel.show()

	ui_label.text = "To grow stronger, you must devour the limbs of the fallen."

func shake_screen(duration: float, intensity: float):
	var orig_pos = $CutsceneSprite.position 
	var shake_tween = create_tween()
	
	for i in range(int(duration * 15)):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property($CutsceneSprite, "position", orig_pos + offset, 0.05)
	
	
	shake_tween.tween_property($CutsceneSprite, "position", orig_pos, 0.05) 

func _on_north_gate_player_entered_gate() -> void:
	pass # Replace with function body.


func _on_north_gate_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

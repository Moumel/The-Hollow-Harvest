extends Node2D

@onready var guy_sprite = $clussy 
@onready var stab_anim = $StabAnimatedSprite
@onready var player = $player
@onready var screen_rect = $CanvasLayer/ScreenEffectRect

@onready var panel = $CanvasLayer/ui_root/Panel
@onready var label = $CanvasLayer/ui_root/VBoxContainer/RichTextLabel
@onready var btn_a = $CanvasLayer/ui_root/VBoxContainer/HBoxContainer/OptionA
@onready var btn_b = $CanvasLayer/ui_root/VBoxContainer/HBoxContainer/OptionB

var active_player : CharacterBody2D = null

var expressions = [
	preload("res://clussy1.png"), 
	preload("res://clussy2.png"),
	preload("res://clussy3.png")
]

var lines = [
	{
		"text": "Greetings. Morning, evening... it matters little. Tell me, boy: what do you believe is eternal in this world?",
		"options": ["Life.", "Nothing."]
	},
	{
		"text": "All that lives must die, all that is solid crumbles. Even emotions wither into shadows.",
		"options": ["The truth?", "..."]
	},
	{
		"text": "As long as you are human, the only eternal truth is... one's own [color=red]sin[/color].",
		"options": ["...", "..."]
	}
]

var current_step = 0
var player_near_dagger = false
var is_stabbing = false 

func _ready():
	screen_rect.show()
	screen_rect.color = Color.WHITE
	screen_rect.modulate.a = 1.0
	MusicController.play_music(preload("res://msuic/clussy.mp3"))
	
	await get_tree().process_frame
	var global_player = MusicController.get_node_or_null("AudioStreamPlayer")
	if global_player:
		global_player.play(18.0)
	
	current_step = 0
	
	if has_node("StabAnimatedSprite"):
		$StabAnimatedSprite.hide()
	
	if Global.has_met_pride:
		guy_sprite.hide()
		panel.hide() 
		var dagger = get_node_or_null("DaggerItem")
		if dagger:
			dagger.show()
			var col = dagger.get_node_or_null("CollisionShape2D")
			if col: col.disabled = false 
	else:
		if player: player.hide()
		player.set_physics_process(false)
		var dagger = get_node_or_null("DaggerItem")
		if dagger: dagger.hide()
		guy_sprite.show()
		panel.show() 
		advance_dialogue()
		
	var fade_tween = create_tween()
	fade_tween.tween_property(screen_rect, "modulate:a", 0.0, 1.5) # 1.5s fade
	await fade_tween.finished
	
	screen_rect.hide()

func _input(event):
	if event.is_action_pressed("interact"):
		print("--- E Key Pressed! ---")
		print("Met Pride: ", Global.has_met_pride)
		print("Near Dagger: ", player_near_dagger)
		
		if not Global.has_met_pride:
			print("Running Clussy Dialogue...")
			advance_dialogue()
		elif player_near_dagger:
			print("Entering Dagger Choice...")
			show_stab_choice()
		else:
			print("Pressed E, but not near anything.")

func show_stab_choice():
	print("Waiting for player choice: [1] [wave]Stab[/wave] or [2] Leave")
	label.text = "The blade is cold. Use it?\n[1] Stab Yourself  |  [2] Leave it"
	panel.show()

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false) 

	var choosing = true
	while choosing:
		if Input.is_key_pressed(KEY_1):
			print("Choice made: STAB")
			choosing = false
			start_suicide_sequence()
		elif Input.is_key_pressed(KEY_2):
			print("Choice made: LEAVE")
			choosing = false
			label.text = "You turned away..."
			if player: player.set_physics_process(true)
			await get_tree().create_timer(1.5).timeout
			panel.hide()
		
		await get_tree().process_frame

func start_suicide_sequence():
	is_stabbing = true
	label.text = "" 
	if label is RichTextLabel:
		label.clear() 
	
	btn_a.hide()
	btn_b.hide()
	panel.hide()
	var player = active_player if active_player else get_tree().get_first_node_in_group("player")
	
	if player:
		panel.hide()
		player.set_physics_process(false)
		var dagger = get_node_or_null("DaggerItem")
		if dagger:
			dagger.hide() 
		
		var tween = create_tween()
		
		
		var original_pos = player.global_position
		for i in range(8):
			var x_shift = 3 if i % 2 == 0 else -3
			tween.tween_property(player, "global_position:x", original_pos.x + x_shift, 0.04)
		
		
		tween.tween_callback(func():
			screen_rect.color = Color.RED
			screen_rect.modulate.a = 0.8
			screen_rect.show()
			
		)
		
		tween.tween_interval(0.1) 
		
		tween.tween_callback(func():
			stab_anim.global_position = player.global_position
			stab_anim.z_index = 100 
			stab_anim.show()
			stab_anim.frame = 0
			stab_anim.play("suicide")
			
			var fade_red = create_tween()
			fade_red.tween_property(screen_rect, "modulate:a", 0.3, 0.2)
		)
		
		
		tween.tween_interval(4.0) 
		
		tween.tween_property(screen_rect, "color", Color.BLACK, 2.0)
		tween.tween_property(screen_rect, "modulate:a", 1.0, 2.0)
		
		await tween.finished
		get_tree().change_scene_to_file("res://scene/void_interrogation.tscn")
	   

func advance_dialogue():
	btn_a.hide()
	btn_b.hide()
	
	if current_step < lines.size():
		var current_data = lines[current_step]
		
		panel.show() 
		if expressions.size() > current_step:
			guy_sprite.texture = expressions[current_step]
		
		label.text = current_data["text"]
		
		label.visible_ratio = 0
		var tween = get_tree().create_tween()
		
		tween.tween_property(label, "visible_ratio", 1.0, 2.0)
		
		await tween.finished
		
		btn_a.text = current_data["options"][0]
		btn_b.text = current_data["options"][1]
		
		btn_a.show()
		btn_b.show()
		
		current_step += 1
	else:
		fade_to_boss()

func fade_to_boss():
	screen_rect.color = Color.BLACK
	screen_rect.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(screen_rect, "modulate:a", 1.0, 1.0)
	tween.tween_callback(Callable(self, "_go_to_boss"))

func _go_to_boss():
	get_tree().change_scene_to_file("res://maps/boss_1.tscn")

func _on_dagger_item_body_entered(body):
	print("OBJECT ENTERED AREA: ", body.name) 
	
	if body.is_in_group("player") or body.name == "player":
		active_player = body
		player_near_dagger = true
		label.text = "[E] Inspect Dagger"
		panel.show()
		label.visible_ratio = 1.0

func _on_dagger_item_body_exited(body):
	if body.is_in_group("player"):
		player_near_dagger = false
		if not is_stabbing:
			panel.hide()


func _on_option_a_pressed() -> void:
	# This runs when you click the first button
	advance_dialogue()

func _on_option_b_pressed() -> void:
	# This runs when you click the second button
	advance_dialogue()

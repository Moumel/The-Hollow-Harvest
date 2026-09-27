extends Control



@onready var ui_panel = $CanvasLayer/ui_root/Panel

@onready var ui_label = $CanvasLayer/ui_root/Panel/Label



@onready var fade_overlay = $FadeOverlay 

@onready var player_node = $player

@onready var npc_node = $npc

@onready var ui_root = $CanvasLayer/ui_root

var is_waiting_for_input = false

func _ready():

	ui_panel.hide()

	

	if Global.trigger_rescue_cutscene:

		

		run_hub_arrival_cutscene() 

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



func _on_button_pressed():

	ui_panel.show()

	ui_label.text = "To grow stronger, you must devour the limbs of the fallen."


func _on_north_gate_player_entered_gate() -> void:
	pass # Replace with function body.


func _on_north_gate_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

extends Node2D




@onready var player = $player
@onready var screen_rect = $CanvasLayer/ScreenEffectRect



@onready var panel = $CanvasLayer/ui_root/Panel
@onready var label = $CanvasLayer/ui_root/Panel/VBoxContainer/RichTextLabel
@onready var btn_a = $CanvasLayer/ui_root/Panel/VBoxContainer/HBoxContainer/OptionA
@onready var btn_b = $CanvasLayer/ui_root/Panel/VBoxContainer/HBoxContainer/OptionB

var choice_made = false

func _ready():
	MusicController.play_music(preload("res://msuic/clussy.mp3"))

	panel.hide()
	start_final_interaction()


func start_final_interaction():
	panel.show()
	label.text = "Cursed dagger [wave amp=20 freq=2]It feels right, doesn't it?[/wave]"
	
	btn_a.text = "Take the Sin"
	btn_b.text = "Take the Sin"
	
	while not choice_made:
		if Input.is_key_pressed(KEY_1) or Input.is_key_pressed(KEY_2):
			_on_choice_selected()
		await get_tree().process_frame

func _on_choice_selected():
	choice_made = true
	run_end_sequence()


func _on_option_a_pressed() -> void:
	print("Button A Clicked!")
	_on_choice_selected()

func _on_option_b_pressed() -> void:
	print("Button B Clicked!")
	_on_choice_selected()
	
func run_end_sequence():
	btn_a.hide()
	btn_b.hide()
	label.text = "And so, the harvest begins again..."
	
	var tween = create_tween()
	screen_rect.show()
	screen_rect.modulate.a = 0
	screen_rect.color = Color.WHITE 
	
	tween.tween_property(screen_rect, "modulate:a", 1.0, 5.0) # Slow, heavy fade
	
	await tween.finished
	get_tree().change_scene_to_file("res://maps/boss_1m2.tscn")

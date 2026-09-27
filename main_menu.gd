extends Control

@onready var fade_rect = $ScreenFade
@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var main_menu_vbox = $VBoxContainer
@onready var senses_menu_layer = $VBoxContainer/SensesMenu

func _ready():
	# Connect buttons 
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	MusicController.play_music(preload("res://msuic/mein.mp3"))
	senses_menu_layer.hide()
	
	# Make sure fade starts invisible
	fade_rect.modulate.a = 0


func _on_start_pressed():
	start_button.disabled = true
	quit_button.disabled = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.8)
	tween.tween_callback(_go_to_intro)


func _go_to_intro():
	
	get_tree().change_scene_to_file("res://scene/intro_cutscene.tscn")
	

func _on_options_button_pressed():
	
	main_menu_vbox.hide() 
	
	
	senses_menu_layer.show() 
	print("Opening Senses Menu.")

func _on_quit_pressed():
	get_tree().quit()

func _on_senses_menu_menu_closed():
	
	$VBoxContainer.show() 

	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_2_pressed() -> void:
	pass # Replace with function body.




func _on_quit_button_pressed() -> void:
	pass # Replace with function body.


func _on_senses_menu_closed() -> void:
	pass # Replace with function body.

extends Control

@onready var credits_container = $ColorRect/VBoxContainer

func _ready():
	
	credits_container.position.y = get_viewport_rect().size.y
	
	
	var tween = create_tween()
	
	
	var target_y = -credits_container.get_combined_minimum_size().y
	
	
	tween.tween_property(credits_container, "position:y", target_y, 15.0)
	

	tween.finished.connect(_on_credits_finished)

func _on_credits_finished():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _input(event):
	
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		_on_credits_finished()

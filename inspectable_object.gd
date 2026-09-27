extends Area2D

@export_multiline var observation_text: String = "It's just an old object..."

var player_in_range = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "player":
		player_in_range = false
		var ui = get_tree().current_scene.get_node_or_null("CanvasLayer/ui_root/Panel")
		if ui: ui.hide()

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		display_message()

func display_message():
	var label = get_tree().current_scene.get_node_or_null("CanvasLayer/ui_root/Panel/VBoxContainer/RichTextLabel")
	var panel = get_tree().current_scene.get_node_or_null("CanvasLayer/ui_root/Panel")
	var btns = get_tree().current_scene.get_node_or_null("CanvasLayer/ui_root/VBoxContainer/HBoxContainer")
	
	if label and panel:
		panel.show()
		if btns: btns.hide() 
		label.text = observation_text
		label.visible_ratio = 0
		
		var tween = create_tween()
		tween.tween_property(label, "visible_ratio", 1.0, 1.0)

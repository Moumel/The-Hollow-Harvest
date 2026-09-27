extends StaticBody2D

@export var dialogue_panel: Panel
@export var dialogue_label: RichTextLabel
@export var ui_root: Control 
@export var dialogue_lines: Array[String] = ["Sup love one"]

var dialogue_text = [
	"You're as delicate as glass ... especially your heart.",
	"Yes. You are worthy of my grace.",
    "It means I love you."
]

var current_step = 0
var is_player_near = false

func _ready():
	$Area2D.body_entered.connect(_on_player_entered)
	$Area2D.body_exited.connect(_on_player_exited)
	
	if dialogue_panel:
		dialogue_panel.hide() 

func _on_player_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		is_player_near = true

func _on_player_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		is_player_near = false
		close_dialogue()

func _input(event):
	if is_player_near and event.is_action_pressed("interact"):
		advance_dialogue()

func advance_dialogue():
	if dialogue_panel:
		if ui_root: ui_root.show()
		dialogue_panel.show()
		
		if current_step < dialogue_lines.size():
			dialogue_label.text = dialogue_lines[current_step]
			dialogue_label.visible_ratio = 0.0
			
			var tween = get_tree().create_tween()
			tween.tween_property(dialogue_label, "visible_ratio", 1.0, 1.5)
			
			current_step += 1
		else:
			close_dialogue()

func close_dialogue():
	if dialogue_panel:
		dialogue_panel.hide()
	
	current_step = 0
	
	if dialogue_label != null:
		dialogue_label.visible_ratio = 3.5
	else:
		print("Warning: NPC tried to reset a label that isn't assigned!")

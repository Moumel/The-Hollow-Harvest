extends Control

@onready var label = $CenterContainer/VBoxContainer/RichTextLabel
@onready var btn_a = $CenterContainer/VBoxContainer/HBoxContainer/OptionA
@onready var btn_b = $CenterContainer/VBoxContainer/HBoxContainer/OptionB
@onready var fade_overlay = $CanvasLayer/FadeOverlay

var current_step = 0
var dialogue = []
var mc2_void_dialogue = [
	{
		"text": "You believed that if you fought hard enough, the [color=yellow]answer[/color] would change. But effort is not a currency you can trade for peace.",
		"options": ["I gave everything.", "It wasn't enough."]
	},
	{
		"text": "You used the [color=yellow]Cursed Dagger[/color] to sever fate. But a blade with two edges always cuts the wielder last.",
		"options": ["I feel nothing.", "The debt is paid."]
	},
	{
		"text": "Ambition is just a [shake]fever[/shake]. You won the battle, but you lost the strength to stand in the world you 'saved'.",
		"options": ["Let me rest.", "..."]
	}
]


func _ready():
	if Global.current_soul_count == 2:
		dialogue = mc2_void_dialogue
	else:
		dialogue = [
	{
		"text": "To breathe is a [shake]sin[/shake]. To think is a [shake]sin[/shake]. You are finally free from the crime of your own heartbeat.",
		"options": ["I am clean.", "The noise stopped."]
	},
	{
		"text": "You chose the blade because you were too [color=yellow]proud[/color] to let the world see you bleed like an ordinary man.",
		"options": ["My pain was mine.", "I was just a man."]
	},
	{
		"text": "You haven't escaped the Harvest, you’ve simply become the whetstone. How truly... [wave]pitiful[/wave].",
		"options": ["...", "..."]
	}
]
	
	btn_a.pressed.connect(_on_choice_selected.bind(0))
	btn_b.pressed.connect(_on_choice_selected.bind(1))
	
	show_text()
	fade_overlay.show()
	fade_overlay.modulate.a = 1.0 
	
	var fade_in = create_tween()
	fade_in.tween_property(fade_overlay, "modulate:a", 0.0, 1.5)
	
	await fade_in.finished
	fade_overlay.hide()

func show_text():
	btn_a.hide()
	btn_b.hide()
	
	label.bbcode_enabled = true
	label.text = dialogue[current_step]["text"]
	label.visible_ratio = 0
	
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, 3.0)
	
	await tween.finished
	btn_a.text = dialogue[current_step]["options"][0]
	btn_b.text = dialogue[current_step]["options"][1]
	btn_a.show()
	btn_b.show()

func _on_choice_selected(index):
	var fade_out = create_tween()
	await fade_out.tween_property(self, "modulate:a", 0.0, 0.5).finished
	current_step += 1
	
	if current_step < dialogue.size():
		self.modulate.a = 1.0
		show_text()
	else:
		fade_overlay.show()
		fade_overlay.modulate.a = 0
		var final_exit = create_tween()
		if Global.current_soul_count == 2:
			Global.current_soul_count = 3 
			get_tree().change_scene_to_file("res://scene/credits.tscn")
			
		else:
			Global.current_soul_count = 2
			get_tree().change_scene_to_file("res://hub_alt.tscn")

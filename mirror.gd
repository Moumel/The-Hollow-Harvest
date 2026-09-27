extends Area2D

var is_player_in_range = false

func _ready():
	# Connect signals to detect the player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player": # Adjust this to match your Player node name
		is_player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false

func _input(event):
	# Check if player is nearby and presses the interaction key (e.g., 'E' or 'ui_accept')
	if is_player_in_range and event.is_action_pressed("ui_accept"):
		interact()

func interact():
	print("The mirror reflects a weary face...")
	# Add your dialogue or event logic here

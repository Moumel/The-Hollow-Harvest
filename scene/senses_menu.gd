extends CanvasLayer

# --- Node References ---
@onready var res_dropdown = $Panel/VBoxContainer/HBoxContainer_Vision/OptionButton_Res
@onready var fs_checkbox = $Panel/VBoxContainer/HBoxContainer_Vision/CheckBox_FS
@onready var vol_slider = $Panel/VBoxContainer/HBoxContainer_Sound/HSlider_Volume
signal menu_closed

# The name of the Master audio bus.
const MASTER_BUS_NAME = "Master"
# Store the index for performance.
@onready var master_bus_index = AudioServer.get_bus_index(MASTER_BUS_NAME)

func _ready():
	# Ensure the menu is hidden when the game starts.
	#hide() 
	
	# INITIAL UI SYNC (Set the sliders/boxes to match the current game state)
	
	# 1. Sync Volume
	var initial_vol_db = AudioServer.get_bus_volume_db(master_bus_index)
	# Convert DB volume (-60 to 0) into linear volume (0.0 to 1.0) for the slider.
	vol_slider.value = db_to_linear(initial_vol_db)

	# 2. Sync Fullscreen
	# In Godot 4, check if the Window Mode is set to Fullscreen or Exclusive Fullscreen.
	var current_mode = DisplayServer.window_get_mode()
	fs_checkbox.button_pressed = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


# --- SIGNAL HANDLERS (Connect nodes to these) ---

# 1. Connected from OptionButton_Res -> item_selected()
func _on_option_button_res_item_selected(index):
	match index:
		0: # User selected "640x480 Windowed"
			# 1. Revert to Windowed Mode (Must do this before setting size)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			# 2. Set the window resolution (The OS window size)
			DisplayServer.window_set_size(Vector2i(640, 480))
			# Uncheck the fullscreen box (good UI practice)
			fs_checkbox.button_pressed = false
			print("Resolution set to 640x480.")
		1: # User selected "Toggle Fullscreen"
			# This item is essentially the same as the checkbox, 
			# but presented in the dropdown. 
			_on_check_box_fs_toggled(true)
			# Also update the checkbox so they stay in sync.
			fs_checkbox.button_pressed = true


# 2. Connected from CheckBox_FS -> toggled(toggled_on)
func _on_check_box_fs_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		print("Switched to Fullscreen.")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# OPTIONAL: You may want to call 640x480 size here to revert cleanly.
		DisplayServer.window_set_size(Vector2i(640, 480))
		print("Switched to Windowed.")


# 3. Connected from HSlider_Volume -> value_changed(value)
func _on_h_slider_volume_value_changed(value):
	# We divide by 100 because Godot's math expects 0.0 to 1.0
	# So 100 becomes 1.0, and 10 becomes 0.1
	var normalized_value = value / 100.0
	
	# We use 0.0001 instead of 0 to avoid a math error (log of zero)
	var volume_db = linear_to_db(max(normalized_value, 0.0001))
	
	AudioServer.set_bus_volume_db(master_bus_index, volume_db)
	
	# This will now print a normal range (around -20dB to 0dB)
	print("Slider Value: ", value, " | DB: ", volume_db)


# 4. Connected from Button_Back -> pressed()
func _on_button_back_pressed():
	# Hide the Senses Menu.
	hide() 
	# You must now re-enable input or visibility for your Main Menu nodes!
	# We will handle this in Step 4.
	menu_closed.emit()
	print("Exiting Senses Menu.")


func _on_h_slider_changed() -> void:
	pass # Replace with function body.

extends Area2D

var is_transitioning = false
func _on_body_entered(body):
	print("--- COLLISION DETECTED ---")
	print("Body Name: ", body.name)
	print("Is in 'player' group?: ", body.is_in_group("player"))
	print("Current Soul: ", Global.current_soul_count)

	if is_transitioning: return 
	
	if body.is_in_group("player"):
	  
		if Global.current_soul_count == 1:
			is_transitioning = true
			print("MC1 detected. Preparing transition to Boss...")

			
			if Global.has_met_pride:
				print("Triggering Dagger Instinct effect before leaving...")
				var current_hub = get_tree().current_scene
				if current_hub.has_method("start_dagger_instinct"):
					current_hub.start_dagger_instinct()
				
				
				await get_tree().create_timer(0.5).timeout

		   
			print("Changing scene to: res://maps/node_2d.tscn")
			get_tree().call_deferred("change_scene_to_file", "res://maps/node_2d.tscn")

		if Global.current_soul_count == 2:
			print("Attempting to load MC2 scene (Dagger Void)...")
			var error = get_tree().change_scene_to_file("res://scene/dagger_void.tscn")
			if error != OK:
				print("SCENE LOAD ERROR: ", error)
	else:
		print("Collision ignored: Body is not in 'player' group.")

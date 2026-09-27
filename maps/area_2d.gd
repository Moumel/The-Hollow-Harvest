extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		
		call_deferred("_change_to_boss_scene")

func _change_to_boss_scene():
	get_tree().change_scene_to_file("res://fight_scene/BossPride.tscn")

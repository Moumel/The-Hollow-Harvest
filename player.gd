extends CharacterBody2D

@export var speed = 120.0
@onready var _animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * speed
	move_and_slide()

	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				_animated_sprite.play("walk_right")
			else:
				_animated_sprite.play("walk_left")
		else:
			if direction.y > 0:
				_animated_sprite.play("walk_down")
			else:
				_animated_sprite.play("walk_up")
	else:
		_animated_sprite.stop()
		_animated_sprite.frame = 0

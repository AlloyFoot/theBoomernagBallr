extends CharacterBody2D

@export var speed: float = 40.0 # Lower number = slower walk speed (try 30 to 50)

@onready var sprite: Sprite2D = $Sprite2D # Adjust if your sprite has a different name

func _physics_process(_delta: float) -> void:
	var player = get_tree().current_scene.get_node_or_null("Player")

	if player:
		var distance = global_position.distance_to(player.global_position)
		
		# Only move if further than 25 pixels away to prevent getting stuck in the player
		if distance > 25.0:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed

			# Safely flip sprite based on walking direction
			if sprite and direction.x != 0:
				sprite.flip_h = direction.x < 0
		else:
			# Stop moving/pushing when close enough to touch
			velocity = Vector2.ZERO

		move_and_slide()

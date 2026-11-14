extends Area2D

signal returned

enum State { IDLE, THROWING, RETURNING }
var current_state = State.IDLE

var player: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var speed: float = 600.0
var max_distance: float = 400.0
var traveled_distance: float = 0.0

# Grace period timer so it doesn't instantly hit the player on spawn
var ignore_player_timer: float = 0.15

func throw(throw_direction: Vector2, throwing_player: Node2D) -> void:
	player = throwing_player
	current_state = State.THROWING
	velocity = throw_direction.normalized() * speed
	traveled_distance = 0.0
	ignore_player_timer = 0.15
	
	var world = get_tree().current_scene
	var current_parent = get_parent()
	if current_parent != world:
		current_parent.remove_child(self)
		world.add_child(self)
		# Spawn further ahead of the player to avoid collision overlap
		global_position = throwing_player.global_position + (throw_direction.normalized() * 40.0)

func _physics_process(delta: float) -> void:
	if ignore_player_timer > 0:
		ignore_player_timer -= delta

	match current_state:
		State.IDLE:
			return
			
		State.THROWING:
			position += velocity * delta
			traveled_distance += velocity.length() * delta
			rotation += 25.0 * delta
			
			if traveled_distance >= max_distance:
				current_state = State.RETURNING
				
		State.RETURNING:
			if not is_instance_valid(player):
				_catch_and_destroy()
				return
				
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			position += velocity * delta
			rotation += 25.0 * delta
			
			if global_position.distance_to(player.global_position) < 30.0:
				_catch_and_destroy()

func _catch_and_destroy() -> void:
	returned.emit()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		if current_state == State.RETURNING and ignore_player_timer <= 0:
			_catch_and_destroy()
		return
		
	elif body.is_in_group("Zombies"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
			
		if current_state == State.THROWING:
			current_state = State.RETURNING
			
	elif not body.is_in_group("Player") and current_state == State.THROWING:
		current_state = State.RETURNING

extends Node2D

@export var zombie_scene: PackedScene

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)

func _on_spawn_timer_timeout() -> void:
	if not zombie_scene:
		print("ERROR: Zombie Scene export slot is empty!")
		return
		
	var player = get_node_or_null("Player")
	if not player:
		print("ERROR: Player node not found!")
		return
		
	var zombie = zombie_scene.instantiate()
	zombie.global_position = player.global_position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
	add_child(zombie)
	print("Zombie spawned successfully!")

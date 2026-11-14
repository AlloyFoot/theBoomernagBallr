extends CharacterBody2D

signal health_changed(current_hp: int)
signal player_died

var speed = 300.0 

@export var max_hp: int = 3
var current_hp: int
var is_invulnerable: bool = false # Cooldown flag so you don't instantly die

const BOOMERANG_SCENE = preload("res://scenes/boomerang.tscn")
var can_throw: bool = true

@onready var ui: CanvasLayer = get_node_or_null("../UI")

func _ready() -> void:
	current_hp = max_hp
	if ui:
		ui.update_health(current_hp)

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	var move_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	
	if move_dir != Vector2.ZERO:
		velocity = speed * move_dir
		
		if move_dir.x != 0:
			$playerSprite.flip_h = move_dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()

	# Check if we bumped into a zombie
	if not is_invulnerable:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider and collider.is_in_group("Zombies"):
				take_damage(1)
				start_invulnerability()
				break # Only take damage from one zombie per check

func take_damage(amount: int = 1) -> void:
	if current_hp <= 0:
		return
		
	current_hp = clamp(current_hp - amount, 0, max_hp)
	health_changed.emit(current_hp)
	
	if ui:
		ui.update_health(current_hp)
		
	if current_hp <= 0:
		die()

func start_invulnerability() -> void:
	is_invulnerable = true
	
	# Optional visual feedback: make the sprite flash or semi-transparent
	$playerSprite.modulate.a = 0.5 
	
	# Wait for 1 second before allowing damage again
	await get_tree().create_timer(1.0).timeout
	
	is_invulnerable = false
	$playerSprite.modulate.a = 1.0 # Restore normal opacity

func heal(amount: int = 1) -> void:
	current_hp = clamp(current_hp + amount, 0, max_hp)
	health_changed.emit(current_hp)
	if ui:
		ui.update_health(current_hp)

func die() -> void:
	player_died.emit()
	set_physics_process(false)
	if ui and ui.has_method("stop_timer"):
		ui.stop_timer()
	if ui and ui.has_method("show_game_over"):
		ui.show_game_over()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_boomerang") and can_throw:
		throw_boomerang()

func throw_boomerang() -> void:
	can_throw = false
	
	var boomerang = BOOMERANG_SCENE.instantiate()
	var throw_dir = (get_global_mouse_position() - global_position).normalized()
	
	get_tree().current_scene.add_child(boomerang)
	boomerang.global_position = global_position
	
	boomerang.returned.connect(_on_boomerang_returned)
	boomerang.throw(throw_dir, self)

func _on_boomerang_returned() -> void:
	can_throw = true

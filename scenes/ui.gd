extends CanvasLayer

@onready var hearts: Array[Node] = $Control/HBoxContainer.get_children()
@onready var timer_label: Label = $Control/TimerLabel

@onready var game_over_screen: Control = $GameOverScreen
@onready var final_time_label: Label = $GameOverScreen/VBoxContainer/FinalTimeLabel
@onready var restart_button: Button = $GameOverScreen/VBoxContainer/RestartButton

var survival_time: float = 0.0
var game_active: bool = true

func _ready() -> void:
	game_over_screen.hide()
	restart_button.pressed.connect(_on_restart_button_pressed)

func _process(delta: float) -> void:
	if not game_active:
		return
		
	survival_time += delta
	
	var minutes: int = int(survival_time) / 60
	var seconds: int = int(survival_time) % 60
	
	if timer_label:
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func update_health(current_hp: int) -> void:
	for i in range(hearts.size()):
		hearts[i].visible = i < current_hp

func show_game_over() -> void:
	game_active = false
	var minutes: int = int(survival_time) / 60
	var seconds: int = int(survival_time) % 60
	
	final_time_label.text = "You Survived: %02d:%02d" % [minutes, seconds]
	game_over_screen.show()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

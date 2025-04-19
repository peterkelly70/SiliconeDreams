# splash_controller.gd

extends Control

@onready var background := $Background
@onready var start_button := $VBoxContainer/StartButton
@onready var options_button := $VBoxContainer/OptionsButton
@onready var exit_button := $VBoxContainer/ExitButton

func _ready():
	print("Splash scene ready!")
	# Force processing even if the rest of the scene is paused.
	process_mode = PROCESS_MODE_ALWAYS
	set_process(true)
	
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _process(delta: float) -> void:
	var mat: ShaderMaterial = background.material as ShaderMaterial
	if mat:
		var time_sec := Time.get_ticks_msec() / 1000.0
		mat.set_shader_parameter("time", time_sec)
		mat.set_shader_parameter("screen_size", get_viewport_rect().size)
		print("Shader time updated:", time_sec)
	else:
		print("ShaderMaterial not found on background.")

func _on_start_pressed():
	StateManager.set_state(StateManager.GameState.PUZZLE)

func _on_options_pressed():
	print("Options menu not implemented yet.")

func _on_exit_pressed():
	get_tree().quit()

# end of splash_controller.gd

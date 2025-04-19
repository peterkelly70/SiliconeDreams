# puzzle_screen.gd
# Godot 4.4 minimal puzzle screen scene script.
# This script creates a full-screen dark background as a placeholder,
# centers the scene in the viewport, and rotates it around its center.
# (Rotation is just for debugging; in your actual game you can remove it.)

extends Node2D

func _ready():
	print("Puzzle Screen Ready!")
	
	# Get the current viewport size.
	var vp_size: Vector2 = get_viewport_rect().size
	
	# Center this Node2D in the viewport.
	# When you rotate this Node2D, it will rotate around its position.
	position = vp_size / 2.0
	
	# Create a ColorRect to serve as a full-screen background.
	# We want its center aligned with the Node2D's origin.
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 1.0)  # Dark gray background.
	# Set its position so that its center is at (0,0).
	bg.position = -vp_size / 2.0
	bg.size = vp_size
	add_child(bg)
	
	# (Optional) Initialize the rest of your puzzle here.

func _process(_delta: float) -> void:
	# For debugging: slowly rotate the scene around the center.
	rotation += 0.2 * _delta

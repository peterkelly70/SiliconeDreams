extends Control

# your generator must have `class_name RandomPuzzleGenerator`
var RandomPuzzleGenerator = preload("res://scripts/random_puzzle_generator.gd")

const GRID_W := 10
const GRID_H := 15

# UI buttons
@onready var btn_generate = $Menu/GenerateBTN
@onready var btn_load     = $Menu/LoadBTN
@onready var btn_solve    = $Menu/SolveBTN
@onready var btn_play     = $Menu/PlayBTN
@onready var btn_check    = $Menu/CheckBTN

# file picker
@onready var puzzle_dialog = $PuzzleLoaderDialog

# controllers
@onready var puzzle_ctrl = $PuzzleController
@onready var play_ctrl   = $PlayController
@onready var load_ctrl   = $LoadController
@onready var check_ctrl  = $CheckController

# the TextureRect you added under Puzzle
@onready var preview: TextureRect = $Puzzle/PreviewRect

var current_puzzle: Array = []

func _ready() -> void:
	# configure file dialog
	puzzle_dialog.mode         = FileDialog.FILE_MODE_OPEN_FILE
	puzzle_dialog.access       = FileDialog.ACCESS_RESOURCES
	puzzle_dialog.current_path = "res://assets/puzzles/"
	puzzle_dialog.clear_filters()
	puzzle_dialog.add_filter("*.png")
	puzzle_dialog.file_selected.connect(_on_PuzzleLoaderDialog_file_selected)

	# hook up buttons
	btn_generate.pressed.connect(_on_generate)
	btn_load.    pressed.connect(_on_load_pressed)
	btn_solve.   pressed.connect(_on_solve)
	btn_play.    pressed.connect(_on_play)
	btn_check.   pressed.connect(_on_check)

func _on_generate() -> void:
	current_puzzle = RandomPuzzleGenerator.new().generate(GRID_W, GRID_H)
	puzzle_ctrl.render(current_puzzle, GRID_W, GRID_H)
	_update_preview_texture(current_puzzle, GRID_W, GRID_H)
	play_ctrl.reset_selections()

func _on_load_pressed() -> void:
	puzzle_dialog.popup_centered()

func _on_PuzzleLoaderDialog_file_selected(path: String) -> void:
	current_puzzle = load_ctrl.load_image(path, GRID_W, GRID_H)
	puzzle_ctrl.render(current_puzzle, GRID_W, GRID_H)
	_update_preview_texture(current_puzzle, GRID_W, GRID_H)
	play_ctrl.reset_selections()

func _on_solve() -> void:
	puzzle_ctrl.show_solution()

func _on_play() -> void:
	play_ctrl.start_play(puzzle_ctrl)

func _on_check() -> void:
	puzzle_ctrl.clear_errors()
	var wrong_cells = check_ctrl.check(
		puzzle_ctrl.user_selection,
		current_puzzle,
		GRID_W, GRID_H
	)
	for idx in wrong_cells:
		puzzle_ctrl.show_error(idx)

func _update_preview_texture(puzzle_flat: Array, w: int, h: int) -> void:
	var sz: int = puzzle_ctrl.cell_size
	var img = Image.new()
	img.create(w * sz, h * sz, false, Image.FORMAT_L8)
	for y in range(h):
		for x in range(w):
			var color = Color.BLACK if puzzle_flat[y * w + x] else Color.WHITE
			for dy in range(sz):
				for dx in range(sz):
					img.set_pixel(x * sz + dx, y * sz + dy, color)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	preview.texture = tex

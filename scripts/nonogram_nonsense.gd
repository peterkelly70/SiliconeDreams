# ────────────────────────────────────────────
#  nonogram_nonsense.gd
# ────────────────────────────────────────────
extends Control

# ─────────── Config ───────────
const GRID_W : int = 10
const GRID_H : int = 15
var RandomPuzzleGenerator := preload("res://scripts/random_puzzle_generator.gd")

# ───────── Scene nodes ─────────
@onready var btn_generate : Button = $Menu/GenerateBTN
@onready var btn_load     : Button = $Menu/LoadBTN
@onready var btn_solve    : Button = $Menu/SolveBTN
@onready var btn_play     : Button = $Menu/PlayBTN
@onready var btn_check    : Button = $Menu/CheckBTN

@onready var preview_rect  : TextureRect      = $Puzzle/PreviewRect
@onready var clue_layer    : ClueLayer        = $Puzzle/ClueLayer
@onready var puzzle_ctrl   : PuzzleController = $Puzzle/PuzzleController
@onready var play_ctrl     : Node             = $PlayController
@onready var check_ctrl    : Node             = $CheckController
@onready var puzzle_dialog : FileDialog       = $PuzzleLoaderDialog
@onready var load_ctrl     : Node             = $LoadController

# ───────── Runtime data ─────────
var current_grid : Array = []      # flat bools
var current_rows : Array = []      # row clue arrays
var current_cols : Array = []      # column clue arrays

# ─────────── Ready ───────────
func _ready() -> void:
	btn_generate.pressed.connect(_on_generate)
	btn_load.pressed.   connect(_on_load_pressed)
	btn_solve.pressed.  connect(_on_solve)
	btn_play.pressed.   connect(_on_play)
	btn_check.pressed.  connect(_on_check)

	puzzle_ctrl.hide()                      # keep splash visible at start

# ───────── Menu handlers ─────────
func _on_generate() -> void:
	var grid2d : Array = []
	for y in range(GRID_H):
		var row : Array = []
		for x in range(GRID_W):
			row.append(randf() < 0.5)
		grid2d.append(row)

	current_grid = []
	for r in grid2d: current_grid += r
	current_rows = _clue_rows(grid2d)
	current_cols = _clue_cols(grid2d)

	_show_preview(grid2d)
	clue_layer.show_clues(current_rows, current_cols)
	puzzle_ctrl.hide()

func _on_load_pressed() -> void:
	puzzle_dialog.popup_centered()

func _on_PuzzleLoaderDialog_file_selected(path : String) -> void:
	var result : Dictionary = load_ctrl.load_image(path, GRID_W, GRID_H)

	current_grid = result["flat"]
	current_rows = result["row_clues"]
	current_cols = result["col_clues"]

	var grid2d : Array = []
	for y in range(GRID_H):
		grid2d.append(current_grid.slice(y * GRID_W, GRID_W))

	_show_preview(grid2d)
	clue_layer.show_clues(current_rows, current_cols)
	puzzle_ctrl.hide()

func _on_solve() -> void:
	preview_rect.hide()
	puzzle_ctrl.show()
	puzzle_ctrl.render(current_grid, GRID_W, GRID_H)
	clue_layer.show_clues(current_rows, current_cols)

	# reveal actual solution
	for i in range(current_grid.size()):
		if current_grid[i]:
			puzzle_ctrl.cells[i].set_filled(true)

func _on_play() -> void:
	preview_rect.hide()
	puzzle_ctrl.show()
	puzzle_ctrl.render(current_grid, GRID_W, GRID_H)
	clue_layer.show_clues(current_rows, current_cols)
	play_ctrl.reset_selections()

func _on_check() -> void:
	puzzle_ctrl.clear_errors()
	var wrong : Array[int] = check_ctrl.check(
		puzzle_ctrl.user_selection,
		current_grid,
		GRID_W, GRID_H
	)
	for i in wrong:
		puzzle_ctrl.show_error(i)

# ───────── Helper functions ─────────
func _show_preview(grid2d : Array) -> void:
	var h := grid2d.size()
	var w := (grid2d[0] as Array).size()
	var img := Image.create(w, h, false, Image.FORMAT_L8)
	for y in range(h):
		for x in range(w):
			img.set_pixel(x, y, Color.BLACK if grid2d[y][x] else Color.WHITE)
	preview_rect.texture         = ImageTexture.create_from_image(img)
	preview_rect.expand_mode     = TextureRect.EXPAND_IGNORE_SIZE
	preview_rect.stretch_mode    = TextureRect.STRETCH_SCALE
	preview_rect.show()

func _clue_rows(grid : Array) -> Array:
	var out : Array = []
	for r in grid: out.append(_clue_line(r))
	return out

func _clue_cols(grid : Array) -> Array:
	var h := grid.size()
	var w := (grid[0] as Array).size()
	var out : Array = []
	for x in range(w):
		var col : Array = []
		for y in range(h):
			col.append(grid[y][x])
		out.append(_clue_line(col))
	return out

func _clue_line(line : Array) -> Array:
	var res : Array = []
	var cnt : int = 0
	for v in line:
		if v:
			cnt += 1
		elif cnt > 0:
			res.append(cnt)
			cnt = 0
	if cnt > 0:
		res.append(cnt)
	if res.is_empty():
		res.append(0)
	return res
# ────────────────────────────────────────────
#  end nonogram_nonsense.gd
# ────────────────────────────────────────────

# nonogram_nonsense.gd
extends Control
class_name NonogramNonsense

# ───────── Layout Offset ─────────
@export var origin : Vector2 = Vector2(0, 0)  # top-left corner of puzzle & clues

# ──────────────────────── Config ─────────────────────────
@export var GRID_W     : int = 10   # columns
@export var GRID_H     : int = 15   # rows
@export var CELL_SIZE  : int = 24   # pixel size per cell
@export var MENU_MARGIN: int = 20   # space between menu and puzzle

# ───────── Scene nodes ──────────────────────
@onready var btn_generate : Button     = $Menu/GenerateBTN
@onready var btn_play     : Button     = $Menu/PlayBTN
@onready var btn_check    : Button     = $Menu/CheckBTN
@onready var btn_solve    : Button     = $Menu/SolveBTN

@onready var preview      : TextureRect = $Puzzle/PreviewRect
@onready var grid         : PuzzleGrid  = $Puzzle/Grid
@onready var clues        : ClueLayer   = $Puzzle/Clues

# ───────── Runtime data ─────────
var current_grid : Array[int] = []   # flat 0/1 ints
var row_clues    : Array      = []   # row clue arrays
var col_clues    : Array      = []   # column clue arrays

func _ready() -> void:
	# calculate origin to the right of the menu
	var menu_width = $Menu.get_size().x
	origin = Vector2(menu_width + MENU_MARGIN, 0)
	# position preview and grid at origin
	preview.position = origin
	grid.position    = origin

	preview.show()
	grid.hide()

	btn_generate.pressed.connect(_on_generate)
	btn_play.pressed.connect(_on_play)
	btn_check.pressed.connect(_on_check)
	btn_solve.pressed.connect(_on_solve)

# ───────── Menu handlers ─────────
func _on_generate() -> void:
	_build_random_puzzle()

	# draw 1px-per-cell base image
	var img := Image.create(GRID_W, GRID_H, false, Image.FORMAT_L8)
	for y in range(GRID_H):
		for x in range(GRID_W):
			img.set_pixel(x, y, Color.BLACK if current_grid[y * GRID_W + x] else Color.WHITE)
	# scale up with nearest neighbor for crisp pixels
	img.resize(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE, Image.INTERPOLATE_NEAREST)

	var tex := ImageTexture.create_from_image(img)
	preview.texture      = tex
	# ensure the preview rect matches exact size
	preview.custom_minimum_size = Vector2(GRID_W, GRID_H) * CELL_SIZE
	preview.stretch_mode        = TextureRect.STRETCH_KEEP
	preview.position            = origin
	preview.show()

	# update clues around the preview
	
	clues.set_clues(row_clues, col_clues)
	grid.hide()

func _on_play() -> void:
	preview.hide()
	grid.position = origin
	grid.show()
	grid.build_grid(current_grid, GRID_W, GRID_H)
	
	clues.set_clues(row_clues, col_clues)
	grid.reset_cells()

func _on_check() -> void:
	grid.show_wrong_cells()

func _on_solve() -> void:
	grid.reveal_solution()

# ───────── Internals ─────────
func _build_random_puzzle() -> void:
	current_grid.resize(GRID_W * GRID_H)
	for i in range(current_grid.size()):
		current_grid[i] = int(randf() < 0.5)

	# compute row/col clues
	var mat : Array = []
	for y in range(GRID_H):
		var start := y * GRID_W
		mat.append(current_grid.slice(start, start + GRID_W))

	row_clues = _compute_clues(mat)
	col_clues = _compute_clues(_transpose(mat))

func _compute_clues(mat : Array) -> Array:
	var out : Array = []
	for line in mat:
		var res : Array = []
		var cnt : int = 0
		for v in line:
			if v == 1:
				cnt += 1
			elif cnt > 0:
				res.append(str(cnt))
				cnt = 0
		if cnt > 0:
			res.append(str(cnt))
		if res.is_empty():
			res.append("0")
		out.append(res)
	return out

func _transpose(mat : Array) -> Array:
	var out : Array = []
	if mat.is_empty():
		return out
	var w : int = (mat[0] as Array).size()
	var h : int = mat.size()
	for x in range(w):
		var col : Array = []
		for y in range(h):
			col.append(mat[y][x])
		out.append(col)
	return out
# end nonogram_nonsense.gd

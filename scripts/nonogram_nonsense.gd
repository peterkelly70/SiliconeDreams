# nonogram_nonsense.gd
extends Control
class_name NonogramNonsense

# ─────────────────────── Config ─────────────────────────
@export var GRID_W    : int = 10   # number of columns
@export var GRID_H    : int = 10   # number of rows
@export var CELL_SIZE : int = 24   # pixel size per cell

# ───────── Scene references ─────────────────────────
# Adjust these paths to match your actual scene tree
@onready var btn_generate : Button      = $Menu/GenerateBTN
@onready var btn_play     : Button      = $Menu/PlayBTN
@onready var btn_check    : Button      = $Menu/CheckBTN
@onready var btn_solve    : Button      = $Menu/SolveBTN

# Preview and grid are children of "Puzzle" Control
@onready var preview      : TextureRect = $Puzzle/PreviewRect
@onready var grid         : PuzzleGrid  = $Puzzle/Grid
@onready var clues        : ClueLayer   = $Puzzle/Clues

# ───────── Runtime data ─────────────────────────
var current_grid2d : Array = []             # 2D grid: Array of Array[int]
var row_clues      : Array = []             # row clue arrays
var col_clues      : Array = []             # column clue arrays

func _ready() -> void:
	# ensure preview is visible at start and grid is hidden
	if preview:
		preview.show()
	if grid:
		grid.hide()

	btn_generate.pressed.connect(_on_generate)
	btn_play.pressed.connect(_on_play)
	btn_check.pressed.connect(_on_check)
	btn_solve.pressed.connect(_on_solve)

# ───────── Menu handlers ─────────
func _on_generate() -> void:
	_build_random_puzzle()

	# render preview image
	var img = Image.create(GRID_W, GRID_H, false, Image.FORMAT_L8)
	for y in range(GRID_H):
		for x in range(GRID_W):
			img.set_pixel(x, y, Color.BLACK if current_grid2d[y][x] == 1 else Color.WHITE)
	# scale up with nearest neighbor
	img.resize(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE, Image.INTERPOLATE_NEAREST)

	var tex = ImageTexture.create_from_image(img)
	preview.texture = tex
	preview.custom_minimum_size = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	preview.show()
	grid.hide()

	# draw clues next to preview
	clues.set_clues(row_clues, col_clues)

func _on_play() -> void:
	# swap in interactive grid
	if preview:
		preview.hide()
	grid.build_grid_2d(current_grid2d, GRID_W, GRID_H)
	grid.custom_minimum_size = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	grid.reset_cells()
	grid.show()

	# draw clues next to grid
	clues.set_clues(row_clues, col_clues)

func _on_check() -> void:
	# highlight wrong cells
	grid.show_wrong_cells()

func _on_solve() -> void:
	# reveal solution
	grid.reveal_solution()

# ───────── Internals ─────────
func _build_random_puzzle() -> void:
	current_grid2d.clear()
	# generate random 2D grid
	for y in range(GRID_H):
		var row : Array[int] = []
		for x in range(GRID_W):
			row.append(int(randf() < 0.5))
		current_grid2d.append(row)

	# compute clues
	row_clues = _compute_clues(current_grid2d)
	col_clues = _compute_clues(_transpose(current_grid2d))

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
		var col : Array[int] = []
		for y in range(h):
			col.append(mat[y][x])
		out.append(col)
	return out
# end nonogram_nonsense.gd

# nonogram_nonsense.gd
extends Control
class_name NonogramNonsense

# ─────────────────────── Config ─────────────────────────
@export var GRID_W     : int = 10   # number of columns
@export var GRID_H     : int = 10   # number of rows
@export var CELL_SIZE  : int = 24   # pixel size per cell

# ───────── Scene references ─────────────────────────
@onready var btn_generate : Button      = $Menu/GenerateBTN
@onready var btn_play     : Button      = $Menu/PlayBTN
@onready var btn_check    : Button      = $Menu/CheckBTN
@onready var btn_solve    : Button      = $Menu/SolveBTN

@onready var preview      : TextureRect = $Puzzle/PreviewRect
@onready var grid         : PuzzleGrid  = $Puzzle/Grid
@onready var clues        : ClueLayer   = $Puzzle/Clues

# ───────── Runtime data ─────────────────────────
var current_grid : Array[int] = []  # flat array of 0/1
var row_clues    : Array      = []  # row clues
var col_clues    : Array      = []  # column clues

func _ready() -> void:
	# show preview on generate, hide grid initially
	preview.show()
	grid.hide()

	# connect menu buttons
	btn_generate.pressed.connect(_on_generate)
	btn_play.pressed.connect(_on_play)
	btn_check.pressed.connect(_on_check)
	btn_solve.pressed.connect(_on_solve)

func _on_generate() -> void:
	_build_random_puzzle()

	# draw a 1px-per-cell image and scale nearest-neighbor
	var img := Image.create(GRID_W, GRID_H, false, Image.FORMAT_L8)
	for y in range(GRID_H):
		for x in range(GRID_W):
			img.set_pixel(x, y, Color.BLACK if current_grid[y * GRID_W + x] else Color.WHITE)
	img.resize(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE, Image.INTERPOLATE_NEAREST)

	var tex := ImageTexture.create_from_image(img)
	preview.texture = tex
	preview.custom_minimum_size = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	preview.show()
	grid.hide()

	# update clues around preview
	clues.set_clues(row_clues, col_clues)

func _on_play() -> void:
	preview.hide()
	grid.build_grid(current_grid, GRID_W, GRID_H)
	clues.set_clues(row_clues, col_clues)
	grid.reset_cells()
	grid.show()

func _on_check() -> void:
	grid.show_wrong_cells()

func _on_solve() -> void:
	grid.reveal_solution()

func _build_random_puzzle() -> void:
	# random flat grid
	current_grid.resize(GRID_W * GRID_H)
	for i in range(current_grid.size()):
		current_grid[i] = int(randf() < 0.5)

	# build 2D matrix for clues
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
		var cnt := 0
		for v in line:
			if v == 1:
				cnt += 1
			elif cnt > 0:
				res.append(str(cnt)); cnt = 0
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
	var w := (mat[0] as Array).size()
	var h := mat.size()
	for x in range(w):
		var col : Array = []
		for y in range(h):
			col.append(mat[y][x])
		out.append(col)
	return out
# end nonogram_nonsense.gd

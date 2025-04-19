extends Node

@onready var generate_button: Button = $Menu/GenerateBTN
@onready var load_button: Button = $Menu/LoadBTN
@onready var solve_button: Button = $Menu/SolveBTN
@onready var play_button: Button = $Menu/PlayBTN
var check_button: Button = null

@onready var puzzle_display: TextureRect = $Puzzle
@onready var clue_layer: Control = $Puzzle/ClueLayer

var generator: Node = preload("res://scripts/random_puzzle_generator.gd").new()
var last_loaded_path: String = ""
var player_grid: Array = []
var cell_size: int = 24

func _ready() -> void:
	generate_button.pressed.connect(_on_generate_pressed)
	load_button.pressed.connect(_on_load_pressed)
	solve_button.pressed.connect(_on_solve_pressed)
	play_button.pressed.connect(_on_play_pressed)
	if $Menu.has_node("CheckBTN"):
		check_button = $Menu/CheckBTN
		check_button.pressed.connect(_on_check_pressed)
	puzzle_display.gui_input.connect(_on_puzzle_clicked)
	
	# Make sure clue layer is visible
	clue_layer.show()

# Generate a new puzzle and display it
func _on_generate_pressed() -> void:
	print("🧩 Generating new puzzle...")
	var path: String = generator.generate_and_save_random_puzzle(15, 15)
	if path != "":
		_display_puzzle_from_file(path)

# Placeholder for load functionality
func _on_load_pressed() -> void:
	print("📂 Load not yet implemented.")

# Show the solution grid
func _on_solve_pressed() -> void:
	print("🧠 Showing solution grid...")
	if last_loaded_path == "":
		printerr("❌ No puzzle loaded.")
		return
	var data: Dictionary = _load_puzzle_data(last_loaded_path)
	if data.size() == 0:
		return
	_render_full_puzzle(data)

# Enter play mode
func _on_play_pressed() -> void:
	print("🎮 Entering play mode...")
	_load_player_grid_from_last_path()

# Check player's solution
func _on_check_pressed() -> void:
	print("✅ Checking solution...")
	if last_loaded_path == "":
		printerr("❌ No puzzle loaded.")
		return
	var data: Dictionary = _load_puzzle_data(last_loaded_path)
	if data.size() == 0:
		return
	_highlight_errors(data)

# Handle cell clicks
func _on_puzzle_clicked(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event
	if not mb.pressed:
		return
	if player_grid.size() == 0:
		print("No player grid initialized")
		return
		
	var grid_w: int = player_grid[0].size()
	var grid_h: int = player_grid.size()
	var data: Dictionary = _load_puzzle_data(last_loaded_path)
	if data.size() == 0:
		return
	var row_clues: Array = data.get("row_clues", [])
	var col_clues: Array = data.get("col_clues", [])
	var margins: Vector2 = _compute_margins(row_clues, col_clues)
	var margin_left: int = int(margins.x)
	var margin_top: int = int(margins.y)
	
	# Get local position within the texture
	var local_x: int = int(mb.position.x)
	var local_y: int = int(mb.position.y)
	
	# Calculate grid position
	var x: int = (local_x - margin_left) / cell_size
	var y: int = (local_y - margin_top) / cell_size
	
	print("Click at: ", mb.position, " translated to grid: (", x, ", ", y, ")")
	
	if x < 0 or y < 0 or x >= grid_w or y >= grid_h:
		print("Click outside grid bounds")
		return
	
	# Toggle fill or mark empty
	var cur: int = player_grid[y][x]
	if mb.button_index == MOUSE_BUTTON_LEFT:
		var nxt: int = -1
		if cur == -1:
			nxt = 1  # Fill
		elif cur == 1:
			nxt = 0  # Mark as empty
		else:  # cur == 0
			nxt = -1  # Reset to unknown
		player_grid[y][x] = nxt
	elif mb.button_index == MOUSE_BUTTON_RIGHT:
		player_grid[y][x] = 0  # Mark as empty
	
	print("Cell value changed to: ", player_grid[y][x])
	_render_play_puzzle(data)

# Load and initialize player grid
func _load_player_grid_from_last_path() -> void:
	if last_loaded_path == "":
		printerr("❌ No puzzle to play.")
		return
	var data: Dictionary = _load_puzzle_data(last_loaded_path)
	if data.size() == 0:
		return
	var width: int = int(data.get("width", 0))
	var height: int = int(data.get("height", 0))
	
	# Clear and initialize player grid
	player_grid.clear()
	for i in range(height):
		var row: Array = []
		for j in range(width):
			row.append(-1)  # -1 means unknown state
		player_grid.append(row)
	
	print("Player grid initialized with dimensions: ", height, "x", width)
	_render_play_puzzle(data)

# Display puzzle from file path
func _display_puzzle_from_file(path: String) -> void:
	print("Loading puzzle from: ", path)
	var data: Dictionary = _load_puzzle_data(path)
	if data.size() == 0:
		return
	last_loaded_path = path
	_render_full_puzzle(data)

# Helpers
func _load_puzzle_data(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("❌ Could not open: ", path)
		return {}
	
	var json_text = file.get_as_text()
	file.close()
	
	var json_result = JSON.parse_string(json_text)
	if json_result == null:
		printerr("❌ JSON parse error")
		return {}
	
	return json_result

func _compute_margins(row_clues: Array, col_clues: Array) -> Vector2:
	var max_rc: int = 0
	for rc in row_clues:
		var sz: int = rc.size()
		if sz > max_rc:
			max_rc = sz
	
	var max_cc: int = 0
	for cc in col_clues:
		var sz: int = cc.size()
		if sz > max_cc:
			max_cc = sz
	
	var margins = Vector2(max_rc * cell_size, max_cc * cell_size)
	print("Calculated margins: ", margins)
	return margins

func _render_full_puzzle(data: Dictionary) -> void:
	var row_clues: Array = data.get("row_clues", [])
	var col_clues: Array = data.get("col_clues", [])
	var grid: Array = data.get("grid", [])
	_draw_puzzle_with_margins(grid, row_clues, col_clues)

func _render_play_puzzle(data: Dictionary) -> void:
	var row_clues: Array = data.get("row_clues", [])
	var col_clues: Array = data.get("col_clues", [])
	_draw_puzzle_with_margins(player_grid, row_clues, col_clues)

func _highlight_errors(data: Dictionary) -> void:
	print("Highlighting errors...")
	# First clear any previous error highlights
	for child in clue_layer.get_children():
		if child is ColorRect:  # Only remove error highlights, not labels
			child.queue_free()
	
	var solution: Array = data.get("grid", [])
	var row_clues: Array = data.get("row_clues", [])
	var col_clues: Array = data.get("col_clues", [])
	var margins: Vector2 = _compute_margins(row_clues, col_clues)
	
	var error_count = 0
	for y in range(min(player_grid.size(), solution.size())):
		for x in range(min(player_grid[y].size(), solution[y].size())):
			# Only mark cells that are filled or marked but incorrect
			if player_grid[y][x] != -1 and solution[y][x] != player_grid[y][x]:
				var mark = ColorRect.new()
				mark.color = Color(1, 0, 0, 0.4)  # Semi-transparent red
				mark.size = Vector2(cell_size, cell_size)
				mark.position = Vector2(margins.x + x * cell_size, margins.y + y * cell_size)
				clue_layer.add_child(mark)
				error_count += 1
	
	print("Found ", error_count, " errors in solution")

func _draw_puzzle_with_margins(grid: Array, row_clues: Array, col_clues: Array) -> void:
	var margins: Vector2 = _compute_margins(row_clues, col_clues)
	var ml: int = int(margins.x)
	var mt: int = int(margins.y)
	var gw: int = grid[0].size()
	var gh: int = grid.size()
	var img_w: int = ml + gw * cell_size
	var img_h: int = mt + gh * cell_size
	
	var img = Image.create(img_w, img_h, false, Image.FORMAT_RGB8)
	img.fill(Color(0.15, 0.15, 0.15))  # Slightly lighter background
	
	# Draw grid cells
	for y in range(gh):
		for x in range(gw):
			var v: int = grid[y][x]
			var col: Color
			if v == 1:
				col = Color.WHITE
			elif v == 0:
				col = Color(0.4, 0.4, 0.4)
			else:
				col = Color(0.2, 0.2, 0.2)  # Dark gray for unknown
			
			var bc: Color = Color(0.1, 0.1, 0.1)  # Border color
			var ox: int = ml + x * cell_size
			var oy: int = mt + y * cell_size
			
			# Draw 5x5 grid indicators for better readability
			if x % 5 == 0 and x > 0:
				for dy in range(cell_size):
					var py: int = oy + dy
					var px: int = ox
					if px >= 0 and px < img_w and py >= 0 and py < img_h:
						img.set_pixel(px-1, py, Color(0.05, 0.05, 0.05))
			
			if y % 5 == 0 and y > 0:
				for dx in range(cell_size):
					var px: int = ox + dx
					var py: int = oy
					if px >= 0 and px < img_w and py >= 0 and py < img_h:
						img.set_pixel(px, py-1, Color(0.05, 0.05, 0.05))
			
			# Draw cell
			for dy in range(cell_size):
				for dx in range(cell_size):
					var px: int = ox + dx
					var py: int = oy + dy
					if px >= 0 and px < img_w and py >= 0 and py < img_h:
						if dx == 0 or dx == cell_size - 1 or dy == 0 or dy == cell_size - 1:
							img.set_pixel(px, py, bc)
						else:
							img.set_pixel(px, py, col)
	
	# Create texture from image
	var tex = ImageTexture.create_from_image(img)
	puzzle_display.texture = tex
	
	# Draw clue labels
	_draw_clue_labels_with_margins(row_clues, col_clues, margins)

func _draw_clue_labels_with_margins(row_clues: Array, col_clues: Array, margins: Vector2) -> void:
	# Clear previous labels
	for child in clue_layer.get_children():
		if child is Label:  # Only remove labels, not error highlights
			child.queue_free()
	
	var ml: int = int(margins.x)
	var mt: int = int(margins.y)
	var gw: int = col_clues.size()
	var gh: int = row_clues.size()
	
	# Draw row clues
	for y in range(gh):
		var clues: Array = row_clues[y]
		for i in range(clues.size()):
			var lbl = Label.new()
			lbl.text = str(int(clues[clues.size() - 1 - i]))
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_color_override("font_color", Color.WHITE)
			lbl.size = Vector2(cell_size, cell_size)
			lbl.position = Vector2(ml - (i + 1) * cell_size, mt + y * cell_size)
			clue_layer.add_child(lbl)
	
	# Draw column clues
	for x in range(gw):
		var clues: Array = col_clues[x]
		for i in range(clues.size()):
			var lbl = Label.new()
			lbl.text = str(int(clues[clues.size() - 1 - i]))
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_color_override("font_color", Color.WHITE)
			lbl.size = Vector2(cell_size, cell_size)
			lbl.position = Vector2(ml + x * cell_size, mt - (i + 1) * cell_size)
			clue_layer.add_child(lbl)

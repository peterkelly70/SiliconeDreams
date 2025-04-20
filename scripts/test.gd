extends Node

@onready var generate_button: Button = $Menu/GenerateBTN
@onready var load_button: Button = $Menu/LoadBTN
@onready var solve_button: Button = $Menu/SolveBTN
@onready var play_button: Button = $Menu/PlayBTN
var check_button: Button = null

@onready var puzzle_display: TextureRect = $Puzzle
@onready var clue_layer: Control = $Puzzle/ClueLayer

var generator = preload("res://scripts/random_puzzle_generator.gd").new()
var last_loaded_path = ""
var player_grid: Array = []
var cell_size = 24

func _ready() -> void:
	generate_button.pressed.connect(_on_generate_pressed)
	load_button.pressed.connect(_on_load_pressed)
	solve_button.pressed.connect(_on_solve_pressed)
	play_button.pressed.connect(_on_play_pressed)
	if $Menu.has_node("CheckBTN"):
		check_button = $Menu/CheckBTN
		check_button.pressed.connect(_on_check_pressed)
	puzzle_display.gui_input.connect(_on_puzzle_clicked)
	clue_layer.show()

func _on_generate_pressed() -> void:
	print("Generating new puzzle...")
	var path = generator.generate_and_save_random_puzzle(15, 15)
	if path != "":
		_display_puzzle_from_file(path)

func _on_load_pressed() -> void:
	print("Load not yet implemented.")

func _on_solve_pressed() -> void:
	print("Showing solution grid...")
	if last_loaded_path == "":
		printerr("No puzzle loaded.")
		return
	var data = _load_puzzle_data(last_loaded_path)
	if data.is_empty():
		return
	_render_full_puzzle(data)

func _on_play_pressed() -> void:
	print("Entering play mode...")
	_load_player_grid_from_last_path()

func _on_check_pressed() -> void:
	print("Checking solution...")
	if last_loaded_path == "":
		printerr("No puzzle loaded.")
		return
	var data = _load_puzzle_data(last_loaded_path)
	if data.is_empty():
		return
	_highlight_errors(data)

func _on_puzzle_clicked(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb = event as InputEventMouseButton
	if not mb.pressed:
		return
	if player_grid.is_empty():
		print("No player grid initialized")
		return

	var data = _load_puzzle_data(last_loaded_path)
	if data.is_empty():
		return

	var row_clues = data.row_clues
	var col_clues = data.col_clues
	var margins = _compute_margins(row_clues, col_clues)
	var ml = int(margins.x)
	var mt = int(margins.y)

	var pos = mb.position
	var x = int((pos.x - ml) / cell_size)
	var y = int((pos.y - mt) / cell_size)
	if x < 0 or y < 0 or y >= player_grid.size() or x >= player_grid[0].size():
		print("Click outside grid")
		return

	var cur = player_grid[y][x]
	if mb.button_index == MOUSE_BUTTON_LEFT:
		if cur == -1:
			player_grid[y][x] = 1
		elif cur == 1:
			player_grid[y][x] = 0
		else:
			player_grid[y][x] = -1
	else:
		player_grid[y][x] = 0

	_render_play_puzzle(data)

	var flash = ColorRect.new()
	flash.color = Color(0.5, 0.5, 1.0, 0.3)
	flash.size = Vector2(cell_size, cell_size)
	flash.position = Vector2(ml + x * cell_size, mt + y * cell_size)
	clue_layer.add_child(flash)
	var tw = create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.25)
	tw.tween_callback(flash.queue_free)

func _load_player_grid_from_last_path() -> void:
	if last_loaded_path == "":
		printerr("No puzzle to play.")
		return
	var data = _load_puzzle_data(last_loaded_path)
	if data.is_empty():
		return
	var w = int(data.width)
	var h = int(data.height)
	player_grid.clear()
	for i in range(h):
		var row = []
		for j in range(w):
			row.append(-1)
		player_grid.append(row)
	_render_play_puzzle(data)

func _display_puzzle_from_file(path: String) -> void:
	print("Loading puzzle from:", path)
	var data = _load_puzzle_data(path)
	if data.is_empty():
		return
	last_loaded_path = path
	_render_full_puzzle(data)

func _load_puzzle_data(path: String) -> Dictionary:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		printerr("Could not open: ", path)
		return {}
	var raw: String = f.get_as_text()
	f.close()

	# Strip BOM if present
	if raw.begins_with("\uFEFF"):
		raw = raw.substr(1, raw.length() - 1)

	# Debug print first 128 chars so you know what’s being parsed
	printerr("Parsing JSON (prefix): ", raw.substr(0, min(raw.length(), 128)))

	var parse_result: Dictionary = JSON.parse_string(raw)
	var err: int      = int(parse_result.get("error", ERR_FILE_CORRUPT))
	var err_line: int = int(parse_result.get("error_line", -1))
	var err_msg: String = parse_result.get("error_string", "unknown") as String

	if err != OK:
		printerr("JSON parse failed at line ", err_line, ": ", err_msg)
		return {}

	var data: Dictionary = parse_result.get("result", {}) as Dictionary
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Expected top‑level Dictionary but got type ", typeof(data))
		return {}

	return data


func _compute_margins(row_clues: Array, col_clues: Array) -> Vector2:
	var max_r = 0
	for rc in row_clues:
		max_r = max(max_r, rc.size())
	var max_c = 0
	for cc in col_clues:
		max_c = max(max_c, cc.size())
	return Vector2(max_r * cell_size, max_c * cell_size)

func _render_full_puzzle(data: Dictionary) -> void:
	var grid = data.grid
	if grid.is_empty() or typeof(grid[0]) != TYPE_ARRAY:
		printerr("No valid grid")
		return
	_draw_puzzle_with_margins(grid, data.row_clues, data.col_clues)
	_center_puzzle_in_view()

func _render_play_puzzle(data: Dictionary) -> void:
	if player_grid.is_empty():
		return
	_draw_puzzle_with_margins(player_grid, data.row_clues, data.col_clues)
	_center_puzzle_in_view()
	for c in clue_layer.get_children():
		if c is Label and c.text == "PLAY MODE":
			c.queue_free()
	var play_label = Label.new()
	play_label.text = "PLAY MODE"
	play_label.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	play_label.position = Vector2(10, 10)
	clue_layer.add_child(play_label)

func _center_puzzle_in_view() -> void:
	var parent = puzzle_display.get_parent()
	if parent == null:
		return
	var parent_size = parent.rect_size
	var puzzle_size = puzzle_display.rect_size
	var centered_x = max(0, (parent_size.x - puzzle_size.x) / 2)
	var centered_y = max(0, (parent_size.y - puzzle_size.y) / 2)
	puzzle_display.position = Vector2(centered_x, centered_y)

func _highlight_errors(data: Dictionary) -> void:
	for c in clue_layer.get_children():
		if c is ColorRect:
			c.queue_free()
	var sol = data.grid
	var errors = 0
	var margins = _compute_margins(data.row_clues, data.col_clues)
	for y in range(min(player_grid.size(), sol.size())):
		for x in range(min(player_grid[y].size(), sol[y].size())):
			if player_grid[y][x] != -1 and sol[y][x] != player_grid[y][x]:
				var mark = ColorRect.new()
				mark.color = Color(1, 0, 0, 0.7)
				mark.size = Vector2(cell_size - 2, cell_size - 2)
				mark.position = Vector2(margins.x + x * cell_size + 1, margins.y + y * cell_size + 1)
				clue_layer.add_child(mark)
				errors += 1
	var fb = Label.new()
	fb.text = str(errors) + " errors" if errors > 0 else "Perfect!"
	fb.add_theme_color_override("font_color", Color(1, 0.3, 0.3) if errors > 0 else Color(0.3, 1, 0.3))
	fb.position = Vector2(10, 10)
	clue_layer.add_child(fb)
	get_tree().create_timer(3.0).timeout.connect(func(): fb.queue_free())

func _draw_puzzle_with_margins(grid: Array, row_clues: Array, col_clues: Array) -> void:
	var margins = _compute_margins(row_clues, col_clues)
	var ml = int(margins.x)
	var mt = int(margins.y)
	var gw = grid[0].size()
	var gh = grid.size()
	var img_w = ml + gw * cell_size
	var img_h = mt + gh * cell_size
	var img = Image.create(img_w, img_h, false, Image.FORMAT_RGB8)
	img.fill(Color(1, 1, 1))

	for y in range(gh):
		for x in range(gw):
			var v = grid[y][x]
			var col = Color(0, 0, 0) if v == 1 else Color(0.8, 0.8, 0.8) if v == 0 else Color(0.95, 0.95, 0.95)
			var ox = ml + x * cell_size
			var oy = mt + y * cell_size
			for dy in range(1, cell_size - 1):
				for dx in range(1, cell_size - 1):
					img.set_pixel(ox + dx, oy + dy, col)

	for x in range(gw + 1):
		var lx = ml + x * cell_size
		var w = 2 if x % 5 == 0 else 1
		for y in range(mt, mt + gh * cell_size + 1):
			for i in range(w):
				img.set_pixel(lx - i, y, Color(0.3, 0.3, 0.3))

	for y in range(gh + 1):
		var ly = mt + y * cell_size
		var w = 2 if y % 5 == 0 else 1
		for x in range(ml, ml + gw * cell_size + 1):
			for i in range(w):
				img.set_pixel(x, ly - i, Color(0.3, 0.3, 0.3))

	puzzle_display.texture = ImageTexture.create_from_image(img)
	puzzle_display.rect_size = Vector2(img_w, img_h)
	_draw_clue_labels_with_margins(row_clues, col_clues, margins)

func _draw_clue_labels_with_margins(row_clues: Array, col_clues: Array, margins: Vector2) -> void:
	for c in clue_layer.get_children():
		if c is Label and c.text != "PLAY MODE":
			c.queue_free()
	var ml = int(margins.x)
	var mt = int(margins.y)

	for y in range(row_clues.size()):
		var clues = row_clues[y]
		for i in range(clues.size()):
			var lbl = Label.new()
			lbl.text = str(int(clues[clues.size() - 1 - i]))
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.rect_size = Vector2(cell_size, cell_size)
			lbl.position = Vector2(ml - (i + 1) * cell_size, mt + y * cell_size)
			clue_layer.add_child(lbl)

	for x in range(col_clues.size()):
		var clues = col_clues[x]
		for i in range(clues.size()):
			var lbl = Label.new()
			lbl.text = str(int(clues[clues.size() - 1 - i]))
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.rect_size = Vector2(cell_size, cell_size)
			lbl.position = Vector2(ml + x * cell_size, mt - (i + 1) * cell_size)
			clue_layer.add_child(lbl)

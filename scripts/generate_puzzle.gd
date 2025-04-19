# puzzle_processor.gd
# Godot 4.4 script for processing a Picross puzzle image into binary grid data,
# computing numerical clues for each row and column, and saving the resulting data as a JSON file.
#
# The script loads the image from "res://assets/puzzles/puzzle0001.png" as a Texture2D resource,
# extracts its Image data using get_image(), and writes the JSON data to "user://puzzles/puzzle0001.json".
#
# Attach this script to a Node in a test scene (or use it as an autoload) to process your puzzle image.

extends Node

func _ready() -> void:
	process_puzzle("res://assets/puzzles/puzzle0001.png", "user://puzzles/puzzle0001.json")

func process_puzzle(image_path: String, json_path: String) -> void:
	# Load the image as a Texture2D resource.
	var texture: Texture2D = ResourceLoader.load(image_path) as Texture2D
	if texture == null:
		print("Failed to load texture resource from: ", image_path)
		return

	# Extract the image data using get_image() (works for CompressedTexture2D as well).
	var img: Image = texture.get_image()
	if img == null:
		print("Failed to obtain image data from texture.")
		return

	# Lock the image for pixel access.
	img.lock()
	var w: int = img.get_width()
	var h: int = img.get_height()
	print("Loaded image size: ", w, " x ", h)
	
	var grid := []
	# Process every pixel to create a binary grid.
	for y in range(h):
		var row := []
		for x in range(w):
			var color: Color = img.get_pixel(x, y)
			# Compute brightness using a standard luminance formula.
			var brightness: float = (color.r * 0.299) + (color.g * 0.587) + (color.b * 0.114)
			if brightness < 0.5:
				row.append(1)  # filled cell
			else:
				row.append(0)  # empty cell
		grid.append(row)
	img.unlock()
	
	# Compute numerical clues for each row.
	var row_clues := []
	for row in grid:
		row_clues.append(compute_clues(row))
	
	# Compute numerical clues for each column.
	var col_clues := []
	for x in range(w):
		var col := []
		for y in range(h):
			col.append(grid[y][x])
		col_clues.append(compute_clues(col))
	
	# Assemble the puzzle data dictionary.
	var puzzle_data := {
		"width": w,
		"height": h,
		"grid": grid,
		"row_clues": row_clues,
		"col_clues": col_clues
	}
	
	# Convert the dictionary to a JSON string.
	var json_string: String = JSON.stringify(puzzle_data)
	
	# Ensure the destination directory "user://puzzles" exists.
	var puzzles_dir: String = "user://puzzles"
	var user_dir: DirAccess = DirAccess.open("user://")
	if user_dir:
		if not user_dir.dir_exists("puzzles"):
			var make_err: int = user_dir.make_dir_recursive("puzzles")
			print("Attempted to create 'puzzles' folder recursively. Error code: ", make_err)
		else:
			print("'puzzles' folder already exists.")
	else:
		print("Failed to open user:// directory.")
	
	# Open the JSON file for writing.
	var file: FileAccess = FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Puzzle data saved to: ", json_path)
	else:
		print("Failed to open file for JSON saving.")
	
	# For debugging, print the puzzle grid and clues.
	print("Puzzle grid data: ", grid)
	print("Row clues: ", row_clues)
	print("Column clues: ", col_clues)

# Computes numerical clues for a line (array of 0s and 1s) by counting consecutive 1s.
# Returns an array of integers; if no filled cells are found, returns [0].
func compute_clues(line: Array) -> Array:
	var clues := []
	var count: int = 0
	for cell in line:
		if cell == 1:
			count += 1
		else:
			if count > 0:
				clues.append(count)
				count = 0
	if count > 0:
		clues.append(count)
	if clues.size() == 0:
		clues.append(0)
	return clues

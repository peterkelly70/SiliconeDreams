# PlayController.gd
extends Control
class_name PlayController

var renderer  # will hold a reference to PuzzleController

func start_play(rend) -> void:
	renderer = rend
	set_process_unhandled_input(true)

func reset_selections() -> void:
	if not renderer:
		return
	for i in range(renderer.user_selection.size()):
		renderer.user_selection[i] = false
		renderer.cells[i].selected = false
		renderer.cells[i].queue_redraw()

func _unhandled_input(ev):
	if not renderer:
		return
	if ev is InputEventMouseMotion:
		_highlight(ev.position)
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		_toggle(ev.position)

func _highlight(pos: Vector2) -> void:
	for cell in renderer.cells:
		cell.selected = false
	for i in range(renderer.cells.size()):
		var cell = renderer.cells[i]
		if cell.get_global_rect().has_point(pos):
			cell.selected = true
			cell.queue_redraw()
			break

func _toggle(pos: Vector2) -> void:
	for i in range(renderer.cells.size()):
		var cell = renderer.cells[i]
		if cell.get_global_rect().has_point(pos):
			var new_state = not renderer.user_selection[i]
			renderer.user_selection[i] = new_state
			cell.selected = new_state
			cell.queue_redraw()
			break

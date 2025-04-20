extends Control

var filled:     bool = false
var selected:   bool = false
var error_state: bool = false

func set_filled(v: bool) -> void:
	filled = v
	queue_redraw()

func clear_error() -> void:
	error_state = false
	queue_redraw()

func show_error() -> void:
	error_state = true
	queue_redraw()


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			selected = not selected
			queue_redraw()


func _draw():
	# filled background
	if filled:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.2, 0.2), true)
	# selection border
	if selected:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1), false, 2)
	# error outline and cross
	if error_state:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0, 0), false, 2)
		draw_line(Vector2.ZERO, size, Color(1, 0, 0), 2)
		draw_line(Vector2(0, size.y), Vector2(size.x, 0), Color(1, 0, 0), 2)

extends TextureRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Fill the viewport while maintaining aspect ratio — crop if needed
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	# Optional: smooth scaling
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

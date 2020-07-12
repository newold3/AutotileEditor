extends Control


onready var selection 		= $Selection
onready var texture_rect 	= $TextureRect
onready var label 			= $Label

var full_path 				= ""
var selected 				= false
var is_dir					= false
var data
var directory_mode = false
var id = 0

signal selected(value, id)
signal change_directory(value, id)
signal dblClick(value, id)

func _ready() -> void:
	if data != null:
		texture_rect.texture 	= data[0]
		label.text 				= data[1].filename
		label.hide()
		label.show()
		full_path 				= data[1].full_path
		is_dir					= data[1].is_directory
		data = null
		center_label()
		resize()
		
	connect_signals()
	
func connect_signals():
	if !is_connected("gui_input", self, "_on_CustomFile_gui_input"):
		connect("gui_input", self, "_on_CustomFile_gui_input")

func center_label():
	label.rect_position.x = texture_rect.rect_size.x * 0.5 - label.rect_size.x * 0.5 + 4

func resize():
	var rect = label.get_rect()
	var min_x = min(label.rect_position.x, 0)
	var max_x = min(label.rect_position.x + label.rect_size.x + 4, texture_rect.rect_size.x)
	var min_y = 0
	var max_y = texture_rect.rect_size.y + label.rect_size.y + 6
	rect_min_size = Vector2(max_x - min_x + 10, max_y - min_y + 10)
	selection.rect_min_size = rect_min_size
	selection.rect_position.x += 5
	texture_rect.rect_position.x += 5
	label.rect_position.x += 5
	
func set_data(_texture, _data):
	data = [_texture, _data]
	

func _on_CustomFile_mouse_entered() -> void:
	selection.visible = true

func _on_CustomFile_mouse_exited() -> void:
	selection.visible = selected
	
func set_selected(value):
	selected = value
	selection.visible = selected


func _on_CustomFile_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.doubleclick:
			if !is_dir:
				set_selected(true)
				emit_signal("dblClick", full_path, id)
			elif directory_mode:
				emit_signal("change_directory", full_path, id)
		elif event.is_pressed():
			set_selected(!selected)
			if is_dir:
				if !directory_mode:
					emit_signal("change_directory", full_path, id)
				else:
					emit_signal("selected", full_path, id)
			else:
				emit_signal("selected", full_path, id)

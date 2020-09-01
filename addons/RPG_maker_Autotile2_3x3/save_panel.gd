extends Panel


onready var title_label				= $title_label
onready var columns_spinBox			= $columns_SpinBox
onready var tilemap_name_lineEdit	= $tilemap_name_LineEdit
onready var tileset_name_lineEdit	= $tileset_name_LineEdit
onready var info_button				= $info_button
onready var single_imagen_button	= $single_image_button
onready var compression_spinBox		= $compression_SpinBox

var id = 0

var data = {
	"tile_width"		: 0,
	"tile_height"		: 0,
	"autotile_path"		: "",
	"tileset_path"		: "",
	"tilemap_path"		: "",
	"tiles"				: []
}

signal deleted(id)
signal show_ultimate_revision_dialog_request(tiles)

func set_initial_values(_title := "", _tilemap_name := "", _tileset_name := "",
	_columns := 16, _data = null):
	if _data != null:
		data = _data
	title_label.text = _title
	tilemap_name_lineEdit.text = _tilemap_name
	tileset_name_lineEdit.text = _tileset_name
	columns_spinBox.value = _columns
	_on_columns_SpinBox_value_changed(_columns)
	update_help()
		
func set_tilemap_path(_tilemap_path):
	data.tilemap_path = _tilemap_path
	update_help()
	
func get_values():
	columns_spinBox.apply()
	compression_spinBox.apply()
	return {
		"tilemap_name"		: tilemap_name_lineEdit.text,
		"tileset_name"		: tileset_name_lineEdit.text,
		"columns"			: columns_spinBox.value,
		"single_image"		: single_imagen_button.pressed,
		"data"				: data,
		"tile_width"		: data.tile_width,
		"tile_height"		: data.tile_height,
		"compression"		: compression_spinBox.value
	}


func _on_delete_button_button_up() -> void:
	emit_signal("deleted", id)
	
func select():
	tilemap_name_lineEdit.caret_position = tilemap_name_lineEdit.text.length()
	tilemap_name_lineEdit.select_all()
	tilemap_name_lineEdit.grab_focus()


func _on_columns_SpinBox_value_changed(value: float) -> void:
	var text = """If the [color=#FF0000]button to save the images in a single image[/color] is activated,
all the tiles will be drawn in a same image in
[color=#FF0000]%s[/color] columns by [color=#FF0000]%s[/color] pixels wide each""" % [
		value, data.tile_width
	]
	columns_spinBox.hint_tooltip = text
	update_help()


func _on_tilemap_name_lineEdit_text_changed(new_text: String) -> void:
	var caret_position = tilemap_name_lineEdit.caret_position
	var illegal = ["<",">",":","\"","/","\\","|","?","*"]
	for _char in illegal:
		if new_text.find(_char) != -1:
			new_text = new_text.replace(_char, "")
			caret_position -= 1
	tilemap_name_lineEdit.text = new_text
	tilemap_name_lineEdit.caret_position = caret_position
	update_help()
	
func _on_tileset_name_lineEdit_text_changed(new_text: String) -> void:
	var caret_position = tileset_name_lineEdit.caret_position
	var illegal = ["<",">",":","\"","/","\\","|","?","*"]
	for _char in illegal:
		if new_text.find(_char) != -1:
			new_text = new_text.replace(_char, "")
			caret_position -= 1
	tileset_name_lineEdit.text = new_text
	tileset_name_lineEdit.caret_position = caret_position
	update_help()
	
func update_help():
	var text = ""
	text += "- Save tilemap in:\n[color=#FF0000]  %s%s.tscn[/color]\n\n" % [
		data.tilemap_path, tilemap_name_lineEdit.text
	]
	text += "- Save tileset in:\n[color=#FF0000]  %s%s.res[/color]\n\n" % [
		data.tilemap_path, tileset_name_lineEdit.text
	]
	text += "- Save tiles in:\n[color=#FF0000]  %s%s/*.png[/color]\n" % [
		data.autotile_path, tilemap_name_lineEdit.text
	]
	info_button.hint_tooltip = text


func _on_single_image_button_toggled(button_pressed: bool) -> void:
	columns_spinBox.editable = button_pressed





func _on_check_collisions_and_occlusions_Button_button_down() -> void:
	emit_signal("show_ultimate_revision_dialog_request", data.tiles)

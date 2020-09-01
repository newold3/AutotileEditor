extends Control

onready var tileset						= $SelectedImage/TilesetContainer/Tileset
onready var tileset_container			= $SelectedImage/TilesetContainer/Tileset/Container
onready var image_real					= $SelectedImage/TilesetContainer/Tileset/Container/Image
onready var horizontal_bar				= $SelectedImage/TilesetContainer/HorizontalBar
onready var vertical_bar				= $SelectedImage/TilesetContainer/VerticalBar
onready var cursor_mouse_over			= $SelectedImage/TilesetContainer/Tileset/Container/Image/CursorMouseOver
onready var cursor_selected				= $SelectedImage/TilesetContainer/Tileset/Container/Image/CursorSelected
onready var cursor_drag					= $SelectedImage/TilesetContainer/Tileset/Container/Image/CursorDrag
onready var hide_behind					= $hide_behind_controls
onready var file_dialog					= $CustomFileDialog
onready var image_list					= $ImageList/list
onready var autotile_list				= $AutoTileList/list
onready var autotiles_lineEdit			= $Panel3/autotiles_folder
onready var tileset_lineEdit			= $Panel3/tileset_folder
onready var preview_selection			= $Panel/preview_selection_selected
onready var create_tile_button			= $Panel/Button
onready var preview_autotile			= $Panel2/preview_autotile_selected
onready var preview_autotile_config		= $AutoTileConfig/preview_texture
onready var preset_button				= $AutoTileConfig/OptionButton
onready var config_rows_button			= $AutoTileConfig/rows/SpinBox
onready var config_columns_button		= $AutoTileConfig/columns/SpinBox
onready var config_tile_width_button	= $AutoTileConfig/tile_width/SpinBox
onready var config_tile_height_button	= $AutoTileConfig/tile_height/SpinBox
onready var config_layout_button		= $AutoTileConfig/tile_layout/OptionButton
onready var config_layout2_button		= $AutoTileConfig/tile_layout/OptionButton2
onready var config_layout_label			= $AutoTileConfig/tile_layout
onready var create_autotile_dialog		= $create_autotile_dialog
onready var create_autotile_dialog_t	= $create_autotile_dialog/LineEdit
onready var create_autotile_dialog_c	= $create_autotile_dialog/OptionButton
onready var create_autotile_dialog_o	= $create_autotile_dialog/CheckButton
onready var create_autotile_dialog_s	= $create_autotile_dialog/SpinBox
onready var edit_autotile_button		= $AutoTileList/edit_autotile_button
onready var move_autotiles_up_button	= $AutoTileList/move_autotile_up_button
onready var move_autotiles_down_button	= $AutoTileList/move_autotile_down_button
onready var merge_autotiles_button		= $AutoTileList/create_merged_autotile_button
onready var create_a_animation_button	= $AutoTileList/create_animated_autotile_button
onready var remove_autotile_button		= $AutoTileList/Button
onready var error1_dialog				= $error1_dialog
onready var error2_dialog				= $error2_dialog
onready var error2_dialog_label			= $error2_dialog/Label
onready var save_dialog					= $SaveDialog
onready var save_dialog_container		= $SaveDialog/BackgroundContainer/Container
onready var save_dialog_container_vbox	= $SaveDialog/BackgroundContainer/Container/VBox
onready var save_dialog_tilemap_path	= $SaveDialog/LineEdit
onready var save_all_button				= $Panel3/save_all_Button
onready var edit_autotile_dialog		= $edit_autotile_dialog
onready var name_autotile_dialog_b		= $edit_autotile_dialog/LineEdit
onready var collision_autotile_dialog_b	= $edit_autotile_dialog/OptionButton
onready var occlusion_autotile_dialog_b	= $edit_autotile_dialog/CheckButton
onready var speed_autotile_dialog_b		= $edit_autotile_dialog/SpinBox
onready var percent_autotile_dialog_b	= $edit_autotile_dialog/SpinBox2
onready var fast_export_button			= $Panel/fast_export_button
onready var saving_animation			= $saving_all_animation
onready var timer						= $Timer

onready var ultimate_dialog_layer		= $ultimate_revision_dialog
onready var ultimate_dialog				= $ultimate_revision_dialog/WindowDialog
onready var ultimate_dialog_itemlist	= $ultimate_revision_dialog/WindowDialog/HBoxContainer/VBoxContainer/ItemList
onready var ultimate_dialog_preview_t	= $ultimate_revision_dialog/WindowDialog/HBoxContainer/Panel/Panel4/preview_autotile_selected
onready var ultimate_dialog_collision	= $ultimate_revision_dialog/WindowDialog/HBoxContainer/Panel/Panel/OptionButton2
onready var ultimate_dialog_percent		= $ultimate_revision_dialog/WindowDialog/HBoxContainer/Panel/Panel/SpinBox3
onready var ultimate_dialog_occlusion	= $ultimate_revision_dialog/WindowDialog/HBoxContainer/Panel/Panel/CheckButton2

var save_panel_scene = preload("save_panel.tscn")

var data_tileset = {
	"layout"			: 0,
	"type"				: 0,
	"tile_width"		: 32,
	"tile_height"		: 32,
	"rows"				: 4,
	"columns"			: 3,
	"selection_width"	: 0,
	"selection_height"	: 0,
	"current_selection"	: Vector2(-1, -1),
	"current_selected"	: Vector2(-1, -1),
	"tiles"				: []
}

var ultimate_tiles = []
var ultimate_last_tile = null
var no_action = false

class Autotile:
	var name 				:= ""
	var path 				:= ""
	var rect				:= Rect2(0, 0, 0, 0)
	var type				:= 0
	var tile_width			:= 0
	var tile_height			:= 0
	var mixed				:= []
	var animation			:= []
	var frame				:= 0
	var animation_delay		:= 0.18
	var collision_type		:= 0
	var occlusion			:= false
	var collision_percent	:= 100
	
	func duplicate() -> Autotile:
		var autotile = Autotile.new()
		autotile.name 				= name
		autotile.path 				= path
		autotile.rect 				= rect
		autotile.type 				= type
		autotile.animation_delay	= animation_delay
		autotile.tile_width 		= tile_width
		autotile.tile_height 		= tile_height
		autotile.collision_type		= collision_type
		autotile.occlusion			= occlusion
		autotile.collision_percent	= collision_percent
		return autotile
		
	func get_id() -> String:
		var id = path + str(rect)
		for tile in mixed: 			id += tile.get_id()
		return id.sha1_text()
	
var data_images = []

var selection = Rect2(
	Vector2.ZERO,
	Vector2.ZERO
)

var preview_config_images = [
	preload("Graphics/preview_config_xp.png"),
	preload("Graphics/preview_config_other_floor.png"),
	preload("Graphics/preview_config_other_wall.png"),
	preload("Graphics/preview_config_other_waterfall.png"),
	preload("Graphics/preview_config_single_tile.png")
]
			
var drag = false
var folder_mode
var can_action = true
var current_animation = null

var customToolTip = preload("CustomToolTip.tscn")
var tooltip

var final_zoom = Vector2.ONE 	# - Suavize canvas zoom
var zoom_timer = 10				# -

var save_files = {}
var thread

signal save_completed()

func _ready() -> void:
	rect_size = Vector2(1024, 768)
	var screen_size = OS.get_screen_size()
	var window_size = rect_size
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_IGNORE, window_size)
	OS.set_window_size(window_size)
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	OS.set_window_always_on_top(true)
	
	load_initial_config()
	
	var path = get_tree().current_scene.filename.get_base_dir()
	for id in ["tilemap", "tileset", "tileset_header", "single_tile",
		"floor", "wall", "waterfall", "single_shape"]:
		save_files[id] = load_file_text("%s/Data/%s.dat" % [path, id])
	
	update_style_for_input_and_text_boxes(self)
	create_input_maps()
	set_tiles()
	set_max_scroll_in_scroll_bars()
	change_autotile_preset(0)
	set_cursor_sizes()
	horizontal_bar.connect("scroll", self, "set_offset_x")
	vertical_bar.connect("scroll", self, "set_offset_y")
	fill_image_list()
	
	tooltip = customToolTip.instance()
	$HINTS.add_child(tooltip)
	tooltip.visible = false
	
	fast_export_button.text = "Fast Export"
	
	speed_autotile_dialog_b.get_line_edit().connect("focus_exited", self,
		"select_speed_autotile_dialog_b")
	connect("save_completed", self, "hide_all_dialogs")
	
func load_initial_config():
	var file = File.new()
	var path = "user://create_autotile_config.dat"
	var config
	if !file.file_exists(path):
		config = {}
		config.preset = preset_button.get_selected_id()
		config.autotiles_path = autotiles_lineEdit.text
		config.tilesets_paths = tileset_lineEdit.text
		config.tilemaps_path = save_dialog_tilemap_path.text
	else:
		file.open(path, file.READ)
		config = parse_json(file.get_as_text())
		file.close()
	preset_button.select(config.preset)
	preset_button.emit_signal("item_selected", config.preset)
	autotiles_lineEdit.text = config.autotiles_path
	tileset_lineEdit.text = config.tilesets_paths
	save_dialog_tilemap_path.text = config.tilemaps_path
		
	
func select_speed_autotile_dialog_b():
	if name_autotile_dialog_b.visible:
		yield(get_tree(), "idle_frame")
		name_autotile_dialog_b.grab_focus()
	
func load_file_text(path : String) -> String:
	var file = File.new()
	file.open(path, file.READ)
	var content = file.get_as_text()
	file.close()
	return content


func update_style_for_input_and_text_boxes(obj):
	var children = obj.get_children()
	for child in children:
		var line_edit = null
		if child.has_method("_get_tooltip"):
			if child.hint_tooltip.length() > 0:
				if !child.is_connected("mouse_entered", self, "show_tooltip"):
					var text = child.hint_tooltip
					if child.has_method("is_shortcut_in_tooltip_enabled"):
						if child.is_shortcut_in_tooltip_enabled():
							child.set_shortcut_in_tooltip(false)
							var shortcut = child.shortcut
							if shortcut != null:
								shortcut = shortcut.shortcut
							if shortcut is InputEventKey:
								var s = OS.get_scancode_string(shortcut.scancode)
								
								if shortcut.shift:
									s = "Shift + " + s
								if shortcut.alt:
									s = "Alt + " + s
								if shortcut.control:
									s = "CTRL + " + s
								if s.length() > 0:
									s = "[color=#FF0000](%s)[/color] " % s
									text = s + text
					if child.has_signal("button_up"):
						child.connect("button_up", self, "hide_tooltip",
							[child, true])
						child.connect("button_down", self, "hide_tooltip",
							[child, true])
					child.connect("mouse_entered", self, "show_tooltip",
						[child])
					child.connect("mouse_exited", self, "hide_tooltip",
						[child])
					child.connect("gui_input", self, "update_tooltip_position",
						[child])
					child.editor_description = child.hint_tooltip
					child.hint_tooltip = ""
		if child.get_child_count() != 0:
			update_style_for_input_and_text_boxes(child)
		if child is LineEdit:
			line_edit = child
		elif child is SpinBox:
			line_edit = child.get_line_edit()
		if line_edit != null:
			line_edit.caret_blink = true
			line_edit.set("custom_colors/cursor_color", Color("12a108"))
			line_edit.set("custom_colors/font_color_selected", Color("ff9292"))
			if !line_edit.is_connected("focus_entered", self, "select_all_text"):
				line_edit.connect("focus_entered", self, "select_all_text", [line_edit])
				line_edit.connect("focus_exited", self, "deselect_text", [line_edit])
				if child is SpinBox:
					line_edit.connect("focus_exited", self, "validate_spinbox", [child])
				
				
func select_all_text(line_edit):
	line_edit.caret_position = line_edit.text.length()
	line_edit.select_all()
	
func deselect_text(line_edit):
	line_edit.deselect()
	
func validate_spinbox(spinbox):
	spinbox.apply()
	
func fill_image_list():
	var selectedIndex = image_list.get_selected_items()
	image_list.clear()
	for _img in data_images:
		image_list.add_item(_img.name)
	
func set_cursor_sizes():
	cursor_mouse_over.rect_size = selection.size
	cursor_selected.rect_size = selection.size
	cursor_drag.rect_size = selection.size
	
func set_tiles():
	var d = data_tileset
	var tex = image_real.texture
	if !tex: return
	d.selection_width	= d.tile_width * d.columns
	d.selection_height	= d.tile_height * d.rows
	d.vertical_tiles 	= max(1, floor(tex.get_width() / d.selection_width))
	d.horizontal_tiles 	= max(1, floor(tex.get_height() / d.selection_height))
	data_tileset = d
	selection.size = Vector2(d.selection_width, d.selection_height)

func set_max_scroll_in_scroll_bars():
	var tex = image_real.texture
	if !tex:
		horizontal_bar.set_target(Vector2.ZERO)
		vertical_bar.set_target(Vector2.ZERO)
		return
	var sc = image_real.rect_scale
	var s = tex.get_size() * sc #- tileset_container.rect_size
	horizontal_bar.set_target(s)
	vertical_bar.set_target(s)
#	if s.x > 0:
#		horizontal_bar.set_target_max_scroll(s)
#	else:
#		horizontal_bar.set_target_max_scroll(Vector2.ZERO)
#		pass
#	if s.y > 0:
#		vertical_bar.set_target_max_scroll(s)
#	else:
#		vertical_bar.set_target_max_scroll(Vector2.ZERO)
#		pass
	
func create_input_maps():
	var action_name = "ZOOM-IN"
	if !InputMap.has_action(action_name):
		vertical_bar.create_input(action_name,
			[BUTTON_WHEEL_UP], false, false, false)
	action_name = "ZOOM-OUT"
	if !InputMap.has_action(action_name):
		vertical_bar.create_input(action_name,
			[BUTTON_WHEEL_DOWN], false, false, false)
	action_name = "CTRL"
	if !InputMap.has_action(action_name):
		vertical_bar.create_input(action_name,
			[KEY_CONTROL], false, false, false)
	
func set_offset_x(offset):
	image_real.rect_position.x = -offset
	
func set_offset_y(offset):
	image_real.rect_position.y = -offset
	
func set_cursor_position(cursor, pos = null):
	var d = data_tileset
	if pos == null:
		pos = d.current_selected
	pos *= Vector2(d.tile_width, d.tile_height)
	cursor.rect_position = pos


func _on_Tileset_gui_input(event: InputEvent) -> void:
	if !image_real.texture: return
	if event is InputEventMouseButton and event.button_index == 1:
		if event.doubleclick:
			_on_create_autotile_Button_button_up()
			return
		if drag and !event.is_pressed():
			data_tileset.current_selected = data_tileset.current_selection
			set_cursor_position(cursor_selected)
			update_preview_selected()
		drag = event.is_pressed()
		if drag:
			var sc = image_real.rect_scale
			var pos = (event.position - image_real.rect_position) / sc
			set_selection_position(pos)
			set_cursor_position(cursor_selected, data_tileset.current_selection)
			cursor_selected.visible = true
			update_preview_selected(data_tileset.current_selection)
	elif event is InputEventMouseMotion:
		var sc = image_real.rect_scale
		var pos = (event.position - image_real.rect_position) / sc
		set_selection_position(pos)
		cursor_drag.visible = drag
		cursor_mouse_over.visible = !drag
		if drag:
			set_cursor_position(cursor_drag, data_tileset.current_selection)
			update_preview_selected(data_tileset.current_selection)
		else:
			set_cursor_position(cursor_mouse_over, data_tileset.current_selection)
	elif Input.is_action_pressed("CTRL"):
		if event.is_action_pressed("ZOOM-IN"):
			final_zoom = image_real.rect_scale + Vector2(0.25, 0.25)
			#change_zoom(0.25)
		elif event.is_action_pressed("ZOOM-OUT"):
			final_zoom = image_real.rect_scale - Vector2(0.25, 0.25)
			#change_zoom(-0.25)
	elif event.is_action_pressed("MouseWheelUp"):
		if horizontal_bar.can_move():
			horizontal_bar.move_top_by(-5)
		else:
			vertical_bar.move_top_by(-5)
	elif event.is_action_pressed("MouseWheelDown"):
		if horizontal_bar.can_move():
			horizontal_bar.move_top_by(5)
		else:
			vertical_bar.move_top_by(5)
			
func update_preview_selected(selection = null):
	if !selection:
		selection = data_tileset.current_selected
	if !image_real.texture: return
	var tex = image_real.texture.get_data()
	var w = data_tileset.selection_width
	var h = data_tileset.selection_height
	var x = selection.x * data_tileset.tile_width
	var y = selection.y * data_tileset.tile_height
	var src_rect = Rect2(Vector2(x, y), Vector2(w, h))
	var img = Image.new()
	img.create(w, h, false, Image.FORMAT_RGBA8)
	img.blit_rect(tex, src_rect, Vector2.ZERO)
	tex = ImageTexture.new()
	tex.create_from_image(img)
	preview_selection.texture = tex
	
		
func change_zoom(value):
	var ir = image_real.texture.get_size()
	var irs = image_real.rect_scale
	var tcrp = tileset_container.get_global_rect()
	
#	# Variation zoom #1
#	var zoom = Vector2()
#	if ir.x * (image_real.rect_scale.x + value) > tcrp.size.x:
#		zoom.x = max(0.05, min(image_real.rect_scale.x + value, 10))
#	else:
#		if ir.x < tcrp.size.x:
#			zoom.x = image_real.rect_scale.x
#		else:
#			zoom.x = tcrp.size.x / ir.x
#	if ir.y * (image_real.rect_scale.y + value) > tcrp.size.y:
#		zoom.y = max(0.05, min(image_real.rect_scale.y + value, 10))
#	else:
#		if ir.y < tcrp.size.y:
#			zoom.y = image_real.rect_scale.y
#		else:
#			zoom.y = tcrp.size.y / ir.y
#	# ------------------------------------------------------------------
	# Variation zoom #2
	var zoom;
	if value is Vector2:
		var z1 = max(0.1, min(irs.x + value.x, 10))
		var z2 = max(0.1, min(irs.y + value.y, 10))
		zoom = Vector2(z1, z2)
	else:
		var z = max(0.1, min(irs.x + value, 10))
		zoom = Vector2(z, z)
	# ------------------------------------------------------------------
	var scalechange = zoom - irs
	var offset = image_real.get_local_mouse_position()
	image_real.rect_scale = zoom
	set_max_scroll_in_scroll_bars()
	offset = image_real.get_local_mouse_position() - offset
	var dest = image_real.rect_position + offset * zoom
	var s = ir * zoom
	if dest.x > 0:
		dest.x = 0
	elif dest.x + s.x < tileset_container.rect_size.x + tcrp.position.x:
		dest.x = tileset_container.rect_size.x + tcrp.position.x - s.x
	if dest.y > 0:
		dest.y = 0
	elif dest.y + s.y < tileset_container.rect_size.y + tcrp.position.y:
		dest.y = tileset_container.rect_size.y + tcrp.position.y - s.y
	var displacement = -(dest + tileset_container.rect_position)
	horizontal_bar.set_displacement(displacement)
	vertical_bar.set_displacement(displacement)
		
func set_selection_position(position):
	var cs = position
	var d = data_tileset
	cs.x = floor(cs.x / d.tile_width)
	cs.y = floor(cs.y / d.tile_height)
	var offset = Vector2(10, 10)
	var s = Vector2(d.columns, d.rows) * Vector2(d.tile_width, d.tile_height)
	selection.position = cs * Vector2(d.tile_width, d.tile_height)
	data_tileset.current_selection = cs
	
func get_selected_rect(position) -> Vector2:
	if !data_tileset.has("vertical_tiles"): return Vector2(-1, -1)
	var cs = data_tileset.current_selection
	var ip = image_real.rect_position
	cs.x = floor(position.x / data_tileset.selection_width) 
	cs.y = floor(position.y / data_tileset.selection_height)
	if (cs.x < ip.x or
		cs.y < ip.y or
		cs.x + ip.x > data_tileset.vertical_tiles - 1 or
		cs.y + ip.y > data_tileset.horizontal_tiles - 1):
		cs = Vector2(-1, -1)
	return cs

func _on_Tileset_mouse_entered() -> void:
	if !image_real.texture: return
	cursor_mouse_over.visible = true

func _on_Tileset_mouse_exited() -> void:
	cursor_mouse_over.visible = false
	
func hide_all_dialogs():
	thread = null
	hide_behind.visible = false
	file_dialog.visible = false
	create_autotile_dialog.visible = false
	edit_autotile_dialog.visible = false
	error1_dialog.visible = false
	error2_dialog.visible = false
	save_dialog.visible = false
	tooltip.hide_all()
	saving_animation.visible = false
	
func show_dialog(dialog):
	hide_behind.visible = true
	dialog.visible = true
	tooltip.hide_all()


func _on_ImageListButton_button_up() -> void:
	if hide_behind.visible: return
	folder_mode = null
	file_dialog.set_valid_files(["png"])
	file_dialog.set_title("Select an Image")
	file_dialog.allow_multiple_selection = true
	file_dialog.directory_mode = false
	file_dialog.set_allow_external_files_visibility(true)
	show_dialog(file_dialog)


func _on_hide_behind_controls_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			hide_all_dialogs()


func _on_CustomFileDialog_select_files(files_string_array) -> void:
	if files_string_array.size() > 0:
		if folder_mode:
			if files_string_array[0].length() == 0:
				return
			if folder_mode == "autotiles":
				autotiles_lineEdit.text = files_string_array[0]
			elif folder_mode == "tileset":
				tileset_lineEdit.text = files_string_array[0]
			elif folder_mode == "tilemap":
				save_dialog_tilemap_path.text = files_string_array[0]
			folder_mode = null
			return
		for file in files_string_array:
			if file.length() == 0: continue
			if !data_images_has(file):
				var file_name = file.get_file().trim_suffix("." + file.get_extension())
				if file_name.length() == 0: continue
				data_images.append({
					"name"	: file_name,
					"path"	: file
				})
				
		fill_image_list()
		if data_images.size() == 0: return
		var file = files_string_array[-1]
		var selectedIndex = 0
		for i in data_images.size():
			if data_images[i].path == file:
				selectedIndex = i
				break
		image_list.select(selectedIndex)
		image_list.ensure_current_is_visible()
		_on_list_item_selected(selectedIndex)
		
	hide_all_dialogs()
	
func data_images_has(file) -> bool:
	for i in data_images.size():
		var obj = data_images[i]
		if obj.path == file:
			return true
	return false
	
func fit_image(fit_width = true, fit_height = true):
	if !image_real.texture: return
	var zoom_x; var zoom_y;
	if fit_width:
		zoom_x = tileset_container.rect_size.x / image_real.texture.get_width()
	if fit_height:
		zoom_y = tileset_container.rect_size.y / image_real.texture.get_height()
	if !fit_width and !fit_height:
		zoom_x = 1
		zoom_y = 1
	elif !fit_width:
		zoom_x = zoom_y
	elif !fit_height:
		zoom_y = zoom_x
	final_zoom = Vector2(zoom_x, zoom_y)
	#image_real.rect_scale = Vector2(zoom_x, zoom_y)
	set_tiles()
	set_max_scroll_in_scroll_bars()
	set_cursor_sizes()


func _on_FitImageButton_button_up() -> void:
	if Input.is_key_pressed(KEY_CONTROL):
		fit_image(false, true)
	elif Input.is_key_pressed(KEY_ALT):
		fit_image(true, false)
	else:
		fit_image(true, true)


func _on_CustomFileDialog_hide() -> void:
	hide_all_dialogs()


func _on_list_item_selected(index: int) -> void:
	image_real.texture = null
	if index == -1: return
	if data_images[index].path.substr(0, 6) == "res://":
		image_real.texture = load(data_images[index].path)
	else:
		image_real.texture = load_external_texture(data_images[index].path)
	image_real.rect_size = image_real.texture.get_size()
	fit_image(true, false)
	data_tileset.current_selection = Vector2.ZERO
	data_tileset.current_selected = Vector2.ZERO
	update_preview_selected()
	set_cursor_position(cursor_selected)
	cursor_selected.visible = true
	if create_tile_button.disabled:
		create_tile_button.disabled = false
		fast_export_button.disabled = false


func _on_select_autotiles_folder_Button_button_up() -> void:
	select_folder("autotiles")


func _on_select_tilesets_folder_Button_button_up() -> void:
	select_folder("tileset")


func _on_autotiles_folder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			select_folder("autotiles")


func _on_tileset_folder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			select_folder("tileset")
			
func select_folder(id):
	file_dialog.set_valid_files(["all"])
	file_dialog.set_title("Select Folder to save %s" % id)
	file_dialog.set_allow_external_files_visibility(false)
	file_dialog.allow_multiple_selection = false
	file_dialog.directory_mode = true
	var text
	if id == "autotiles":
		text = autotiles_lineEdit.text
	elif id == "tileset":
		text = tileset_lineEdit.text
	elif id == "tilemap":
		text = save_dialog_tilemap_path.text
	file_dialog.set_initial_folder(text)
	folder_mode = id
	show_dialog(file_dialog)


func _on_OptionButton_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("MouseWheelUp"):
		change_autotile_preset(-1)
	elif event.is_action_pressed("MouseWheelDown"):
		change_autotile_preset(1)
		
func change_autotile_preset(index):
	var selected_index = preset_button.get_selected_id() + index
	var _max = preset_button.get_item_count() - 1
	if selected_index > _max:
		selected_index = 0
	elif selected_index < 0:
		selected_index = _max
	preset_button.select(selected_index)
	preset_button.emit_signal("item_selected", selected_index)
	
func update_data_tileset_values():
	data_tileset.columns 			=	config_columns_button.value
	data_tileset.rows 				=	config_rows_button.value
	data_tileset.tile_width			=	config_tile_width_button.value
	data_tileset.tile_height		=	config_tile_height_button.value
	if preset_button.selected == 8:
		data_tileset.layout = -1
		data_tileset.type = -1
		preview_autotile_config.texture	= 	preview_config_images[4]
	else:
		data_tileset.layout			=	config_layout_button.get_selected_id()
		data_tileset.type			=	config_layout2_button.get_selected_id()
		var texture_id = data_tileset.layout + data_tileset.type
		preview_autotile_config.texture	= 	preview_config_images[texture_id]
	
	set_tiles()
	set_cursor_sizes()
	set_cursor_position(cursor_selected)
	update_preview_selected()

func _on_config_OptionButton_item_selected(index: int) -> void:
	var _data
	can_action = false
	match index:
		0: _data = [3, 4, 32, 32, 0, 0] # XP
		1: _data = [2, 3, 32, 32, 1, 0] # AUTOTILE VXACE - FLOOR
		2: _data = [2, 2, 32, 32, 1, 1] # AUTOTILE VXACE - WALL
		3: _data = [2, 1, 32, 32, 1, 2] # AUTOTILE VXACE - WATERFALL
		4: _data = [2, 3, 48, 48, 1, 0] # AUTOTILE MV - FLOOR
		5: _data = [2, 2, 48, 48, 1, 1] # AUTOTILE MV - WALL
		6: _data = [2, 1, 48, 48, 1, 2] # AUTOTILE MV - WATERFALL
		7: # CUSTOM
			config_columns_button.value 		= 	3
			config_rows_button.value 			= 	4
			config_tile_width_button.value		= 	32
			config_tile_height_button.value		= 	32
			config_layout_button.disabled 		= 	false
			config_tile_width_button.editable 	= 	true
			config_tile_height_button.editable 	= 	true
			config_layout_label.visible			= 	true
			config_layout_button.select(			0)
			config_layout2_button.select(			0)
			update_data_tileset_values()
			can_action = true
			return
		8: _data = [1, 1, 32, 32, -1, -1] # SINGLE TILE
	config_layout_button.disabled 		= 	true
	config_layout2_button.disabled 		= 	true
	config_layout_label.visible			= 	index != 8
	config_tile_width_button.editable 	= 	index == 8
	config_tile_height_button.editable 	= 	index == 8
	config_columns_button.editable 		= 	index == 8
	config_rows_button.editable 		= 	index == 8
	config_columns_button.value			=	_data[0]
	config_rows_button.value			=	_data[1]
	config_tile_width_button.value		=	_data[2]
	config_tile_height_button.value		=	_data[3]
	config_layout_button.select(			_data[4])
	config_layout2_button.select(			_data[5])
	update_data_tileset_values()
	can_action = true


func _on_OptionButton_item_selected(index: int) -> void:
	can_action = false
	if index == 0:
		config_columns_button.value 		= 	3
		config_rows_button.value 			= 	4
		config_layout2_button.disabled		=	true
		config_layout2_button.select(			0)
	else:
		config_columns_button.value 		= 	2
		config_rows_button.value 			= 	3
		config_layout2_button.disabled		=	false
		config_layout2_button.select(			0)
	update_data_tileset_values()
	can_action = true


func _on_OptionButton2_item_selected(index: int) -> void:
	can_action = false
	if index == 0:
		config_columns_button.value 		= 	2
		config_rows_button.value 			= 	3
	elif index == 1:
		config_columns_button.value 		= 	2
		config_rows_button.value 			= 	2
	elif index == 2:
		config_columns_button.value 		= 	2
		config_rows_button.value 			= 	1
	update_data_tileset_values()
	can_action = true

func _on_tile_rows_SpinBox_value_changed(value: float) -> void:
	if !can_action: return
	update_data_tileset_values()

func _on_tile_columns_SpinBox_value_changed(value: float) -> void:
	if !can_action: return
	update_data_tileset_values()
	
func _on_tile_width_SpinBox_value_changed(value: float) -> void:
	if !can_action: return
	update_data_tileset_values()


func _on_tile_height_SpinBox_value_changed(value: float) -> void:
	if !can_action: return
	update_data_tileset_values()
	


func _on_create_autotile_Button_button_up() -> void:
	if data_tileset.current_selected != Vector2(-1, -1):
		var d = create_autotile_dialog
		var pos = get_global_mouse_position()
		pos.x = pos.x - d.rect_size.x + 77
		if pos.x + d.rect_size.x > get_viewport().size.x:
			pos.x = get_viewport().size.x - d.rect_size.x - 10
		pos.y += 27
		d.rect_global_position = pos
		show_dialog(d)


func _on_create_autotile_dialog_ok_button_pressed() -> void:
	if !create_autotile_dialog.visible: return
	create_autotile_dialog_s.apply()
	var text = create_autotile_dialog_t.text
	var collision_type = create_autotile_dialog_c.get_selected_id()
	var occlusion = create_autotile_dialog_o.pressed
	var collision_percent = create_autotile_dialog_s.value
	if text.length() > 0:
		var new_autotile = Autotile.new()
		new_autotile.name = get_fix_name_for_paths(text)
		new_autotile.collision_type = collision_type
		new_autotile.occlusion = occlusion
		new_autotile.collision_percent = collision_percent
		if preset_button.selected != 8:
			new_autotile.type = (config_layout_button.get_selected_id() +
				config_layout2_button.get_selected_id())
		else:
			new_autotile.type = -1
		new_autotile.path = data_images[image_list.get_selected_items()[0]].path
		var x = data_tileset.current_selected.x * data_tileset.tile_width
		var y = data_tileset.current_selected.y * data_tileset.tile_height
		var w = data_tileset.selection_width
		var h = data_tileset.selection_height
		new_autotile.rect = Rect2(Vector2(x, y), Vector2(w, h))
		new_autotile.tile_width = config_tile_width_button.value
		new_autotile.tile_height = config_tile_height_button.value
		data_tileset.tiles.append(new_autotile)
		var t = get_type_name(new_autotile.type)
		autotile_list.add_item("%s (%s%dx%d)" %
			[new_autotile.name, t, new_autotile.tile_width, new_autotile.tile_height])
		autotile_list.select(data_tileset.tiles.size() - 1)
		autotile_list.ensure_current_is_visible()
		autotile_list.emit_signal("item_selected", data_tileset.tiles.size() - 1)
		save_all_button.disabled = false
		save_all_button.modulate.a = 1
	hide_all_dialogs()
	if remove_autotile_button.disabled:
		remove_autotile_button.disabled = false
	edit_autotile_button.disabled = remove_autotile_button.disabled
	autotile_list.grab_focus()


func _on_LineEdit_visibility_changed() -> void:
	if create_autotile_dialog_t.visible:
		var text
		match preset_button.selected:
			0, 1, 4	: 	text = get_fix_name_for_paths("Floor-Autotile_1")
			2, 5	: 	text = get_fix_name_for_paths("Wall-Autotile_1")
			3, 6	:	text = get_fix_name_for_paths("Waterfall-Autotile_1")
			7		:
				if config_layout2_button.selected == 0:
						text = get_fix_name_for_paths("Floor-Autotile_1")
				elif config_layout2_button.selected == 1:
						text = get_fix_name_for_paths("Wall-Autotile_1")
				else:
						text = get_fix_name_for_paths("Waterfall-Autotile_1")
			8		: 	text = get_fix_name_for_paths("Single-Tile_1")
				
		create_autotile_dialog_t.text = text
		create_autotile_dialog_t.caret_position = text.length()
		create_autotile_dialog_t.select_all()
		create_autotile_dialog_t.grab_focus()
		
func get_tile(autotile : Autotile) -> Image:
	var autotile_table; var columns; var rows;
	# get autotile table
	match autotile.type:
		-1: # SINGLE TILE
			columns = 1
			rows = 1
		0: # XP
			autotile_table = get_xp_autotile_table()
			columns = 6
			rows = 8
		1: # Floor VX, ACE, MV
			autotile_table = get_floor_autotile_table()
			columns = 6
			rows = 8
		2: # Wall VX, ACE, MV
			autotile_table = get_wall_autotile_table()
			columns = 4
			rows = 8
		3: # Waterfall VX, ACE, MV
			autotile_table = get_waterfall_autotile_table()
			columns = 6
			rows = 4
	# create image with right size
	var w = autotile.tile_width
	var h = autotile.tile_height
	if autotile.type == -1:
		w = autotile.rect.size.x
		h = autotile.rect.size.y
	var x = 0
	var y = 0
	var img = Image.new()
	var _pattern
	if autotile.animation.size() > 0:
		var tile = autotile.animation[autotile.frame]
		img = get_tile(tile)
		autotile.frame += 1
		if autotile.frame > autotile.animation.size() - 1:
			autotile.frame = 0
		current_animation = autotile
		return img
	elif autotile.mixed.size() > 0:
		var tile = autotile.mixed[0]
		img = get_tile(tile)
		var dest = Vector2.ZERO
		var src_rect = Rect2(Vector2.ZERO,
			Vector2(img.get_width(), img.get_height()))
		for i in range(1, autotile.mixed.size()):
			var img2 = get_tile(autotile.mixed[i])
			img.blend_rect(img2, src_rect, dest)
		return img
	else:
		if autotile.path.substr(0, 6) == "res://":
			_pattern = load(autotile.path).get_data()
		else:
			_pattern = Image.new()
			_pattern.load(autotile.path)
		_pattern.convert(Image.FORMAT_RGBA8)
	# create Autotile
	img.create(w * columns, h * rows, false, Image.FORMAT_RGBA8)
	if autotile.type == -1: # Get single tile
		var xi = autotile.rect.position.x
		var yi = autotile.rect.position.y
		var _w = autotile.rect.size.x
		var _h = autotile.rect.size.y
		var src_rect = Rect2(Vector2(xi, yi), Vector2(_w, _h))
		var dest = Vector2.ZERO
		img.blit_rect(_pattern, src_rect, dest)
	else:
		var _w = w * 0.5
		var _h = h * 0.5
		var xi = autotile.rect.position.x
		var yi = autotile.rect.position.y
		for tile in autotile_table:
			for i in tile.size():
				var vx = tile[i][0]
				var vy = tile[i][1]
				var src_rect = Rect2(Vector2(xi + vx *_w, yi + vy *_h), Vector2(_w, _h))
				var dest = Vector2(x + i%2 * _w, y + i/2 * _h)
				img.blit_rect(_pattern, src_rect, dest)
			x += w
			if x >= img.get_width():
				x = 0
				y += h
	# return image created
	return img
	
	
func update_autotile_preview(autotile, return_image = false):
	var result_image = get_tile(autotile)
	if !return_image: # load image in preview_autotile
		preview_autotile.texture = load_external_texture(result_image)
	else:
		return result_image
		
func load_external_texture(path) -> ImageTexture:
	var img
	if path is String:
		img = Image.new()
		img.load(path)
	elif path is Image:
		img = path
	else:
		return ImageTexture.new()
	img.convert(Image.FORMAT_RGBA8)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex
	
		
func get_xp_autotile_table() -> Array:
	var table = [
		[[2,4],[3,4],[2,5],[3,5]], [[4,0],[3,4],[2,5],[3,5]],
		[[2,4],[5,0],[2,5],[3,5]], [[4,0],[5,0],[2,5],[3,5]],
		[[2,4],[3,4],[2,5],[5,1]], [[4,0],[3,4],[2,5],[5,1]],
		[[2,4],[5,0],[2,5],[5,1]], [[4,0],[5,0],[2,5],[5,1]],
		[[2,4],[3,4],[4,1],[3,5]], [[4,0],[3,4],[4,1],[3,5]],
		[[2,4],[5,0],[4,1],[3,5]], [[4,0],[5,0],[4,1],[3,5]],
		[[2,4],[3,4],[4,1],[5,1]], [[4,0],[3,4],[4,1],[5,1]],
		[[2,4],[5,0],[4,1],[5,1]], [[4,0],[5,0],[4,1],[5,1]],
		[[0,4],[1,4],[0,5],[1,5]], [[0,4],[5,0],[0,5],[1,5]],
		[[0,4],[1,4],[0,5],[5,1]], [[0,4],[5,0],[0,5],[5,1]],
		[[2,2],[3,2],[2,3],[3,3]], [[2,2],[3,2],[2,3],[5,1]],
		[[2,2],[3,2],[4,1],[3,3]], [[2,2],[3,2],[4,1],[5,1]],
		[[4,4],[5,4],[4,5],[5,5]], [[4,4],[5,4],[4,1],[5,5]],
		[[4,0],[5,4],[4,5],[5,5]], [[4,0],[5,4],[4,1],[5,5]],
		[[2,6],[3,6],[2,7],[3,7]], [[4,0],[3,6],[2,7],[3,7]],
		[[2,6],[5,0],[2,7],[3,7]], [[4,0],[5,0],[2,7],[3,7]],
		[[0,4],[5,4],[0,5],[5,5]], [[2,2],[3,2],[2,7],[3,7]],
		[[0,2],[1,2],[0,3],[1,3]], [[0,2],[1,2],[0,3],[5,1]],
		[[4,2],[5,2],[4,3],[5,3]], [[4,2],[5,2],[4,1],[5,3]],
		[[4,6],[5,6],[4,7],[5,7]], [[4,0],[5,6],[4,7],[5,7]],
		[[0,6],[1,6],[0,7],[1,7]], [[0,6],[5,0],[0,7],[1,7]],
		[[0,2],[5,2],[0,3],[5,3]], [[0,2],[1,2],[0,7],[1,7]],
		[[0,6],[5,6],[0,7],[5,7]], [[4,2],[5,2],[4,7],[5,7]],
		[[0,2],[5,2],[0,7],[5,7]], [[0,0],[1,0],[0,1],[1,1]]
	]
	return table
	
func get_floor_autotile_table() -> Array:
	var table = [
		[[2,4],[1,4],[2,3],[1,3]], [[2,0],[1,4],[2,3],[1,3]],
		[[2,4],[3,0],[2,3],[1,3]], [[2,0],[3,0],[2,3],[1,3]],
		[[2,4],[1,4],[2,3],[3,1]], [[2,0],[1,4],[2,3],[3,1]],
		[[2,4],[3,0],[2,3],[3,1]], [[2,0],[3,0],[2,3],[3,1]],
		[[2,4],[1,4],[2,1],[1,3]], [[2,0],[1,4],[2,1],[1,3]],
		[[2,4],[3,0],[2,1],[1,3]], [[2,0],[3,0],[2,1],[1,3]],
		[[2,4],[1,4],[2,1],[3,1]], [[2,0],[1,4],[2,1],[3,1]],
		[[2,4],[3,0],[2,1],[3,1]], [[2,0],[3,0],[2,1],[3,1]],
		[[0,4],[1,4],[0,3],[1,3]], [[0,4],[3,0],[0,3],[1,3]],
		[[0,4],[1,4],[0,3],[3,1]], [[0,4],[3,0],[0,3],[3,1]],
		[[2,2],[1,2],[2,3],[1,3]], [[2,2],[1,2],[2,3],[3,1]],
		[[2,2],[1,2],[2,1],[1,3]], [[2,2],[1,2],[2,1],[3,1]],
		[[2,4],[3,4],[2,3],[3,3]], [[2,4],[3,4],[2,1],[3,3]],
		[[2,0],[3,4],[2,3],[3,3]], [[2,0],[3,4],[2,1],[3,3]],
		[[2,4],[1,4],[2,5],[1,5]], [[2,0],[1,4],[2,5],[1,5]],
		[[2,4],[3,0],[2,5],[1,5]], [[2,0],[3,0],[2,5],[1,5]],
		[[0,4],[3,4],[0,3],[3,3]], [[2,2],[1,2],[2,5],[1,5]],
		[[0,2],[1,2],[0,3],[1,3]], [[0,2],[1,2],[0,3],[3,1]],
		[[2,2],[3,2],[2,3],[3,3]], [[2,2],[3,2],[2,1],[3,3]],
		[[2,4],[3,4],[2,5],[3,5]], [[2,0],[3,4],[2,5],[3,5]],
		[[0,4],[1,4],[0,5],[1,5]], [[0,4],[3,0],[0,5],[1,5]],
		[[0,2],[3,2],[0,3],[3,3]], [[0,2],[1,2],[0,5],[1,5]],
		[[0,4],[3,4],[0,5],[3,5]], [[2,2],[3,2],[2,5],[3,5]],
		[[0,2],[3,2],[0,5],[3,5]], [[0,0],[1,0],[0,1],[1,1]]
	]
	return table
	
func get_wall_autotile_table() -> Array:
	var table = [
		[[2,2],[1,2],[2,1],[1,1]], [[0,2],[1,2],[0,1],[1,1]],
		[[0,2],[1,2],[0,1],[1,1]], [[0,2],[1,2],[0,1],[1,1]],
		[[0,2],[1,2],[0,1],[1,1]], [[2,2],[3,2],[2,1],[3,1]],
		[[2,2],[3,2],[2,1],[3,1]], [[2,2],[3,2],[2,1],[3,1]],
		[[2,2],[3,2],[2,1],[3,1]], [[2,0],[1,0],[2,1],[1,1]],
		[[2,0],[1,0],[2,1],[1,1]], [[2,0],[1,0],[2,1],[1,1]],
		[[2,0],[1,0],[2,1],[1,1]], [[2,2],[1,2],[2,3],[1,3]],
		[[2,2],[1,2],[2,3],[1,3]], [[2,2],[1,2],[2,3],[1,3]],
		[[2,2],[1,2],[2,3],[1,3]], [[0,2],[3,2],[0,1],[3,1]],
		[[2,0],[1,0],[2,3],[1,3]], [[0,0],[1,0],[0,1],[1,1]],
		[[0,0],[1,0],[0,1],[1,1]], [[2,0],[3,0],[2,1],[3,1]],
		[[2,0],[3,0],[2,1],[3,1]], [[0,2],[1,2],[0,3],[1,3]],
		[[0,2],[1,2],[0,3],[1,3]], [[2,2],[3,2],[2,3],[3,3]],
		[[2,2],[3,2],[2,3],[3,3]], [[0,0],[3,0],[0,1],[3,1]],
		[[0,0],[1,0],[0,3],[1,3]], [[0,2],[3,2],[0,3],[3,3]],
		[[2,0],[3,0],[2,3],[3,3]], [[0,0],[3,0],[0,3],[3,3]]
		# Original
#		[[2,2],[1,2],[2,1],[1,1]], [[0,2],[1,2],[0,1],[1,1]],
#		[[2,0],[1,0],[2,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
#		[[2,2],[3,2],[2,1],[3,1]], [[0,2],[3,2],[0,1],[3,1]],
#		[[2,0],[3,0],[2,1],[3,1]], [[0,0],[3,0],[0,1],[3,1]],
#		[[2,2],[1,2],[2,3],[1,3]], [[0,2],[1,2],[0,3],[1,3]],
#		[[2,0],[1,0],[2,3],[1,3]], [[0,0],[1,0],[0,3],[1,3]],
#		[[2,2],[3,2],[2,3],[3,3]], [[0,2],[3,2],[0,3],[3,3]],
#		[[2,0],[3,0],[2,3],[3,3]], [[0,0],[3,0],[0,3],[3,3]]
	]
	return table
	
func get_waterfall_autotile_table() -> Array:
	var table = [
		[[2,0],[1,0],[2,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
		[[0,0],[1,0],[0,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
		[[0,0],[1,0],[0,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
		[[0,0],[1,0],[0,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
		[[0,0],[1,0],[0,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
		[[2,0],[3,0],[2,1],[3,1]], [[2,0],[3,0],[2,1],[3,1]],
		[[2,0],[3,0],[2,1],[3,1]], [[2,0],[3,0],[2,1],[3,1]],
		[[2,0],[3,0],[2,1],[3,1]], [[2,0],[3,0],[2,1],[3,1]],
		[[2,0],[3,0],[2,1],[3,1]], [[2,0],[3,0],[2,1],[3,1]],
		[[2,0],[3,0],[2,1],[3,1]], [[0,0],[3,0],[0,1],[3,1]],
		[[0,0],[3,0],[0,1],[3,1]], [[0,0],[3,0],[0,1],[3,1]],
		[[0,0],[3,0],[0,1],[3,1]], [[0,0],[3,0],[0,1],[3,1]],
		# Original
#		[[2,0],[1,0],[2,1],[1,1]], [[0,0],[1,0],[0,1],[1,1]],
#		[[2,0],[3,0],[2,1],[3,1]], [[0,0],[3,0],[0,1],[3,1]]
	]
	return table
	
func get_fix_name_for_paths(text : String) -> String:
	text = text.replace(" ", "_")
	text = text.lstrip("_")
	text = text.rstrip("_")
	var illegal = ["<",">",":","\"","/","\\","|","?","*"]
	for _char in illegal: text = text.replace(_char, "")
	text = get_path_name(text)
	return text

func get_path_name(text : String) -> String:
	var n = 2
	var duplicated = true
	var new_text = text
	var regex = RegEx.new()
	regex.compile("(.*_)(\\d+)$")
	while duplicated:
		duplicated = false
		for _data in data_tileset.tiles:
			if _data.name == new_text:
				var result = regex.search(new_text)
				if result:
					n = int(result.get_strings()[2]) + 1
					new_text = "%s%s" % [result.get_strings()[1], n]
				else:
					new_text = "%s_%s" % [text, n]
					n += 1
				duplicated = true
				break
				
	return new_text


func _on_autotile_list_item_selected(index: int) -> void:
	var autotile = data_tileset.tiles[index]
	autotile.frame = 0
	current_animation = null
	update_autotile_preview(autotile)
	move_autotiles_up_button.disabled = autotile_list.is_selected(0)
	move_autotiles_down_button.disabled = autotile_list.is_selected(
		data_tileset.tiles.size() - 1)
	merge_autotiles_button.disabled = autotile_list.get_selected_items().size() < 2
	create_a_animation_button.disabled = merge_autotiles_button.disabled
	timer.stop()
	timer.wait_time = autotile.animation_delay
	timer.start()

func _on_list_multi_selected(index: int, selected: bool) -> void:
	if selected:
		_on_autotile_list_item_selected(index)
	else:
		merge_autotiles_button.disabled = autotile_list.get_selected_items().size() < 2


func _on_edit_autotile_button_button_up() -> void:
	var ids = autotile_list.get_selected_items()
	autotile_list.unselect_all()
	autotile_list.select(ids[-1])
	autotile_list.emit_signal("item_selected", ids[-1])
	var autotile_name 				= data_tileset.tiles[ids[-1]].name
	var autotile_animation_delay 	= data_tileset.tiles[ids[-1]].animation_delay
	var collision_type				= data_tileset.tiles[ids[-1]].collision_type
	var occlusion					= data_tileset.tiles[ids[-1]].occlusion
	var collision_percent			= data_tileset.tiles[ids[-1]].collision_percent
	name_autotile_dialog_b.text = autotile_name
	speed_autotile_dialog_b.value = autotile_animation_delay
	percent_autotile_dialog_b.value = collision_percent
	percent_autotile_dialog_b.editable = collision_type == 1
	collision_autotile_dialog_b.select(collision_type)
	occlusion_autotile_dialog_b.pressed = occlusion
	var pos = get_global_mouse_position() + Vector2(31, 26)
	pos.x -= edit_autotile_dialog.rect_size.x
	edit_autotile_dialog.rect_global_position = pos
	show_dialog(edit_autotile_dialog)
	name_autotile_dialog_b.caret_position = name_autotile_dialog_b.text.length()
	name_autotile_dialog_b.select_all()
	name_autotile_dialog_b.grab_focus()
	
func _on_edit_autotile_ok_button_button_up():
	if !edit_autotile_dialog.visible: return
	var id = autotile_list.get_selected_items()[0]
	if (name_autotile_dialog_b.text.length() > 0 and
		name_autotile_dialog_b.text != data_tileset.tiles[id].name):
		var autotile_name = name_autotile_dialog_b.text
		autotile_name = get_fix_name_for_paths(autotile_name)
		data_tileset.tiles[id].name = autotile_name
		autotile_list.set_item_text(id, "%s (%s%dx%d)" %
			[	autotile_name,
				get_type_name(data_tileset.tiles[id].type),
				data_tileset.tiles[id].tile_width,
				data_tileset.tiles[id].tile_height
			]
		)
	speed_autotile_dialog_b.apply()
	percent_autotile_dialog_b.apply()
	var autotile_animation_delay 	= speed_autotile_dialog_b.value
	var collision_type				= collision_autotile_dialog_b.get_selected_id()
	var occlusion					= occlusion_autotile_dialog_b.pressed
	var collision_percent			= percent_autotile_dialog_b.value
	data_tileset.tiles[id].animation_delay = autotile_animation_delay
	data_tileset.tiles[id].collision_type = collision_type
	data_tileset.tiles[id].occlusion = occlusion
	data_tileset.tiles[id].collision_percent = collision_percent
	timer.stop()
	timer.wait_time = autotile_animation_delay
	timer.start()
	if current_animation != null:
		current_animation.frame = 0
	hide_all_dialogs()
	
func _on_autotiles_list_gui_input(event: InputEvent):
	if (event is InputEventMouseButton and event.button_index == 1 and
		event.doubleclick):
			var id = autotile_list.get_item_at_position(
				autotile_list.get_local_mouse_position())
			autotile_list.unselect_all()
			autotile_list.select(id)
			autotile_list.emit_signal("item_selected", id)
			var autotile_name 				= data_tileset.tiles[id].name
			var autotile_animation_delay 	= data_tileset.tiles[id].animation_delay
			var collision_type				= data_tileset.tiles[id].collision_type
			var occlusion					= data_tileset.tiles[id].occlusion
			var collision_percent			= data_tileset.tiles[id].collision_percent
			name_autotile_dialog_b.text = autotile_name
			speed_autotile_dialog_b.value = autotile_animation_delay
			collision_autotile_dialog_b.select(collision_type)
			percent_autotile_dialog_b.value = collision_percent
			percent_autotile_dialog_b.editable = collision_type == 1
			occlusion_autotile_dialog_b.pressed = occlusion
			var pos = get_global_mouse_position() + Vector2(31, 26)
			pos.x -= edit_autotile_dialog.rect_size.x
			edit_autotile_dialog.rect_global_position = pos
			show_dialog(edit_autotile_dialog)
			name_autotile_dialog_b.caret_position = name_autotile_dialog_b.text.length()
			name_autotile_dialog_b.select_all()
			name_autotile_dialog_b.grab_focus()

func _on_move_autotile_up_button_button_up() -> void:
	var ids = autotile_list.get_selected_items()
	var start_position = ids[0] - 1
	for i in ids:
		autotile_list.move_item(i, start_position)
		var autotile = data_tileset.tiles[i]
		data_tileset.tiles.remove(i)
		data_tileset.tiles.insert(start_position, autotile)
		start_position += 1
	var index = autotile_list.get_selected_items()[-1]
	_on_autotile_list_item_selected(index)


func _on_move_autotile_down_button_button_up() -> void:
	var ids = autotile_list.get_selected_items()
	ids.invert()
	var start_position = ids[0] + 1
	for i in ids:
		autotile_list.move_item(i, start_position)
		var autotile = data_tileset.tiles[i]
		data_tileset.tiles.remove(i)
		data_tileset.tiles.insert(start_position, autotile)
		start_position -= 1
	var index = autotile_list.get_selected_items()[-1]
	_on_autotile_list_item_selected(index)


func _on_create_merged_autotile_button_button_up() -> void:
	var ids = autotile_list.get_selected_items()
	var w = data_tileset.tiles[ids[0]].tile_width
	var h = data_tileset.tiles[ids[0]].tile_height
	var t = data_tileset.tiles[ids[0]].type
	# check if all selected tiles has same size and type
	for i in range(1, ids.size()):
		if (data_tileset.tiles[ids[i]].tile_width != w or
			data_tileset.tiles[ids[i]].tile_height != h or
			data_tileset.tiles[ids[i]].type != t):
			var pos = get_global_mouse_position()
			pos.x = pos.x - error1_dialog.rect_size.x + 72
			pos.y = pos.y + 22
			error1_dialog.rect_global_position = pos
			show_dialog(error1_dialog)
			return # error mixing tiles
	# tiles are right, mixing it
	var new_autotile = data_tileset.tiles[ids[0]].duplicate()
	for i in range(0, ids.size()):
		var t2 = data_tileset.tiles[ids[i]].duplicate()
		new_autotile.mixed.append(t2)
	new_autotile.name = get_path_name("mixed_1")
	# add autotile to data
	data_tileset.tiles.append(new_autotile)
	t = get_type_name(t)
	autotile_list.add_item("%s (%s%dx%d)" %
		[new_autotile.name, t, new_autotile.tile_width, new_autotile.tile_height])
	autotile_list.select(data_tileset.tiles.size() - 1)
	autotile_list.ensure_current_is_visible()
	autotile_list.emit_signal("item_selected", data_tileset.tiles.size() - 1)

func _on_create_animated_autotile_button_button_up() -> void:
	var ids = autotile_list.get_selected_items()
	var w = data_tileset.tiles[ids[0]].tile_width
	var h = data_tileset.tiles[ids[0]].tile_height
	var t = data_tileset.tiles[ids[0]].type
	# check if all selected tiles has same size and type
	for i in range(1, ids.size()):
		if (data_tileset.tiles[ids[i]].tile_width != w or
			data_tileset.tiles[ids[i]].tile_height != h or
			data_tileset.tiles[ids[i]].type != t):
			var pos = get_global_mouse_position()
			pos.x = pos.x - error1_dialog.rect_size.x + 72
			pos.y = pos.y + 22
			error1_dialog.rect_global_position = pos
			show_dialog(error1_dialog)
			return # error, tiles wuth different size or type
	# tiles are right, delete them and create a new autotile animated
	ids.invert()
	var autotiles = []
	for i in ids:
		autotiles.insert(0, data_tileset.tiles[i])
		data_tileset.tiles.remove(i)
		autotile_list.remove_item(i)
	var new_autotile = autotiles[0].duplicate()
	for autotile in autotiles:
		if autotile.animation.size() > 0:
			for sub_tile in autotile.animation:
				new_autotile.animation.append(sub_tile)
		else:
			new_autotile.animation.append(autotile)
	new_autotile.name = get_path_name("Animation_1")
	# add autotile to data
	data_tileset.tiles.append(new_autotile)
	t = get_type_name(t)
	autotile_list.add_item("%s (%s%dx%d)" %
		[new_autotile.name, t, new_autotile.tile_width, new_autotile.tile_height])
	autotile_list.select(data_tileset.tiles.size() - 1)
	autotile_list.ensure_current_is_visible()
	autotile_list.emit_signal("item_selected", data_tileset.tiles.size() - 1)
		
func get_type_name(id):
	match id:
		-1 : return "single - "
		0, 1: return "floor - "
		2: return "wall - "
		3: return "waterfall - "


func animate_autotile_selected() -> void:
	if current_animation != null:
		update_autotile_preview(current_animation)


func _on_remove_autotile_button_up() -> void:
	tooltip.hide_all()
	var index = autotile_list.get_selected_items()[-1]
	if get_focus_owner() != autotile_list: return
	var ids = autotile_list.get_selected_items()
	ids.invert()
	for i in ids:
		data_tileset.tiles.remove(i)
		autotile_list.remove_item(i)
	index = min(autotile_list.get_item_count() - 1, index)
	if index >= 0:
		autotile_list.select(index)
		autotile_list.emit_signal("item_selected", index)
	else:
		preview_autotile.texture = null
		current_animation = null
	save_all_button.disabled = data_tileset.tiles.size() == 0
	save_all_button.modulate.a = 0.4 if save_all_button.disabled else 1
	remove_autotile_button.disabled = save_all_button.disabled
	edit_autotile_button.disabled = remove_autotile_button.disabled
	

func _on_remove_autotile_Button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			autotile_list.grab_focus()


func _on_error_dialog_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			hide_all_dialogs()



func _on_save_all_Button_button_up() -> void:
	if data_tileset.tiles.size() == 0: return
	# get Data struct
	var data = get_data_struct(data_tileset.tiles)
	# Create save panel for each key
	for key in data.keys():
		var panel = save_panel_scene.instance()
		panel.id = save_dialog_container_vbox.get_child_count()
		panel.connect("deleted", self, "delete_tilemap_in_save_dialog")
		panel.connect("show_ultimate_revision_dialog_request",
			self, "show_ultimate_revision_dialog")
		save_dialog_container_vbox.add_child(panel)
		var lineedit = panel.columns_spinBox.get_line_edit()
		lineedit.connect('focus_entered', self,
			'save_dialog_on_focus_changed')
		lineedit.connect('focus_exited', self,
			'save_dialog_on_focus_exited', [lineedit])
		panel.tilemap_name_lineEdit.connect('focus_entered', self,
			'save_dialog_on_focus_changed')
		panel.tilemap_name_lineEdit.connect('focus_exited', self,
			'save_dialog_on_focus_exited', [panel.tilemap_name_lineEdit])
		panel.tileset_name_lineEdit.connect('focus_entered', self,
			'save_dialog_on_focus_changed')
		panel.tileset_name_lineEdit.connect('focus_exited', self,
			'save_dialog_on_focus_exited', [panel.tileset_name_lineEdit])
		var data2 = {
			"tile_width"		: key[0],
			"tile_height"		: key[1],
			"autotile_path"		: autotiles_lineEdit.text,
			"tileset_path"		: tileset_lineEdit.text,
			"tilemap_path"		: save_dialog_tilemap_path.text,
			"tiles"				: data[key],
		}
		panel.set_initial_values(
			"Tiles %sx%s" % [key[0], key[1]],
			get_fix_name_for_paths("New Tilemap (%sx%s)" % [key[0], key[1]]),
			get_fix_name_for_paths("New Tileset (%sx%s)" % [key[0], key[1]]),
			16,
			data2
		)
		update_style_for_input_and_text_boxes(panel)
	# Show save dialog
	show_dialog(save_dialog)
	
func get_data_struct(_data : Array) -> Dictionary:
	var data = {}
	for tile in _data:
		var id = [tile.tile_width, tile.tile_height]
		if !data.has(id):
			data[id] = {}
		var type_name = get_type_name(tile.type)
		if !data[id].has(type_name):
			data[id][type_name] = {
				"multi"			: [],
				"individual"	: [],
			}
		if tile.animation.size() > 0:
			data[id][type_name]["multi"].append(tile)
		else:
			data[id][type_name]["individual"].append(tile)
	return data
	
func save_dialog_on_focus_changed():
	var focused = get_focus_owner()
	var focus_size = focused.rect_size.y
	var parent
	if focused.get_parent() is SpinBox:
		parent = focused.get_parent().get_parent()
	else:
		parent = focused.get_parent()
	var focus_top = focused.rect_position.y + parent.rect_position.y
	var scroll_size = save_dialog_container.rect_size.y
	var scroll_top = save_dialog_container.get_v_scroll()
	var scroll_bottom = scroll_top + scroll_size - focus_size - 60
	if focus_top < scroll_top:
		save_dialog_container.set_v_scroll(focus_top - 60)
	if focus_top > scroll_bottom:
		var scroll_offset = scroll_top + focus_top - scroll_bottom
		save_dialog_container.set_v_scroll(scroll_offset)
		
	focused.caret_position = focused.text.length()
	focused.select_all()
		
func save_dialog_on_focus_exited(last_focused):
	last_focused.deselect()
	if save_dialog.visible:
		yield(get_tree(), "idle_frame")
		var focused = get_focus_owner()
		if !focused is LineEdit:
			if save_dialog_container_vbox.get_child_count() != 0:
				var child = save_dialog_container_vbox.get_child(0)
				child.tilemap_name_lineEdit.grab_focus()
	
func delete_tilemap_in_save_dialog(id):
	var child = save_dialog_container_vbox.get_child(id)
	save_dialog_container_vbox.remove_child(child)
	child.queue_free()
	if save_dialog_container_vbox.get_child_count() == 0:
		hide_all_dialogs()
	else:
		# re-arrange ids
		for i in save_dialog_container_vbox.get_child_count():
			child = save_dialog_container_vbox.get_child(i)
			child.id = i
		


func _on_save_dialog_CloseButton_button_up() -> void:
	if save_dialog.visible and can_action:
		hide_all_dialogs()


func _on_SaveDialog_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(1):
		save_dialog.rect_position += event.relative


func _on_SaveDialog_visibility_changed() -> void:
	if !can_action: return
	if save_dialog.visible:
		if save_dialog_container_vbox.get_child_count() > 0:
			var child = save_dialog_container_vbox.get_child(0)
			child.select()
	else:
		for child in save_dialog_container_vbox.get_children():
			save_dialog_container_vbox.remove_child(child)
			child.queue_free()


func _on_save_dialog_tilemap_LineEdit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			can_action = false
			select_folder("tilemap")
			yield(file_dialog, "hide")
			show_dialog(save_dialog)
			yield(get_tree(), "idle_frame")
			can_action = true
			refresh_info_in_save_panels()
			
func refresh_info_in_save_panels():
	if save_dialog_container_vbox.get_child_count() > 0:
		var text = save_dialog_tilemap_path.text
		for child in save_dialog_container_vbox.get_children():
			child.set_tilemap_path(text)
			
func show_tooltip(child):
	if child.hint_tooltip != "":
		child.editor_description = child.hint_tooltip.lstrip(" ")
		child.hint_tooltip = ""
	tooltip.set_text(child.editor_description)
	tooltip.show()
	
func hide_tooltip(child, value = false):
	tooltip.hide(value)
	
func update_tooltip_position(event : InputEvent, child = null):
	if child.hint_tooltip != "":
		child.editor_description = child.hint_tooltip.lstrip(" ")
		child.hint_tooltip = ""
	if event is InputEventMouseMotion:
		tooltip.update_position()



func _on_fast_export_button_toggled(button_pressed: bool) -> void:
	var index = fast_export_button.selected
	if index == 0: return
	fast_export_button.select(0)
	fast_export_button.text = "Fast Export"
	var _config = get_export_configuration(index)
	
func get_export_configuration(index):
	var result = {}
	# rects = [x, y, columns, rows, type, animation_length, animation_direction]
	# animation_direction => 1: Left to Right, 2: Up to Down 
	if index <= 6 or index > 12:
		result.tile_width = 32
		result.tile_height = 32
	else:
		result.tile_width = 48
		result.tile_height = 48
	result.columns = 16
	var img = image_real.texture.get_data()
	var error = ""; var _w; var _h;
	match index:
		1, 7: # Tileset A1
			_w = 768 if index == 7 else 512
			_h = 576 if index == 7 else 384
			if img.get_width() != _w or img.get_height() != _h:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nA size of [color=#FF0000]%s[/color] x [color=#FF0000]%s[/color] was expected" % [_w, _h]
			result.tile_data = [
				[0,0,2,3,1,3,1],	[6,0,2,3,1,1,1],	[8,0,2,3,1,3,1],	[14,0,2,1,3,3,2],
				[0,3,2,3,1,3,1],	[6,3,2,3,1,1,1],	[8,3,2,3,1,3,1],	[14,3,2,1,3,3,2],
				[0,6,2,3,1,3,1],	[6,6,2,3,1,1,1],	[8,6,2,3,1,3,1],	[14,6,2,1,3,3,2],
				[0,9,2,3,1,3,1],	[6,9,2,3,1,1,1],	[8,9,2,3,1,3,1],	[14,9,2,1,3,3,2]
			]
			result.columns = 24
		2, 8: # Tileset A2
			_w = 768 if index == 8 else 512
			_h = 576 if index == 8 else 384
			if img.get_width() != _w or img.get_height() != _h:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nA size of [color=#FF0000]%s[/color] x [color=#FF0000]%s[/color] was expected" % [_w, _h]
			result.tile_data = [
				[0,0,2,3,1,1,1],	[2,0,2,3,1,1,1],	[4,0,2,3,1,1,1],	[6,0,2,3,1,1,1],	[8,0,2,3,1,1,1],	[10,0,2,3,1,1,1],	[12,0,2,3,1,1,1],	[14,0,2,3,1,1,1],
				[0,3,2,3,1,1,1],	[2,3,2,3,1,1,1],	[4,3,2,3,1,1,1],	[6,3,2,3,1,1,1],	[8,3,2,3,1,1,1],	[10,3,2,3,1,1,1],	[12,3,2,3,1,1,1],	[14,3,2,3,1,1,1],
				[0,6,2,3,1,1,1],	[2,6,2,3,1,1,1],	[4,6,2,3,1,1,1],	[6,6,2,3,1,1,1],	[8,6,2,3,1,1,1],	[10,6,2,3,1,1,1],	[12,6,2,3,1,1,1],	[14,6,2,3,1,1,1],
				[0,9,2,3,1,1,1],	[2,9,2,3,1,1,1],	[4,9,2,3,1,1,1],	[6,9,2,3,1,1,1],	[8,9,2,3,1,1,1],	[10,9,2,3,1,1,1],	[12,9,2,3,1,1,1],	[14,9,2,3,1,1,1]
			]
			result.columns = 48
		3, 9: # Tileset A3
			_w = 768 if index == 9 else 512
			_h = 384 if index == 9 else 256
			if img.get_width() != _w or img.get_height() != _h:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nA size of [color=#FF0000]%s[/color] x [color=#FF0000]%s[/color] was expected" % [_w, _h]
			result.tile_data = [
				[0,0,2,2,2,1,1],	[2,0,2,2,2,1,1],	[4,0,2,2,2,1,1],	[6,0,2,2,2,1,1],	[8,0,2,2,2,1,1],	[10,0,2,2,2,1,1],	[12,0,2,2,2,1,1],	[14,0,2,2,2,1,1],
				[0,2,2,2,2,1,1],	[2,2,2,2,2,1,1],	[4,2,2,2,2,1,1],	[6,2,2,2,2,1,1],	[8,2,2,2,2,1,1],	[10,2,2,2,2,1,1],	[12,2,2,2,2,1,1],	[14,2,2,2,2,1,1],
				[0,4,2,2,2,1,1],	[2,4,2,2,2,1,1],	[4,4,2,2,2,1,1],	[6,4,2,2,2,1,1],	[8,4,2,2,2,1,1],	[10,4,2,2,2,1,1],	[12,4,2,2,2,1,1],	[14,4,2,2,2,1,1],
				[0,6,2,2,2,1,1],	[2,6,2,2,2,1,1],	[4,6,2,2,2,1,1],	[6,6,2,2,2,1,1],	[8,6,2,2,2,1,1],	[10,6,2,2,2,1,1],	[12,6,2,2,2,1,1],	[14,6,2,2,2,1,1]
			]
			result.columns = 32
		4, 10: # Tileset A4
			_w = 768 if index == 10 else 512
			_h = 720 if index == 10 else 480
			if img.get_width() != _w or img.get_height() != _h:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nA size of [color=#FF0000]%s[/color] x [color=#FF0000]%s[/color] was expected" % [_w, _h]
			result.tile_data = [
				[0,0,2,3,1,1,1],	[2,0,2,3,1,1,1],	[4,0,2,3,1,1,1],	[6,0,2,3,1,1,1],	[8,0,2,3,1,1,1],	[10,0,2,3,1,1,1],	[12,0,2,3,1,1,1],	[14,0,2,3,1,1,1],
				[0,3,2,2,2,1,1],	[2,3,2,2,2,1,1],	[4,3,2,2,2,1,1],	[6,3,2,2,2,1,1],	[8,3,2,2,2,1,1],	[10,3,2,2,2,1,1],	[12,3,2,2,2,1,1],	[14,3,2,2,2,1,1],
				[0,5,2,3,1,1,1],	[2,5,2,3,1,1,1],	[4,5,2,3,1,1,1],	[6,5,2,3,1,1,1],	[8,5,2,3,1,1,1],	[10,5,2,3,1,1,1],	[12,5,2,3,1,1,1],	[14,5,2,3,1,1,1],
				[0,8,2,2,2,1,1],	[2,8,2,2,2,1,1],	[4,8,2,2,2,1,1],	[6,8,2,2,2,1,1],	[8,8,2,2,2,1,1],	[10,8,2,2,2,1,1],	[12,8,2,2,2,1,1],	[14,8,2,2,2,1,1],
				[0,10,2,3,1,1,1],	[2,10,2,3,1,1,1],	[4,10,2,3,1,1,1],	[6,10,2,3,1,1,1],	[8,10,2,3,1,1,1],	[10,10,2,3,1,1,1],	[12,10,2,3,1,1,1],	[14,10,2,3,1,1,1],
				[0,13,2,2,2,1,1],	[2,13,2,2,2,1,1],	[4,13,2,2,2,1,1],	[6,13,2,2,2,1,1],	[8,13,2,2,2,1,1],	[10,13,2,2,2,1,1],	[12,13,2,2,2,1,1],	[14,13,2,2,2,1,1]
			]
			result.columns = 16
		5, 11: # Tileset A5
			_w = 384 if index == 11 else 256
			_h = 768 if index == 11 else 512
			if img.get_width() != _w or img.get_height() != _h:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nA size of [color=#FF0000]%s[/color] x [color=#FF0000]%s[/color] was expected" % [_w, _h]
			result.tile_data = []
			for y in 16:
				for x in 8:
					result.tile_data.append([x, y, 1, 1, -1, 1, 1])
			result.columns = 4
		6, 12: # Tilesets B-E
			_w = 768 if index == 12 else 512
			_h = 768 if index == 12 else 512
			if img.get_width() != _w or img.get_height() != _h:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nA size of [color=#FF0000]%s[/color] x [color=#FF0000]%s[/color] was expected" % [_w, _h]
			result.tile_data = []
			for y in 16:
				for x in 16:
					result.tile_data.append([x, y, 1, 1, -1, 1, 1])
			result.columns = 4
		13: # Tileset XP
			if img.get_width() % 32 != 0 or img.get_height() % 32 != 0:
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nAn image with width and height divisible by [color=#FF0000]32[/color] was expected"
			result.columns = 8
			result.tile_data = []
			for y in img.get_height() / 32:
				for x in img.get_width() / 32:
					result.tile_data.append([x, y, 1, 1, -1, 1, 1])
		14: # Autotile XP without animation
			if (img.get_width() != 96 or img.get_height() != 128):
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nAn image of [color=#FF0000]96[/color] x [color=#FF0000]128[/color] was expected"
			result.columns = 8
			result.tile_data = [ [0, 0, 3, 4, 0, 1, 1] ]
		15: # Autotile XP animated
			if (img.get_width() != 384 or img.get_height() != 128):
				error = "[color=#3263de]Error[/color]: image size does not\nmatch with the preset"
				error += "\nAn image of [color=#FF0000]384[/color] x [color=#FF0000]128[/color] was expected"
			result.columns = 32
			result.tile_data = [ [0, 0, 3, 4, 0, 4, 1] ]
			
	if error != "":
		error = "[center]%s[/center]" % error
		error2_dialog_label.bbcode_text = error
		show_dialog(error2_dialog)
		return
			
	result.tiles = []
	var tile_id = 1
	for data in result.tile_data:
		var new_autotile = Autotile.new()
		new_autotile.type = data[4]
		#var text = get_type_name(data[4]).replace(" - ", "")
		new_autotile.name = get_type_name(new_autotile.type) + str(tile_id)
		new_autotile.path = data_images[image_list.get_selected_items()[0]].path
		var x = data[0] * result.tile_width
		var y = data[1] * result.tile_height
		var w = data[2] * result.tile_width
		var h = data[3] * result.tile_height
		new_autotile.rect = Rect2(Vector2(x, y), Vector2(w, h))
		new_autotile.tile_width = result.tile_width
		new_autotile.tile_height = result.tile_height
		if data[5] > 1:
			var animation_tiles = []
			var rect = new_autotile.rect
			for i in data[5]:
				var sub_tile = new_autotile.duplicate()
				sub_tile.rect = rect
				if data[6] == 1:
					rect.position.x += rect.size.x
				else:
					rect.position.y += rect.size.y
				animation_tiles.append(sub_tile)
			new_autotile.animation = animation_tiles
		result.tiles.append(new_autotile)
		tile_id += 1
		
	var data = get_data_struct(result.tiles).values()[0]
		
	var panel = save_panel_scene.instance()
	panel.id = 0
	panel.connect("deleted", self, "delete_tilemap_in_save_dialog")
	panel.connect("show_ultimate_revision_dialog_request",
			self, "show_ultimate_revision_dialog")
	save_dialog_container_vbox.add_child(panel)
	var lineedit = panel.columns_spinBox.get_line_edit()
	lineedit.connect('focus_entered', self,
		'save_dialog_on_focus_changed')
	lineedit.connect('focus_exited', self,
		'save_dialog_on_focus_exited', [lineedit])
	panel.tilemap_name_lineEdit.connect('focus_entered', self,
		'save_dialog_on_focus_changed')
	panel.tilemap_name_lineEdit.connect('focus_exited', self,
		'save_dialog_on_focus_exited', [panel.tilemap_name_lineEdit])
	panel.tileset_name_lineEdit.connect('focus_entered', self,
		'save_dialog_on_focus_changed')
	panel.tileset_name_lineEdit.connect('focus_exited', self,
		'save_dialog_on_focus_exited', [panel.tileset_name_lineEdit])
	var data2 = {
		"tile_width"		: result.tile_width,
		"tile_height"		: result.tile_height,
		"autotile_path"		: autotiles_lineEdit.text,
		"tileset_path"		: tileset_lineEdit.text,
		"tilemap_path"		: save_dialog_tilemap_path.text,
		"tiles"				: data,
	}
	var file_name = "Fast Export"
	panel.set_initial_values(
		file_name,
		get_fix_name_for_paths(file_name),
		get_fix_name_for_paths(file_name),
		result.columns,
		data2
	)
	update_style_for_input_and_text_boxes(panel)
	# Show save dialog
	show_dialog(save_dialog)


func _on_save_dialog_save_Button_button_up() -> void:
	if !save_dialog.visible: return
	# Show saving animation...
	saving_animation.visible = true
	for i in 6:
		yield(get_tree(), "idle_frame")
	save_all()
	# vvvvvvvvvvvvvvvvvvvvvvv does not works :(
	#thread = Thread.new()
	#thread.start(self, "save_all", save_dialog_container_vbox.get_children())
	#yield(self, "save_completed")
	#hide_all_dialogs()


func save_all(user_data = null) -> void:
	# Get the save panels with all necesary info to save data
	var save_panels
	if user_data is Array:
		save_panels = user_data
	else:
		save_panels = save_dialog_container_vbox.get_children()
	var dir = Directory.new()
	var image_data = []
	for panel in save_panels:
		var panel_data = panel.get_values()
		# Check if the destination folder exists, if not, create it
		if !dir.dir_exists(panel_data.data.autotile_path +
				panel_data.tilemap_name + "/"):
			dir.make_dir_recursive(panel_data.data.autotile_path +
				panel_data.tilemap_name + "/")
		if !dir.dir_exists(panel_data.data.tilemap_path):
			dir.make_dir_recursive(panel_data.data.tilemap_path)
		if !dir.dir_exists(panel_data.data.tileset_path):
			dir.make_dir_recursive(panel_data.data.tileset_path)
		# get all tile images with right names to save it
		var autotile_path = (panel_data.data.autotile_path +
			panel_data.tilemap_name + "/")
		var keys = ["floor - ", "wall - ", "waterfall - ", "single - "]
		var tile_images = []
		for key in keys:
			tile_images.append(get_image_for_tiles(panel_data.data.tiles, key))
		# if panel single_image is true, merge all tiles in a single image
		# else, create individual files for each image
		var data_rects = {} # Save info here to create tileset
		if panel_data.single_image:
			# merge all tiles in a single image
			# get tile size and desired_max_width
			var tile_width = panel_data.tile_width
			var tile_height = panel_data.tile_height
			var columns = panel_data.columns
			var desired_width = tile_height * columns
			# get image size
			var x = 0; var y = 0;
			var max_width = 0; var max_height = 0; var height = 0;
			var ids = []
			for arr in tile_images:
				for im_data in arr:
					if !ids.has(im_data.id):
						ids.append(im_data.id)
					else:
						continue
					if im_data.img is Array:
						for im in im_data.img:
							x += im.get_width()
							height = max(height, im.get_height())
							if x >= desired_width:
								max_width = max(x, max_width)
								x = 0
								max_height += height
								height = 0
							max_width = max(max_width, x)
							if max_height == 0:
								max_height = im.get_height()
					else:
						x += im_data.img.get_width()
						height = max(height, im_data.img.get_height())
						if x >= desired_width:
							max_width = x
							x = 0
							max_height += height
							height = 0
						max_width = max(max_width, x)
						if max_height == 0:
							max_height = im_data.img.get_height()
			var size = Vector2.ZERO
			size.x = max_width
			size.y = max_height
			# fill image and save
			var img = Image.new()
			img.create(min(Image.MAX_WIDTH, size.x*2),
				min(Image.MAX_HEIGHT, size.y*2), false, Image.FORMAT_RGBA8)
			var matrix_data = [] # Control where the tiles are drawn
			for i in size.y / tile_height:
				matrix_data.append([])
				for j in size.x / tile_width:
					matrix_data[-1].append(0)
			x = 0; y = 0;
			height = 0
			var path = get_final_file_name(panel_data.tileset_name, ".png",
				autotile_path)
			for arr in tile_images:
				yield(get_tree(), "idle_frame")
				for im_data in arr:
					if !data_rects.has(im_data.id):
						data_rects[im_data.id] = {}
					else:
						continue
					if im_data.img is Array:
						data_rects[im_data.id].rect = []
						data_rects[im_data.id].animation_delay = im_data.animation_delay
						for im in im_data.img:
							var src_rect = Rect2(Vector2.ZERO,
								im.get_size())
							var dest = Vector2(x, y)
							dest = get_empty_space_position(
								matrix_data,
								im.get_size(),
								Vector2(tile_width, tile_height)
							)
							data_rects[im_data.id].name = im_data.name
							data_rects[im_data.id].type = im_data.type
							data_rects[im_data.id].path = path
							data_rects[im_data.id].rect.append(Rect2(
								dest, src_rect.size))
							data_rects[im_data.id].animation_delay = im_data.animation_delay
							data_rects[im_data.id].collision_type = im_data.collision_type
							data_rects[im_data.id].occlusion = im_data.occlusion
							data_rects[im_data.id].tile_size = Vector2(tile_width, tile_height)
							data_rects[im_data.id].collision_percent = im_data.collision_percent
							img.blit_rect(im, src_rect, dest)
							height = max(height, im.get_height())
							x += im.get_width()
							if x >= size.x:
								x = 0
								y += height
								height = 0
					else:
						var src_rect = Rect2(Vector2.ZERO,
								im_data.img.get_size())
						var dest = Vector2(x, y)
						dest = get_empty_space_position(
							matrix_data,
							im_data.img.get_size(),
							Vector2(tile_width, tile_height)
						)
						data_rects[im_data.id].name = im_data.name
						data_rects[im_data.id].type = im_data.type
						data_rects[im_data.id].path = path
						data_rects[im_data.id].rect = Rect2(
							dest, src_rect.size)
						data_rects[im_data.id].animation_delay = im_data.animation_delay
						data_rects[im_data.id].collision_type = im_data.collision_type
						data_rects[im_data.id].occlusion = im_data.occlusion
						data_rects[im_data.id].tile_size = Vector2(tile_width, tile_height)
						data_rects[im_data.id].collision_percent = im_data.collision_percent
						img.blit_rect(im_data.img, src_rect, dest)
						height = max(height, im_data.img.get_height())
						x += im_data.img.get_width()
						if x >= size.x:
							x = 0
							y += height
							height = 0
			# Crop image (Cut transparent pixels)
			var mw = 0; var mh = 0;
			for obj in data_rects.values():
				var rect = obj.rect
				if rect is Rect2:
					mw = max(mw, rect.position.x + rect.size.x)
					mh = max(mh, rect.position.y + rect.size.y)
				else:
					for r in rect:
						mw = max(mw, r.position.x + r.size.x)
						mh = max(mh, r.position.y + r.size.y)
			if img.get_width() != mw or img.get_height() != mh:
				img.crop(mw, mh)
			# save image (all tiles merged in a single image)
			if panel_data.compression != 0:
				img.compress(0, 0, panel_data.compression)
			img.save_png(path)
		else:
			# Save individual images
			var tile_width = panel_data.tile_width
			var tile_height = panel_data.tile_height
			for arr in tile_images:
				yield(get_tree(), "idle_frame")
				for img_data in arr:
					if !data_rects.has(img_data.id):
						data_rects[img_data.id] = {}
					else:
						continue
					var path = get_final_file_name(img_data.name, ".png",
						autotile_path)
					img_data.path = path
					if img_data.img is Array:
						var img = Image.new()
						var w = img_data.img[0].get_width()
						var h = img_data.img[0].get_height()
						img.create(w * img_data.img.size(), h,
							false, Image.FORMAT_RGBA8)
						var src_rect = Rect2(Vector2.ZERO, Vector2(w, h))
						var x = 0
						data_rects[img_data.id].rect = []
						for im in img_data.img:
							var dest = Vector2(x, 0)
							img.blit_rect(im, src_rect, dest)
							data_rects[img_data.id].rect.append(Rect2(
								dest, src_rect.size))
							x += w
						print(data_rects[img_data.id].rect)
						if panel_data.compression != 0:
							img.compress(0, 0, panel_data.compression)
						img.save_png(img_data.path)
						data_rects[img_data.id].name = img_data.name
						data_rects[img_data.id].type = img_data.type
						data_rects[img_data.id].path = img_data.path
						data_rects[img_data.id].collision_type = img_data.collision_type
						data_rects[img_data.id].occlusion = img_data.occlusion
						data_rects[img_data.id].tile_size = Vector2(tile_width, tile_height)
						data_rects[img_data.id].collision_percent = img_data.collision_percent
						data_rects[img_data.id].animation_delay = img_data.animation_delay
					else:
						if panel_data.compression != 0:
							img_data.img.compress(0, 0, panel_data.compression)
						img_data.img.save_png(img_data.path)
						data_rects[img_data.id].name = img_data.name
						data_rects[img_data.id].type = img_data.type
						data_rects[img_data.id].path = img_data.path
						data_rects[img_data.id].rect = Rect2(
							Vector2.ZERO, img_data.img.get_size())
						data_rects[img_data.id].collision_type = img_data.collision_type
						data_rects[img_data.id].occlusion = img_data.occlusion
						data_rects[img_data.id].tile_size = Vector2(tile_width, tile_height)
						data_rects[img_data.id].collision_percent = img_data.collision_percent
						data_rects[img_data.id].animation_delay = img_data.animation_delay
		# Create tileset:
		var tileset_str = save_files.tileset
		var tile_id = 0
		var resource_id = 0
		var ids = data_rects.keys() # Preserve order of data
		var paths = {} # Void duplicates
		var resource_body = "" # save the text of the resource body tag in tileset_str
		var header = "" # save the text of the resource header tag in tileset_str
		for id in ids:
			var rect = data_rects[id]
			var text = ""
			if !paths.has(rect.path):
				paths[rect.path] = tile_id
				text = save_files.tileset_header
				text = text.replace("#PATH#", rect.path)
				text = text.replace("#RESOURCE_ID#", tile_id)
				header += text + "\n"
			if rect.type == 0 or rect.type == 1: # floor autotile
				text = save_files.floor
			elif rect.type == 2: # wall autotile
				text = save_files.wall
			elif rect.type == 3: # waterfall autotile
				text = save_files.waterfall
			elif rect.type == -1: # single tile
				text = save_files.single_tile
			var tile_id_str = get_id_formatted(tile_id, ids.size())
			text = text.replace("#TILE_NAME#", "%s - %s" % [tile_id_str, rect.name])
			text = text.replace("#RESOURCE_ID#", paths[rect.path])
			var r
			if rect.rect is Array:
				r = rect.rect[0]
			else:
				r = rect.rect
			if rect.occlusion:
				var pol
				if rect.type == -1:
					pol = str(_create_collision_polygon(rect.path, r))
				else:
					pol = str(_create_simple_collision_polygon(rect.tile_size))
				pol = pol.replace("[", "")
				pol = pol.replace("]", "")
				pol = pol.replace("(", "")
				pol = pol.replace(")", "")
				header += "[sub_resource type=\"OccluderPolygon2D\" id=%s]\n" % \
					resource_id
				header += "polygon = PoolVector2Array( %s )\n\n" % pol
				var new_text = ""
				if rect.type == -1:
					 new_text = "#TILE_ID#/occluder = SubResource( %s )" % resource_id
				else:
					for y in r.size.y / rect.tile_size.y:
						for x in r.size.x / rect.tile_size.x:
							if new_text != "": new_text += ", "
							new_text += "Vector2( %s, %s), " % \
								[x, y]
							new_text += "SubResource( %s )" % str(resource_id)
					new_text = "#TILE_ID#/autotile/occluder_map = [ %s ]\n" % new_text
				text = text.replace("#OCCLUDER#", new_text)
				resource_id += 1
			else:
				text = text.replace("#OCCLUDER#\n", "")
			if rect.collision_type == 0: # NO COLLISION
				text = text.replace("#SHAPEEXTENDES#", "")
				text = text.replace("#SHAPE#\n", "")
			elif rect.collision_type == 1 or rect.type != -1:
				var pol
				if rect.type == -1:
					pol = str(_create_simple_collision_polygon(rect.rect.size,
						rect.collision_percent))
				else:
					pol = str(_create_simple_collision_polygon(rect.tile_size,
						rect.collision_percent))
				pol = pol.replace("[", "")
				pol = pol.replace("]", "")
				pol = pol.replace("(", "")
				pol = pol.replace(")", "")
				header += "[sub_resource type=\"ConvexPolygonShape2D\" id=%s]\n" % \
					resource_id
				header += "points = PoolVector2Array( %s )\n\n" % pol
				if rect.type == -1:
					var new_text = save_files.single_shape
					new_text = new_text.replace("#TILE_ID#", str(resource_id))
					text = text.replace("#SHAPEEXTENDES#", new_text)
					new_text = "#TILE_ID#/shape = SubResource( %s )" % str(resource_id)
					text = text.replace("#SHAPE#", new_text)
				else:
					var new_text = ""
					for y in r.size.y / rect.tile_size.y:
						for x in r.size.x / rect.tile_size.x:
							var t = save_files.single_shape
							var v = "Vector2( %s, %s )" % [x, y]
							t = t.replace("Vector2( 0, 0 )", v)
							if new_text != "": new_text += ",\n"
							new_text += t
					new_text = new_text.replace("#TILE_ID#", str(resource_id))
					text = text.replace("#SHAPEEXTENDES#", new_text)
					new_text = "#TILE_ID#/shape = SubResource( %s )" % str(resource_id)
					text = text.replace("#SHAPE#", new_text)
				resource_id += 1
			else:
				var pol = str(_create_collision_polygon(rect.path, r))
				pol = pol.replace("[", "")
				pol = pol.replace("]", "")
				pol = pol.replace("(", "")
				pol = pol.replace(")", "")
				header += "[sub_resource type=\"ConvexPolygonShape2D\" id=%s]\n" % \
					resource_id
				header += "points = PoolVector2Array( %s )\n\n" % pol
				var new_text = save_files.single_shape
				new_text = new_text.replace("#TILE_ID#", str(resource_id))
				text = text.replace("#SHAPEEXTENDES#", new_text)
				new_text = "#TILE_ID#/shape = SubResource( %s )" % str(resource_id)
				text = text.replace("#SHAPE#", new_text)
				resource_id += 1
			text = text.replace("#TILE_ID#", tile_id)
			if rect.rect is Rect2:
				text = text.replace("#RECT#", "Rect2" + str(rect.rect))
			else:
				# Animate tile, use rect[0]
				text = text.replace("#RECT#", "Rect2" + str(rect.rect[0]))
			if rect.type != -1:
				text = text.replace("#TILE_SIZE#", "Vector2" +
					str(Vector2(panel_data.tile_width, panel_data.tile_height)))
			resource_body += text
			tile_id += 1
			
		tileset_str = tileset_str.replace("#RESOURCE_HEADER#", header)
		tileset_str = tileset_str.replace("#RESOURCE_BODY#", resource_body)
		# save tileset
		var path = get_final_file_name(panel_data.tileset_name, ".tres",
			panel_data.data.tileset_path)
		save_file_text(path, tileset_str)
		# create tilemap
		var tilemap_str = save_files.tilemap
		tilemap_str = tilemap_str.replace("#TILESET_PATH#", path)
		tilemap_str = tilemap_str.replace("#TILE_SIZE#", "Vector2" +
			str(Vector2(panel_data.tile_width, panel_data.tile_height)))
		var animation_data = ""
		tile_id = 0
		for id in ids:
			var rect = data_rects[id]
			if rect.rect is Array:
				animation_data += "\t\\\"Tile %s\\\":\n\t\t{\n" % tile_id
				animation_data += "\t\t\t\\\"frame\\\"\t: 0,\n"
				animation_data += "\t\t\t\\\"delay\\\"\t: %s,\n" % rect.animation_delay
				animation_data += "\t\t\t\\\"time\\\"\t: 0,\n"
				animation_data += "\t\t\t\\\"animation_rects\\\":\n\t\t\t\t[\n"
				for i in rect.rect.size():
					var r = rect.rect[i]
					if i < rect.rect.size() - 1:
						animation_data += "\t\t\t\t\tRect2%s,\n" % str(r)
					else:
						animation_data += "\t\t\t\t\tRect2%s\n" % str(r)
				animation_data += "\t\t\t\t],\n\t\t},\n"
			tile_id += 1
		tilemap_str = tilemap_str.replace("#ANIMATIONS_DATA#", animation_data)
		# save tilemap
		path = get_final_file_name(panel_data.tilemap_name, ".tscn",
			panel_data.data.tilemap_path)
		save_file_text(path, tilemap_str)
		emit_signal("save_completed")
		#hide_all_dialogs()
		print("Saved!")
					

func _create_collision_polygon(path : String, src_rect: Rect2) -> Array:
	var tex = load_external_texture(path)
	var img = Image.new()
	img.create(src_rect.size.x, src_rect.size.y, false, tex.get_data().get_format())
	img.blit_rect(tex.get_data(), src_rect, Vector2.ZERO)
	tex = ImageTexture.new()
	tex.create_from_image(img)
	var bm = BitMap.new()
	bm.create_from_image_alpha(tex.get_data())
	var rect = Rect2(0, 0, tex.get_data().get_width(), tex.get_data().get_height())
	var my_array = bm.opaque_to_polygons(rect)
	return my_array
	
func _create_simple_collision_polygon(size : Vector2, percent : int = 100) -> Array:
	var mod = size.y * (percent / 100.0)
	var y = size.y - mod
	var my_array = [
		Vector2(0, y),
		Vector2(size.x, y),
		Vector2(size.x, size.y),
		Vector2(0, size.y)
	]
	return my_array



func get_id_formatted(_id : int, _size : int) -> String:
	var result = ""
	var zeros = str(_size).length() - str(_id).length()
	for i in range(0, zeros):
		result += "0"
	result += str(_id)
	return result
	


func save_file_text(path : String, content : String) -> void:
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(content)
	file.close()
	

func get_empty_space_position(matrix : Array,
	size : Vector2, tile_size : Vector2) -> Vector2:
	var cells = size / tile_size
	
	for y1 in matrix.size():
		for x1 in matrix[y1].size():
			var busy = false
			for y2 in range(y1, min(y1 + cells.y, matrix.size())):
				for x2 in range(x1, min(x1 + cells.x, matrix[y1].size())):
					if matrix[y2][x2] == 1:
						busy = true
						break
				if busy: break
			if !busy:
				for y2 in range(y1, min(y1 + cells.y, matrix.size())):
					for x2 in range(x1, min(x1 + cells.x, matrix[y1].size())):
						matrix[y2][x2] = 1
				return Vector2(x1 * tile_size.x, y1 * tile_size.y)

	return Vector2.ZERO


func get_image_for_tiles(data_tiles : Dictionary, key : String) -> Array:
	var result = []
	if data_tiles.has(key):
		if data_tiles[key].multi.size() > 0:
			for tile in data_tiles[key].multi:
				result.append({
					"id"				: tile.get_id(),
					"name"				: tile.name,
					"type"				: tile.type,
					"img"				: get_img_for_tile(tile),
					"tile_width"		: tile.tile_width,
					"tile_height"		: tile.tile_height,
					"animation_delay"	: tile.animation_delay,
					"collision_type"	: tile.collision_type,
					"occlusion"			: tile.occlusion,
					"collision_percent"	: tile.collision_percent,
				})
		if data_tiles[key].individual.size() > 0:
			for tile in data_tiles[key].individual:
				result.append({
					"id"				: tile.get_id(),
					"name"				: tile.name,
					"type"				: tile.type,
					"img"				: get_img_for_tile(tile),
					"tile_width"		: tile.tile_width,
					"tile_height"		: tile.tile_height,
					"animation_delay"	: tile.animation_delay,
					"collision_type"	: tile.collision_type,
					"occlusion"			: tile.occlusion,
					"collision_percent"	: tile.collision_percent,
				})
	return result
	
func get_img_for_tile(tile):
	var result = []
	if tile.animation.size() > 0:
		for sub_tile in tile.animation:
			result.append(get_tile(sub_tile))
	else:
		result.append(get_tile(tile))
	if result.size() == 1:
		return result[0]
	else:
		return result
		
func get_final_file_name(file_name, ext, path):
	var file = File.new()
	var n = 2
	var regex = RegEx.new()
	regex.compile("(.*_)(\\d+)$")
	while file.file_exists(path + file_name + ext):
		var result = regex.search(file_name)
		if result:
			n = int(result.get_strings()[2]) + 1
			file_name = "%s%s" % [result.get_strings()[1], n]
		else:
			file_name = "%s_%s" % [file_name, n]
			n += 1
	return (path + file_name + ext)


func _process(delta: float) -> void:
	if final_zoom != image_real.rect_scale:
		var zoom = image_real.rect_scale.move_toward(final_zoom,
			zoom_timer * delta) - image_real.rect_scale
		change_zoom(zoom)
#		image_real.rect_scale = image_real.rect_scale.move_toward(final_zoom,
#			zoom_timer * delta)
		zoom_timer += 1
		if image_real.rect_scale.distance_to(final_zoom) < 0.001:
			#image_real.rect_scale = final_zoom
			zoom_timer = 10
			


func _on_CreateAutoTile_tree_exiting() -> void:
	if thread != null:
		thread.wait_to_finish()
	# Save config
	var file = File.new()
	var path = "user://create_autotile_config.dat"
	file.open(path, file.WRITE)
	var config = {}
	config.preset = preset_button.get_selected_id()
	config.autotiles_path = autotiles_lineEdit.text
	config.tilesets_paths = tileset_lineEdit.text
	config.tilemaps_path = save_dialog_tilemap_path.text
	file.store_string(to_json(config))
	file.close()


func _on_create_autotile_dialog_ok_button_focus_exited() -> void:
	if create_autotile_dialog.visible:
		yield(get_tree(), "idle_frame")
		create_autotile_dialog_t.grab_focus()
		
func _unhandled_key_input(event: InputEventKey) -> void:
	if (hide_behind.visible and event is InputEventKey and
		event.is_pressed() and event.scancode == KEY_ESCAPE):
			if !save_dialog.visible and !file_dialog.visible:
				hide_all_dialogs()


func _on_create_autotile_OptionButton_item_selected(index: int) -> void:
	if index == 1:
		create_autotile_dialog_s.editable = true
		var lineedit = create_autotile_dialog_s.get_line_edit()
		lineedit.caret_position = lineedit.text.length()
		lineedit.select_all()
		yield(get_tree(), "idle_frame")
		lineedit.grab_focus()
	else:
		create_autotile_dialog_s.editable = false


func _on_edit_autotile_OptionButton_item_selected(index: int) -> void:
	if index == 1:
		percent_autotile_dialog_b.editable = true
		var lineedit = percent_autotile_dialog_b.get_line_edit()
		lineedit.caret_position = lineedit.text.length()
		lineedit.select_all()
		yield(get_tree(), "idle_frame")
		lineedit.grab_focus()
	else:
		percent_autotile_dialog_b.editable = false
		
func show_ultimate_revision_dialog(tiles):
	ultimate_dialog_itemlist.clear()
	var data; var data2;
	for key in tiles:
		data = tiles[key]
		for key2 in data:
			data2 = data[key2]
			for tile in data2:
				ultimate_tiles.append(tile)
				ultimate_dialog_itemlist.add_item(tile.name)
	if ultimate_dialog_itemlist.get_item_count() != 0:
		ultimate_dialog_itemlist.select(0)
		update_ultimate_autotile_preview(0)
	ultimate_dialog_layer.visible = true
	ultimate_dialog.show()


func update_ultimate_autotile_preview(index: int) -> void:
	no_action = true
	if ultimate_last_tile != index and ultimate_last_tile != null:
		var autotile = ultimate_tiles[ultimate_last_tile]
		ultimate_dialog_percent.apply()
		autotile.collision_type = ultimate_dialog_collision.get_selected_id()
		autotile.collision_percent = ultimate_dialog_percent.value
		autotile.occlusion = ultimate_dialog_occlusion.pressed
	var autotile = ultimate_tiles[index]
	var result_image = get_tile(autotile)
	ultimate_dialog_preview_t.texture = load_external_texture(result_image)
	ultimate_dialog_collision.select(autotile.collision_type)
	ultimate_dialog_percent.value = autotile.collision_percent
	ultimate_dialog_occlusion.pressed = autotile.occlusion
	ultimate_dialog_percent.editable = autotile.collision_type == 1
	ultimate_last_tile = index
	no_action = false


func _on_ultimate_percent_SpinBox_value_changed(value: float) -> void:
	if no_action: return
	var index = ultimate_dialog_itemlist.get_selected_items()[0]
	var autotile = ultimate_tiles[index]
	autotile.collision_percent = value

func _on_ultimate_occlusion_CheckButton_toggled(button_pressed: bool) -> void:
	if no_action: return
	var index = ultimate_dialog_itemlist.get_selected_items()[0]
	var autotile = ultimate_tiles[index]
	autotile.occlusion = button_pressed


func _on_ultimate_collision_type_OptionButton_item_selected(collision_type : int) -> void:
	if no_action: return
	var index = ultimate_dialog_itemlist.get_selected_items()[0]
	var autotile = ultimate_tiles[index]
	autotile.occlusion = collision_type
	ultimate_dialog_percent.editable = collision_type == 1


func _on_ultimate_revision_dialog_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and \
		event.is_pressed():
		ultimate_dialog.hide()


func _on_ultimate_WindowDialog_hide() -> void:
	if !ultimate_dialog_itemlist: return
	if ultimate_last_tile != null:
		update_ultimate_autotile_preview(ultimate_last_tile)
	ultimate_tiles.clear()
	ultimate_dialog_itemlist.clear()
	ultimate_dialog_layer.visible = false


func _on_ultimate_close_button_down() -> void:
	ultimate_dialog.hide()

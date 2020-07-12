tool
extends Control


export(Texture) var pattern setget update_image
export(String, "Horizontal", "Vertical") var scrollbar_design = null setget change_design

var pattern_rects = {
	"background_normal"			: Rect2(Vector2(0, 0), Vector2(28, 31)),
	"top_normal"				: Rect2(Vector2(3, 31), Vector2(23, 24)),
	"decoration_hor_normal"		: Rect2(Vector2(52, 58), Vector2(16, 10)),
	"decoration_ver_normal"		: Rect2(Vector2(58, 41), Vector2(10, 16)),
	"background_over"			: Rect2(Vector2(28, 0), Vector2(28, 31)),
	"top_over"					: Rect2(Vector2(31, 31), Vector2(23, 24)),
	"shadow"					: Rect2(Vector2(56, 0), Vector2(28, 40)),
	"decoration_hor_over"		: Rect2(Vector2(68, 58), Vector2(16, 10)),
	"decoration_ver_over"		: Rect2(Vector2(74, 41), Vector2(10, 16)),
	"background_corners"		: [10, 11, 10, 11],
	"top_corners"				: [8, 8, 8, 8],

}

var background
var background_texture
var background_shadow
var top
var top_texture
var top_shadow
var top_decoration

var drag = false
var background_drag = false

var data = {
	"min_scroll" 				: Vector2(2, 2),
	"max_scroll"				: Vector2.ZERO,
	"target_min_scroll"			: Vector2.ZERO,
	"target_max_scroll"			: Vector2.ZERO,
	"target_rect_size"			: Vector2.ZERO,
}

var need_refresh = false
var need_change_position = false
var can_auto_change_position = false
var initializing = true

signal scroll(offset)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !is_connected("item_rect_changed", self, "_on_item_rect_changed"):
		connect("item_rect_changed", self, "_on_item_rect_changed")
	set_initial_variables()
	create_input_maps()
	set_min_size()
	set_images()
	set_target(Vector2.ZERO)
	set_process(true)
	
func create_input_maps():
	var action_name = "MouseLeft"
	if !InputMap.has_action(action_name):
		create_input(action_name, [BUTTON_LEFT], false, false, false)
	action_name = "MouseWheelUp"
	if !InputMap.has_action(action_name):
		create_input(action_name, [BUTTON_WHEEL_UP], false, false, false)
	action_name = "MouseWheelDown"
	if !InputMap.has_action(action_name):
		create_input(action_name, [BUTTON_WHEEL_DOWN], false, false, false)
		
func create_input(action_name, keys, _shift = false, _control = false, _alt = false):
	InputMap.add_action(action_name)
	var event;
	for key in keys:
		if key < 10 or key == 128 or key == 256:
			event = InputEventMouseButton.new()
			event.button_index = key
		else:
			event = InputEventKey.new()
			event.scancode = key
			event.shift = _shift
			event.control = _control
			event.alt = _alt
		InputMap.action_add_event(action_name, event)
	

func set_min_size():
	if scrollbar_design == "Horizontal":
		rect_min_size = Vector2(100, 30)
	else:
		rect_min_size = Vector2(30, 100)
		
func set_initial_variables():
	if !has_node("background"): return
	background 					= $background
	background_texture			= $background/texture
	background_shadow			= $background/shadow
	top 						= $top
	top_texture					= $top/texture
	top_shadow					= $top/shadow
	top_decoration				= $top/decoration
	
func set_target(value):
	data.target_rect_size = value
	var s = rect_size - Vector2(4, 4)
	data.target_max_scroll = Vector2()
	data.target_max_scroll.x = max(0, value.x - s.x)
	data.target_max_scroll.y = max(0, value.y - s.y)
	set_top(false)
	fix_top_position()
	emit_signal("scroll", get_displacement())
	
func set_images(set_initial_position = false):
	if !pattern: return
	
	if !background_shadow:
		set_initial_variables()
	set_background()
	set_top(set_initial_position)
	# Save max scroll
	data.max_scroll = rect_size - top.rect_size - Vector2(2, 2)
	
func set_background():
	if !background_shadow: return
	# Background shadow texture
	background_shadow.texture = pattern
	background_shadow.region_rect = pattern_rects.shadow
	background_shadow.patch_margin_left = pattern_rects.background_corners[0]
	background_shadow.patch_margin_top = pattern_rects.background_corners[1]
	background_shadow.patch_margin_right = pattern_rects.background_corners[2]
	background_shadow.patch_margin_bottom = pattern_rects.background_corners[3]
	# Background texture
	background_texture.texture = pattern
	background_texture.region_rect = pattern_rects.background_normal
	background_texture.patch_margin_left = pattern_rects.background_corners[0]
	background_texture.patch_margin_top = pattern_rects.background_corners[1]
	background_texture.patch_margin_right = pattern_rects.background_corners[2]
	background_texture.patch_margin_bottom = pattern_rects.background_corners[3]
		
func set_top(set_initial_position):
	if !background_shadow: return
	# Top shadow texture
	top_shadow.texture = pattern
	top_shadow.region_rect = pattern_rects.shadow
	top_shadow.patch_margin_left = pattern_rects.background_corners[0]
	top_shadow.patch_margin_top = pattern_rects.background_corners[1]
	top_shadow.patch_margin_right = pattern_rects.background_corners[2]
	top_shadow.patch_margin_bottom = pattern_rects.background_corners[3]
	# Top texture
	top_texture.texture = pattern
	top_texture.region_rect = pattern_rects.top_normal
	top_texture.patch_margin_left = pattern_rects.top_corners[0]
	top_texture.patch_margin_top = pattern_rects.top_corners[1]
	top_texture.patch_margin_right = pattern_rects.top_corners[2]
	top_texture.patch_margin_bottom = pattern_rects.top_corners[3]
	# Set shadow and top position
	var x; var y; var s;
	if scrollbar_design == "Horizontal":
		top.rect_size.x = get_horizontal_top_width()
		top.rect_size.y = rect_size.y - 4
		top_shadow.rect_size = top.rect_size
		if set_initial_position:
			x = 2
			y = rect_size.y * 0.5 - top.rect_size.y * 0.5
			top.rect_position = Vector2(x, y)
	else:
		top.rect_size.x = rect_size.x - 4
		top.rect_size.y = get_vertical_top_height()
		top_shadow.rect_size = top.rect_size
		if set_initial_position:
			x = rect_size.x * 0.5 - top.rect_size.x * 0.5
			y = 2
			top.rect_position = Vector2(x, y)
	top_shadow.rect_position = Vector2(2, 5)
	# top decoration texture
	top_decoration.texture = pattern
	if scrollbar_design == "Horizontal":
		top_decoration.region_rect = pattern_rects.decoration_ver_normal
	else:
		top_decoration.region_rect = pattern_rects.decoration_hor_normal
	# set top decoration position
	x = top.rect_size.x * 0.5 - top_decoration.region_rect.size.x * 0.5
	y = top.rect_size.y * 0.5 - top_decoration.region_rect.size.y * 0.5
	top_decoration.position = Vector2(x, y)
	
func get_horizontal_top_width() -> float:
	if data.target_max_scroll.x <= 0:
		return rect_size.x - 4
	var s = rect_size.x - 2
	var ratio = data.target_max_scroll.x / s
	var value = max(16, s - s * ratio)
	data.max_scroll.x = s - value
	return value
	
func get_vertical_top_height() -> float:
	if data.target_max_scroll.y <= 0:
		return rect_size.y - 4
	var s = rect_size.y - 2
	var ratio = data.target_max_scroll.y / s
	var value = max(16, s - s * ratio)
	data.max_scroll.y = s - value
	return value

	
func update_image(value):
	pattern = value
	need_refresh = true
	set_process(true)
	
func change_design(value):
	if scrollbar_design != null:
		need_change_position = true
	scrollbar_design = value
	need_refresh = true
	set_process(true)
	

func _on_item_rect_changed() -> void:
	if pattern and Engine.editor_hint:
		set_images(true)


func _on_top_mouse_entered() -> void:
	top_texture.region_rect = pattern_rects.top_over


func _on_top_mouse_exited() -> void:
	top_texture.region_rect = pattern_rects.top_normal


func _on_background_mouse_entered() -> void:
	background_texture.region_rect = pattern_rects.background_over


func _on_background_mouse_exited() -> void:
	background_texture.region_rect = pattern_rects.background_normal


func set_displacement(value):
	if scrollbar_design == "Horizontal":
		if data.target_max_scroll.x <= 0:
			fix_top_position()
			return
		var x = map(value.x, data.target_min_scroll.x, data.target_max_scroll.x,
			data.min_scroll.x, data.max_scroll.x)
		top.rect_position.x = x
		value = -x
	else:
		if data.target_max_scroll.y <= 0:
			fix_top_position()
			return
		var y = map(value.y, data.target_min_scroll.y, data.target_max_scroll.y,
			data.min_scroll.y, data.max_scroll.y)
		top.rect_position.y = y
	fix_top_position()
	emit_signal("scroll", get_displacement())

func get_displacement():
	var value
	if scrollbar_design == "Horizontal":
		if data.target_max_scroll.x <= 0:
			fix_top_position()
			return 0
		value = map(top.rect_position.x, data.min_scroll.x, data.max_scroll.x,
			data.target_min_scroll.x, data.target_max_scroll.x)
	else:
		if data.target_max_scroll.y <= 0:
			fix_top_position()
			return 0
		value = map(top.rect_position.y, data.min_scroll.y, data.max_scroll.y,
			data.target_min_scroll.y, data.target_max_scroll.y)
	return value

func _on_top_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and drag:
		var movement = event.relative
		var _rect_position = top.rect_position
		if scrollbar_design == "Horizontal":
			top.rect_position.x += movement.x
		else:
			top.rect_position.y += movement.y
		fix_top_position()
		if _rect_position != top.rect_position:
			emit_signal("scroll", get_displacement())	
	elif event is InputEventMouseButton and event.button_index == 1:
		if can_move():
			drag = event.is_pressed()
			emit_signal("scroll", get_displacement())
		else:
			drag = false
	elif event.is_action_pressed("MouseWheelUp"):
		if can_move():
			move_top_by(-5)
	elif event.is_action_pressed("MouseWheelDown"):
		if can_move():
			move_top_by(5)
		
func can_move() -> bool:
	if scrollbar_design == "Horizontal":
		return (data.max_scroll.x > 4 and data.target_max_scroll.x > 0)
	else:
		return (data.max_scroll.y > 4 and data.target_max_scroll.y > 0)
			
func fix_top_position():
#	if ((scrollbar_design == "Horizontal" and data.target_max_scroll.x <= 0) or
#		(scrollbar_design == "Vertical" and data.target_max_scroll.y <= 0)):
#		top.rect_position.x = data.min_scroll.x
#		top.rect_position.y = data.min_scroll.y
#	else:
	if scrollbar_design == "Horizontal":
		if top.rect_position.x < data.min_scroll.x:
			top.rect_position.x = data.min_scroll.x
		if top.rect_position.x + top.rect_size.x > rect_size.x - 4:
			top.rect_position.x = rect_size.x - 4 - top.rect_size.x
	else:
		if top.rect_position.y < data.min_scroll.y:
			top.rect_position.y = data.min_scroll.y
		if top.rect_position.y + top.rect_size.y > rect_size.y - 4:
			top.rect_position.y = rect_size.y - 4 - top.rect_size.y


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		background_drag = event.is_pressed()
	elif event.is_action_pressed("MouseWheelUp"):
		if can_move():
			move_top_by(-5)
	elif event.is_action_pressed("MouseWheelDown"):
		if can_move():
			move_top_by(5)
		
		
func _physics_process(delta: float) -> void:
	if background_drag and Input.is_action_pressed("MouseLeft") and can_move():
		move_top_by_step()
		
func move_top_by_step():
	var pos = get_global_mouse_position()
	var displacement = 5
	var _rect_position = top.rect_position
	if scrollbar_design == "Horizontal":
		var left2right = pos.x > top.rect_global_position.x
		if left2right:
			var x = top.rect_global_position.x + top.rect_size.x
			if  x < pos.x:
				top.rect_global_position.x += displacement
		else:
			var x = top.rect_global_position.x
			if  x > pos.x:
				top.rect_global_position.x -= displacement
	else:
		var top2bottom = pos.y > top.rect_global_position.y
		if top2bottom:
			var y = top.rect_global_position.y + top.rect_size.y
			if  y < pos.y:
				top.rect_global_position.y += displacement
		else:
			var y = top.rect_global_position.y
			if  y > pos.y:
				top.rect_global_position.y -= displacement
	fix_top_position()
	if _rect_position != top.rect_global_position:
		emit_signal("scroll", get_displacement())
		
func move_top_by(displacement):
	var _pos = top.rect_global_position
	if scrollbar_design == "Horizontal":
		top.rect_global_position.x += displacement
	else:
		top.rect_global_position.y += displacement
	fix_top_position()
	if _pos != top.rect_global_position:
		emit_signal("scroll", get_displacement())
				
			
func map(value : float, istart : float, istop : float,
	ostart : float, ostop : float) -> float:
	#if (istop - istart) == 0: return value
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))	
		
func _process(delta: float) -> void:
	if top:
		if (scrollbar_design == "Horizontal" and
			top.rect_position.x < data.min_scroll.x):
				top.rect_position.x = data.min_scroll.x
		if (scrollbar_design == "Vertical" and
			top.rect_position.y < data.min_scroll.y):
				top.rect_position.y = data.min_scroll.y
	if Engine.editor_hint:
		if initializing:
			can_auto_change_position = true
			need_refresh = false
			initializing = false
		elif need_refresh:
			_ready()
			need_refresh = false
			if need_change_position and can_auto_change_position:
				rect_size = Vector2(rect_size.y, rect_size.x)
				need_change_position = false
		set_process(false)

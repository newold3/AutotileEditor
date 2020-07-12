extends RichTextLabel

onready var back_panel			= $BackPanel
onready var label				= $Label
onready var animation			= $AnimationPlayer
onready var timer				= $Timer

var is_hide = true
var show_hide_animation = true

func _ready() -> void:
	label.add_font_override("font", get_font("normal_font"))


func set_text(_text):
	bbcode_text = _text
	var font = get_font("normal_font")
	var array_text = text.split("\n")
	var w = 0
	var h = 0
	for i in array_text.size():
		var size = font.get_string_size(array_text[i])
		w = max(w, size.x)
		h += size.y
	rect_size = Vector2(w, h)
	back_panel.rect_size = rect_size + Vector2(32, 32)
	#label.text = ""
	
func show():
	show_hide_animation = true
	animation.stop()
	visible = false
	if text.length() == 0: return
	timer.start()
	is_hide = false
	yield(timer, "timeout")
	if is_hide: return
	update_position()
	animation.play("show")
	is_hide = false
	yield(animation, "animation_finished")
	
func hide(value = false):
	if show_hide_animation:
		if !is_hide or value:
			is_hide = true
			animation.play("hide")
		
func update_position():
	if is_hide: return
	var pos = get_global_mouse_position() + Vector2(16, 16)
	if pos.x < 16:
		pos.x = 16
	elif pos.x + rect_size.x + 16 > get_viewport_rect().size.x:
		pos.x = pos.x - rect_size.x - 28
	if pos.y < 16:
		pos.y = 16
	elif pos.y + rect_size.y + 16 > get_viewport_rect().size.y:
		pos.y = pos.y - rect_size.y - 28
	rect_global_position = pos
	
func hide_all():
	is_hide = true
	timer.stop()
	animation.stop()
	show_hide_animation = false
	visible = false


func _on_Timer_timeout() -> void:
	pass # Replace with function body.

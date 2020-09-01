tool
extends EditorPlugin

# Initial variables:
#var button

# Add menu button to canvas editor:
func _enter_tree()-> void:
	add_tool_menu_item("Autotile Editor", self, "clickedButton")
	#button = Button.new()
	#button.set_text("Tool - Create Autotile")
	#button.connect("pressed",  self, "clickedButton")
	# CONTAINER_CANVAS_EDITOR_MENU, CONTAINER_TOOLBAR
	#add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, button)

func clickedButton(ud):
	var _icon = ProjectSettings.get_setting("application/config/icon")
	var _name = ProjectSettings.get_setting("application/config/name")
	ProjectSettings.set_setting("application/config/icon", "res://addons/RPG_maker_Autotile2_3x3/icon.png")
	ProjectSettings.set_setting("application/config/name", "Create Autotiles by Newold")
	ProjectSettings.save()
	var executable = OS.get_executable_path()
	var array = ["res://Addons/RPG_maker_Autotile2_3x3/CreateAutoTile.tscn"]
	var args = PoolStringArray(array)
	OS.execute(executable, args)
	ProjectSettings.set_setting("application/config/icon", _icon)
	ProjectSettings.set_setting("application/config/name", _name)
	ProjectSettings.save()
	get_editor_interface().get_resource_filesystem().scan()


# Remove menu button from canvas editor:
func _exit_tree():
	remove_tool_menu_item("Autotile Editor")
	#remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, button)
	#button.free()
	pass

# Plugin name:
func get_plugin_name()-> String: 
	return "Create Autotile from RPG Makers tilesets";

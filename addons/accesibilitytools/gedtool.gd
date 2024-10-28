@tool
extends EditorPlugin

var panel

const TOOL_PANEL = preload("res://addons/accesibilitytools/tool_panel.tscn")

func _enter_tree():
	panel = TOOL_PANEL.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
	panel.undo_redo = get_undo_redo()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, panel)
	if has_method("get_editor_interface"):
		panel.set_editor_interface(get_editor_interface())

func _exit_tree():
	remove_control_from_docks(panel)
	panel.queue_free()

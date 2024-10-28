extends OptionButton

@export var shader_normal : Shader = preload("res://addons/accesibilitytools/shaders/normal_shader.gdshader")
@export var shader_deuteranopia : Shader = preload("res://addons/accesibilitytools/shaders/deuteranopia_shader.gdshader")
@export var shader_protanopia : Shader = preload("res://addons/accesibilitytools/shaders/protanopia_shader.gdshader")
@export var shader_tritanopia : Shader = preload("res://addons/accesibilitytools/shaders/tritanopia_shader.gdshader")


func _ready():
	connect("item_selected", Callable(self, "_on_daltonismo_selected"))
	select(global_accesibility_signal.color_blind_selected)

func _on_daltonismo_selected(index):
	var selected_option = get_item_text(index)
	
	match selected_option:
		"Normal":
			global_accesibility_signal.emit_change_shader(shader_normal, index)
			print("Normal")
		"Deuteranopía":
			global_accesibility_signal.emit_change_shader(shader_deuteranopia, index)
			print("Deuteronopia")
		"Protanopía":
			global_accesibility_signal.emit_change_shader(shader_protanopia, index)
			print("Protanopía")
		"Tritanopía":
			global_accesibility_signal.emit_change_shader(shader_tritanopia, index)
			print("Tritanopía")
		_:
			print("Opción no reconocida: ", selected_option)

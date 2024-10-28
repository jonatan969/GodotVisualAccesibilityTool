extends ColorRect

func _ready():
	global_accesibility_signal.connect("change_shader", Callable(self, "_on_shader_changed"))
	if global_accesibility_signal.selected_shader == null:
		pass
	else:
		_on_shader_changed(global_accesibility_signal.selected_shader)

func _on_shader_changed(shader: Shader):
	if shader:
		var material = ShaderMaterial.new()
		material.shader = shader
		self.material = material
	else:
		self.material = null 

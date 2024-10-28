extends Control

@onready var item_list = $ItemListGlowObject
@onready var color_picker_button = $ColorPickerGlowObject
@onready var line_edit_glow_intensity = $LineEditIntensity
@onready var line_edit_glow_time_factor = $LineEditTimeFactor
@onready var apply_glow_button = $ApplyGlowButton
@onready var restore_glow_button = $RestoreGlowButton

var glow_object_data := []

var json_file_path = "res://addons/accesibilitytools/glow_object/glow_data.json"

func _ready():
	# Cargar los datos del JSON al iniciar
	load_glow_data()
	
	# Conectar las señales utilizando Callable
	item_list.connect("item_selected", Callable(self, "_on_item_list_item_selected"))
	restore_glow_button.connect("pressed", Callable(self, "_on_restore_glow_button_pressed"))
	apply_glow_button.connect("pressed", Callable(self, "_on_apply_glow_button_pressed"))

# Función para cargar los datos desde el JSON y llenar la matriz
func load_glow_data():
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var parsed_data = JSON.parse_string(json_data)
		if typeof(parsed_data) == TYPE_DICTIONARY or typeof(parsed_data) == TYPE_ARRAY:
			glow_object_data = parsed_data
			print("Datos cargados exitosamente desde JSON: ", glow_object_data)
		else:
			print("Error al parsear el archivo JSON.")
		file.close()
	else:
		print("No se pudo abrir el archivo JSON en la ruta: ", json_file_path)

# Función que se llama cuando seleccionas un ítem del ItemList
func _on_item_list_item_selected(index):
	# Obtener la escena seleccionada y el target_color de la matriz
	var selected_data = glow_object_data[index]
	var name_scene = selected_data[0]
	var scene_path = selected_data[1]
	
	# Cargar la escena para modificar su shader
	if apply_glow_button.disabled:
		color_picker_button.color = Color(1, 1, 0)  # Color amarillo
		line_edit_glow_intensity.text = "0.5"
		line_edit_glow_time_factor.text = "1.5"
		apply_glow_button.disabled = false
		restore_glow_button.disabled = false
	
	var scene = load(scene_path) as PackedScene
	if scene:
		var instance = scene.instantiate() 
		var shader_material = instance.material
		if shader_material and shader_material is ShaderMaterial:
			# Cambiar el replace_color en el shader
			var shader = shader_material as ShaderMaterial
			shader_material.set_shader_parameter("glow_color", color_picker_button.color)
			shader_material.set_shader_parameter("intensity", float(line_edit_glow_intensity.text))
			shader_material.set_shader_parameter("time_factor", float(line_edit_glow_time_factor.text))
			print("Shader aplicado y parámetros establecidos.")
		else:
			print("No se pudo encontrar el nodo padre.")
	else:
		print("No se pudo cargar la escena: ", scene_path)

# Función para restaurar el color original (target_color)
func _on_restore_glow_button_pressed():
	var selected_index = item_list.get_selected_items()[0]
	if selected_index >= 0:
		var selected_data = glow_object_data[selected_index]
		var name_scene = selected_data[0]
		var scene_path = selected_data[1]
		color_picker_button.color = "ffff00"
	
		# Cargar la escena para modificar su shader
		var scene = load(scene_path) as PackedScene
		if scene:
			var instance = scene.instantiate() 
			var shader_material = instance.material
			var shader = shader_material as ShaderMaterial
			shader.set_shader_parameter("intensity", 0)
		else:
			print("No se pudo cargar la escena: ", scene_path)

# Opción: función para aplicar color (si es necesario)
func _on_apply_glow_button_pressed():
	# Lógica para aplicar el color seleccionado por el ColorPickerButton
	_on_item_list_item_selected(item_list.get_selected_items()[0])

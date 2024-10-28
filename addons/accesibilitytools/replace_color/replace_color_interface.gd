extends Control

@onready var item_list = $ItemListReplaceColor
@onready var color_picker_button = $ColorPickerReplaceColor
@onready var apply_color_button = $ApplyColorButton
@onready var restore_color_button = $RestoreColorButton

var color_replace_data := []

var json_file_path = "res://addons/accesibilitytools/replace_color/replace_data.json"

# Llamar a la función al seleccionar un ítem en el ItemList
func _ready():
	# Cargar los datos del JSON al iniciar
	load_replace_color_data()
	
	# Conectar las señales utilizando Callable
	item_list.connect("item_selected", Callable(self, "_on_item_list_item_selected"))
	restore_color_button.connect("pressed", Callable(self, "_on_restore_color_button_pressed"))
	apply_color_button.connect("pressed", Callable(self, "_on_apply_color_button_pressed"))

# Función para cargar los datos desde el JSON y llenar la matriz
func load_replace_color_data():
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var parsed_data = JSON.parse_string(json_data)
		if typeof(parsed_data) == TYPE_DICTIONARY or typeof(parsed_data) == TYPE_ARRAY:
			color_replace_data = parsed_data
			print("Datos cargados exitosamente desde JSON: ", color_replace_data)
		else:
			print("Error al parsear el archivo JSON.")
		file.close()
	else:
		print("No se pudo abrir el archivo JSON en la ruta: ", json_file_path)

# Función que se llama cuando seleccionas un ítem del ItemList
func _on_item_list_item_selected(index):
	# Obtener la escena seleccionada y el target_color de la matriz
	var selected_data = color_replace_data[index]
	var name_scene = selected_data[0]
	var scene_path = selected_data[1]
	var color_string = selected_data[2] 
	color_string = color_string.strip_edges()  # Eliminar espacios en blanco
	color_string = color_string.substr(1, color_string.length() - 2)  # Quitar paréntesis
	var color_values = color_string.split(",")  # Dividir la cadena en valores

	var target_color = Color()
	if color_values.size() == 4:
		for i in range(4):
			var value = float(color_values[i].strip_edges())  # Convertir a float
			value = clamp(value, 0.0, 1.0)  # Asegurarse que esté en el rango [0, 1]
			if i == 0:
				target_color.r = value
			elif i == 1:
				target_color.g = value
			elif i == 2:
				target_color.b = value
			elif i == 3:
				target_color.a = value
	if apply_color_button.disabled == true:
		color_picker_button.color = target_color
		apply_color_button.disabled = false
		restore_color_button.disabled = false
	# Cargar la escena para modificar su shader
	var scene = load(scene_path) as PackedScene
	if scene:
		var instance = scene.instantiate()  
		
		# Obtener el nodo que contiene el shader (ajusta esto según tu escena)
		var shader_material = instance.material
		if shader_material and shader_material is ShaderMaterial:
			# Cambiar el replace_color en el shader
			var shader = shader_material as ShaderMaterial
			shader.set_shader_parameter("replace_color", color_picker_button.color)
			print("Color aplicado: ", color_picker_button.color)
	else:
		print("No se pudo cargar la escena: ", scene_path)

# Función para restaurar el color original (target_color)
func _on_restore_color_button_pressed():
	var selected_index = item_list.get_selected_items()[0]
	if selected_index >= 0:
		var selected_data = color_replace_data[selected_index]
		var name_scene = selected_data[0]
		var scene_path = selected_data[1]
		var color_string = selected_data[2] 
		color_string = color_string.strip_edges()  # Eliminar espacios en blanco
		color_string = color_string.substr(1, color_string.length() - 2)  # Quitar paréntesis
		var color_values = color_string.split(",")  # Dividir la cadena en valores

		var target_color = Color()
		if color_values.size() == 4:
			for i in range(4):
				var value = float(color_values[i].strip_edges())  # Convertir a float
				value = clamp(value, 0.0, 1.0)  # Asegurarse que esté en el rango [0, 1]
				if i == 0:
					target_color.r = value
				elif i == 1:
					target_color.g = value
				elif i == 2:
					target_color.b = value
				elif i == 3:
					target_color.a = value
		
		color_picker_button.color = target_color
		# Cargar la escena para modificar su shader
		var scene = load(scene_path) as PackedScene
		if scene:
			var instance = scene.instantiate()  
			
			# Obtener el nodo que contiene el shader (ajusta esto según tu escena)
			var shader_material = instance.material
			if shader_material and shader_material is ShaderMaterial:
				# Cambiar el replace_color en el shader
				var shader = shader_material as ShaderMaterial
				shader.set_shader_parameter("replace_color", target_color)
				print("Color aplicado: ", target_color)
		else:
			print("No se pudo cargar la escena: ", scene_path)

# Opción: función para aplicar color (si es necesario)
func _on_apply_color_button_pressed():
	# Lógica para aplicar el color seleccionado por el ColorPickerButton
	_on_item_list_item_selected(item_list.get_selected_items()[0])

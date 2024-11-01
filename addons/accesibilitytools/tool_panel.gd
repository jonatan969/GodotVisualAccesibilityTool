@tool
extends ScrollContainer

var undo_redo : EditorUndoRedoManager
@export var scene : PackedScene

#region GUI
@onready var daltonismo_checkbutton = %cbDaltonismo

@onready var replacecolor_checkbutton = %cbReplaceColor
@onready var replacecolor_vboxcantainer = %vbReplaceColor

@onready var glowobject_checkbutton = %cbGlowObject
@onready var glowobject_vboxcantainer = %vbGlowObject

@onready var scene_picker_replace = %vbReplaceColor/arpReplaceColor
@onready var color_picker_replace = %vbReplaceColor/cpReplaceColor
@onready var itemlist_replacecolor = %vbReplaceColor/ilReplaceColor
@onready var name_replacecolor = %vbReplaceColor/leReplaceColor

@onready var scene_picker_glow = %vbGlowObject/arpSceneGlow
@onready var optionbutton_glow = %vbGlowObject/opGlowEffect
@onready var itemlist_glow = %vbGlowObject/ilGlowObjects
@onready var name_glow = %vbGlowObject/leGlowObject
#endregion

#region Replace Color var
var color_replace_data := []
var scene_replace_path = ""
var file_replace_path = "res://addons/accesibilitytools/replace_color/replace_data.json"
#endregion
var editor_interface
#region Glide Options var
var glow_object_data := []
var scene_glow_path = ""
var file_glow_path = "res://addons/accesibilitytools/glow_object/glow_data.json"
#endregion

func _ready():
	pass
func set_editor_interface(interface):
	editor_interface = interface
func _on_cb_daltonismo_toggled(toggled_on):
	if toggled_on == true:
		print("ColorBlindFilter: Activate")
	else:
		print("ColorBlindFilter: Desactivate")

func _on_cb_replace_color_toggled(toggled_on):
	replacecolor_vboxcantainer.visible = toggled_on
	if toggled_on == true:
		print("Replace Color: Activate")
	else:
		print("Replace Color: Desactivate")

func _on_cb_glide_object_toggled(toggled_on):
	glowobject_vboxcantainer.visible = toggled_on
	if toggled_on == true:
		print("Glow Object: Activate")
	else:
		print("Glow Object: Desactivate")


func _on_b_generador_pressed():
	if daltonismo_checkbutton.button_pressed == true or replacecolor_checkbutton.button_pressed == true or glowobject_checkbutton.button_pressed == true:
		if editor_interface:
			var message_dialog = AcceptDialog.new()
			message_dialog.dialog_text = """
			To apply and be able to see all the changes, 
			please restart Godot Engine
			"""
			editor_interface.get_base_control().add_child(message_dialog)
			message_dialog.call_deferred("popup_centered")  # Mostrar el diálogo centrado de forma segura
		else:
			print("Error: Reference to editor_interface is not available.")
	else:
		if editor_interface:
			var message_dialog = AcceptDialog.new()
			message_dialog.dialog_text = """
			No accessibility options selected
			"""
			editor_interface.get_base_control().add_child(message_dialog)
			message_dialog.call_deferred("popup_centered")  # Mostrar el diálogo centrado de forma segura
		else:
			print("Error: Reference to editor_interface is not available.")
	_add_global_to_autoload()
	_generate_daltonismo_options_scene()
	_generate_replace_color_scene()
	_generate_glow_objects_scene()


func _generate_shaderscreen_colorrect():
	var save_path = "res://colorblind_shaderscreen.tscn"
	var canvas_scene = CanvasLayer.new()
	canvas_scene.name = "ColorBlindCanvas"
	var colorrect_scene = ColorRect.new()
	colorrect_scene.name = "ColorBlindFilter"
	colorrect_scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	colorrect_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var colorrect_material = ShaderMaterial.new()
	colorrect_scene.material = colorrect_material
	var shader : Shader = preload("res://addons/accesibilitytools/shaders/normal_shader.gdshader")
	colorrect_material.shader = shader
	var script_path = "res://addons/accesibilitytools/shaders/daltonismo_colorrect.gd"
	var color_rect_script = load(script_path)
	if color_rect_script and color_rect_script is GDScript:
		colorrect_scene.set_script(color_rect_script)
	else:
		print("Error: The script could not be loaded or the script is invalid.")
	canvas_scene.add_child(colorrect_scene)
	colorrect_scene.owner = canvas_scene
	var scene_resource = PackedScene.new()
	var result = scene_resource.pack(canvas_scene)
	if result == OK:
		ResourceSaver.save(scene_resource, save_path)
		print("ColorRect scene saved in:: " + save_path)
	else:
		print("Error saving ColorRect scene.")

func _generate_daltonismo_options_scene():
	if daltonismo_checkbutton.button_pressed == true:
		_generate_shaderscreen_colorrect()
		var save_path = "res://colorblind_optionbutton.tscn"
		var accesibility_scene = VBoxContainer.new()
		accesibility_scene.name = "ColorBlindOptions"	
		print("Color Blind Available. Generating options...")
		var daltonismo_optionbutton = OptionButton.new()
		daltonismo_optionbutton.name = "DaltonismoItemList"
		daltonismo_optionbutton.add_item("Normal")
		daltonismo_optionbutton.add_item("Deuteranopía")
		daltonismo_optionbutton.add_item("Protanopía")
		daltonismo_optionbutton.add_item("Tritanopía")
		accesibility_scene.add_child(daltonismo_optionbutton)
		daltonismo_optionbutton.owner = accesibility_scene
		print("ItemList added to new scene.")
		
		var script_path = "res://addons/accesibilitytools/shaders/daltonismo_optionbutton.gd"
		var option_button_script = load(script_path)

		if option_button_script and option_button_script is GDScript:
			daltonismo_optionbutton.set_script(option_button_script)
		else:
			print("Error: The script could not be loaded or the script is invalid.")
		accesibility_scene.queue_sort()

		var scene_resource = PackedScene.new()
		var result = scene_resource.pack(accesibility_scene)
		if result != OK:
			print("Error packaging scene:", result)
			return
		var error = ResourceSaver.save(scene_resource, save_path)
		if error == OK:
			print("Color blindness options screen generated and saved in: " + save_path)
		else:
			print("Failed to save colorblind options scene. Error code:", error)
	else:
		print("Color Blind Filter dont Activated")	

func _generate_replace_color_scene():
	if replacecolor_checkbutton.button_pressed == true:
		_save_data_to_json(file_replace_path, color_replace_data)
	#region Crear ItemList con los registros de la matriz
		var replace_color_control = VBoxContainer.new()
		replace_color_control.name = "ReplaceColorControl"
		var replace_color_script = load("res://addons/accesibilitytools/replace_color/replace_color_interface.gd")
		replace_color_control.set_script(replace_color_script)
		replace_color_control.process_mode = Node.PROCESS_MODE_ALWAYS
		
		var itemlist_replace = ItemList.new()
		itemlist_replace.name = "ItemListReplaceColor"
		itemlist_replace.custom_minimum_size = Vector2(200, 100)
		for data in color_replace_data:
			itemlist_replace.add_item(data[0])
		var colorpickerbutton_replace = ColorPickerButton.new()
		colorpickerbutton_replace.name = "ColorPickerReplaceColor"
		colorpickerbutton_replace.custom_minimum_size = Vector2(200, 50)
		
		var button_applyreplace = Button.new()
		button_applyreplace.name = "ApplyColorButton"
		button_applyreplace.text = "Apply"
		button_applyreplace.disabled = true
		var button_restorereplace = Button.new()
		button_restorereplace.name = "RestoreColorButton"
		button_restorereplace.text = "Restore Color"
		button_restorereplace.disabled = true
		
		replace_color_control.add_child(itemlist_replace)
		replace_color_control.add_child(colorpickerbutton_replace)
		replace_color_control.add_child(button_applyreplace)
		replace_color_control.add_child(button_restorereplace)
		itemlist_replace.owner = replace_color_control
		colorpickerbutton_replace.owner = replace_color_control
		button_applyreplace.owner = replace_color_control
		button_restorereplace.owner = replace_color_control

		var save_path = "res://replacecolorinterface.tscn"
		var packed_scene_interface = PackedScene.new()
		var interfaceresult = packed_scene_interface.pack(replace_color_control)
		if interfaceresult != OK:
			print("Error packaging scene")
			return
		interfaceresult = ResourceSaver.save(packed_scene_interface,save_path)
		if interfaceresult == OK:
			print("Scene successfully saved in:", save_path)
		else:
			print("Error saving scene:", interfaceresult)
	#endregion
	#region Crear Canvas Layer con filtro en Objetos
		for data in color_replace_data:
			var name_option = data[0] 
			var scene_path = data[1] 
			var target_color = data[2] 
			var scene = load(scene_path).instantiate()
			
			if not scene:
				print("Error: Could not load scene:", scene_path)
				continue
				
			var shader_material = ShaderMaterial.new()
			var shader = Shader.new()
			shader.resource_path = "res://addons/accesibilitytools/replace_color/ReplaceColor_"+name_option+".gdshader"
			shader.code = """
shader_type canvas_item;

render_mode unshaded;

uniform vec4 target_color : source_color;
uniform vec4 replace_color : source_color; // Color de reemplazo
			
			
uniform float hue_threshold : hint_range(0.0, 1.0) = 0.1;      // Umbral de diferencia para el matiz (Hue)
uniform float saturation_threshold : hint_range(0.0, 1.0) = 0.2; // Umbral de diferencia para la saturación
uniform float value_threshold : hint_range(0.0, 1.0) = 1.0;      // Umbral de valor para cubrir más tonos del color

// Función para convertir RGB a HSV
vec3 rgb_to_hsv(vec3 color) {
	float max_val = max(max(color.r, color.g), color.b);
	float min_val = min(min(color.r, color.g), color.b);
	float delta = max_val - min_val;

	vec3 hsv = vec3(0.0); // Hue, Saturation, Value

	// Cálculo de Value
	hsv.z = max_val;

	// Cálculo de Saturation
	hsv.y = (max_val == 0.0) ? 0.0 : delta / max_val;

	// Cálculo de Hue
	if (delta != 0.0) {
		if (max_val == color.r) {
			hsv.x = (color.g - color.b) / delta + (color.g < color.b ? 6.0 : 0.0);
		} else if (max_val == color.g) {
			hsv.x = (color.b - color.r) / delta + 2.0;
		} else {
			hsv.x = (color.r - color.g) / delta + 4.0;
		}
		hsv.x /= 6.0;
	}

	return hsv;
}

// Función para convertir HSV de vuelta a RGB
vec3 hsv_to_rgb(vec3 hsv) {
	float h = hsv.x * 6.0;
	float c = hsv.y * hsv.z;
	float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));

	vec3 rgb = vec3(0.0);
	if (h < 1.0) rgb = vec3(c, x, 0.0);
	else if (h < 2.0) rgb = vec3(x, c, 0.0);
	else if (h < 3.0) rgb = vec3(0.0, c, x);
	else if (h < 4.0) rgb = vec3(0.0, x, c);
	else if (h < 5.0) rgb = vec3(x, 0.0, c);
	else rgb = vec3(c, 0.0, x);

	float m = hsv.z - c;
	return rgb + vec3(m, m, m);
}

void fragment() {
	// Obtener el color actual de la pantalla en las coordenadas del fragmento
	vec4 screen_color = textureLod(TEXTURE, UV, 0.0);

	// Convertir los colores a espacio HSV
	vec3 screen_hsv = rgb_to_hsv(screen_color.rgb);
	vec3 target_hsv = rgb_to_hsv(target_color.rgb);
	vec3 replace_hsv = rgb_to_hsv(replace_color.rgb);

	// Comparar los componentes HSV de manera separada
	float hue_diff = abs(screen_hsv.x - target_hsv.x);         // Diferencia de matiz
	float saturation_diff = abs(screen_hsv.y - target_hsv.y);  // Diferencia de saturación
	float value_diff = abs(screen_hsv.z - target_hsv.z);       // Diferencia de valor

	// Si la diferencia en el matiz y la saturación está dentro de los umbrales, reemplazar el color
	if (hue_diff < hue_threshold && saturation_diff < saturation_threshold) {
		// Mantener el valor (luminosidad) del color original pero aplicar el valor de umbral
		replace_hsv.z = screen_hsv.z * value_threshold;

		// Convertir de nuevo a RGB
		screen_color.rgb = hsv_to_rgb(replace_hsv);
	}

	// Devolver el color final manteniendo la transparencia original
	COLOR = vec4(screen_color.rgb, screen_color.a);
} 
			"""
			shader_material.set_shader(shader)
			shader_material.set_shader_parameter("target_color", target_color) # Asignar el color objetivo
			shader_material.set_shader_parameter("replace_color", target_color)
			shader.resource_name = "ShaderReplace_" + name_option
			var shader_path = "res://addons/accesibilitytools/replace_color/ReplaceColor_" + name_option + ".gdshader"
			var shader_save_result = ResourceSaver.save(shader, shader_path)
			if shader_save_result == OK:
				print("Shader successfully saved in:", shader_path)
			else:
				print("Error saving shader:", shader_save_result)

			scene.material = shader_material  # Asigna el material al padre
			# Recorrer los nodos hijos y activar 'use_parent_material' si es posible
			for child in scene.get_children():
				if child is Sprite2D or child is Sprite3D or child is MeshInstance3D or child is AnimatedSprite2D or child is AnimatedSprite3D:
					child.use_parent_material = true

			print("Shader aplicado al nodo padre de la escena:", scene_path)
			print("Shader asignado: ", shader.resource_name)
			var packed_scene = PackedScene.new()
			packed_scene.pack(scene)
			var result = ResourceSaver.save(packed_scene, scene_path)
			if result == OK:
				print("Escena guardada con éxito en:", scene_path)
			else:
				print("Error al guardar la escena:", result)
	#endregion
	else:
		print("Replace Color dont Activated")

func _generate_glow_objects_scene():
	if glowobject_checkbutton.button_pressed == true:
		_save_data_to_json(file_glow_path, glow_object_data)
		#region Crear ItemList con los registros de la matriz
		var glow_objects_control = VBoxContainer.new()
		glow_objects_control.name = "GlowObjectControl"
		var glow_object_script = load("res://addons/accesibilitytools/glow_object/glow_object_interface.gd")
		glow_objects_control.set_script(glow_object_script)
		
		var itemlist_glow = ItemList.new()
		itemlist_glow.name = "ItemListGlowObject"
		itemlist_glow.custom_minimum_size = Vector2(200, 100)
		for data in glow_object_data:
			itemlist_glow.add_item(data[0])
		var colorpickerbutton_glow = ColorPickerButton.new()
		colorpickerbutton_glow.name = "ColorPickerGlowObject"
		colorpickerbutton_glow.custom_minimum_size = Vector2(200, 50)
		
		var intensity_glow = Label.new()
		intensity_glow.text = "Intensity"
		intensity_glow.name = "Intensity"
		var time_glow = Label.new()
		time_glow.text = "Time Factor"
		time_glow.name = "Time Factor"
		
		var intenstity_line = LineEdit.new()
		intenstity_line.name = "LineEditIntensity"
		intenstity_line.placeholder_text = "0.5"
		var time_line = LineEdit.new()
		time_line.name = "LineEditTimeFactor"
		time_line.placeholder_text = "1"
		
		var button_applyreplace = Button.new()
		button_applyreplace.name = "ApplyGlowButton"
		button_applyreplace.text = "Apply"
		button_applyreplace.disabled = true
		var button_restorereplace = Button.new()
		button_restorereplace.name = "RestoreGlowButton"
		button_restorereplace.text = "Restore Color"
		button_restorereplace.disabled = true
		
		glow_objects_control.add_child(itemlist_glow)
		glow_objects_control.add_child(colorpickerbutton_glow)
		glow_objects_control.add_child(intensity_glow)
		glow_objects_control.add_child(intenstity_line)
		glow_objects_control.add_child(time_glow)
		glow_objects_control.add_child(time_line)
		glow_objects_control.add_child(button_applyreplace)
		glow_objects_control.add_child(button_restorereplace)
		itemlist_glow.owner = glow_objects_control
		colorpickerbutton_glow.owner = glow_objects_control
		intensity_glow.owner = glow_objects_control
		intenstity_line.owner = glow_objects_control
		time_glow.owner = glow_objects_control
		time_line.owner = glow_objects_control
		button_applyreplace.owner = glow_objects_control
		button_restorereplace.owner = glow_objects_control

		var save_path = "res://glowobjectsinterface.tscn"
		var packed_scene_interface = PackedScene.new()
		var interfaceresult = packed_scene_interface.pack(glow_objects_control)
		if interfaceresult != OK:
			print("Error packaging scene")
			return
		interfaceresult = ResourceSaver.save(packed_scene_interface,save_path)
		if interfaceresult == OK:
			print("Scene successfully saved in:", save_path)
		else:
			print("Error saving scene:", interfaceresult)
		#endregion
		#region Insertar Shader en Nodo Padre y activar use_parent_material
		for data in glow_object_data:
			var name_option = data[0]
			var scene_path = data[1]
			var value = data[2] # Este es el valor que define el tipo de efecto ("Shine", "Metalic", etc.)
			var scene = load(scene_path).instantiate()

			if not scene:
				print("Error: Could not load scene:", scene_path)
				continue

			# Crear el shader material
			var shader_material = ShaderMaterial.new()
			var shader = Shader.new()
			shader.resource_path = "res://addons/accesibilitytools/glow_object/GlowObject_"+name_option+".gdshader"
			# Verifica el valor para seleccionar el shader correspondiente
			if value == "Shine":
				print("Shader:", value)
				shader.code = """
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float intensity = 0;
uniform float time_factor = 1.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	if (original_color.a < 0.01) {
		discard;
	} else {
		float glow_effect = abs(sin(TIME * time_factor));

		vec4 final_color = mix(original_color, glow_color, glow_effect * intensity);
		
		COLOR = final_color;
	}
}
			"""
			elif value == "Metalic":
				print("Shader:", value)
				shader.code = """
shader_type canvas_item;
uniform vec4 glow_color : source_color = vec4(1.0, 0.0, 1.0, 1.0); // Color del brillo
uniform float intensity = 0; // Intensidad del brillo
uniform float time_factor = 2.0; // Velocidad de animación del brillo
uniform float frequency = 2.0; // Frecuencia del patrón de brillo

void fragment() {
	// Obtener el color original del sprite debajo
	vec4 original_color = texture(TEXTURE, UV);
	
	// Coordenadas UV desplazadas por tiempo para generar el movimiento
	vec2 uv_offset = UV + vec2(sin(TIME * time_factor), cos(TIME * time_factor)) * 0.1;
	
	// Efecto de ondas de brillo basado en la posición UV y el tiempo
	float wave = sin((uv_offset.x + uv_offset.y) * frequency + TIME * time_factor) * 0.5 + 0.5;
	
	// Intensificar el efecto de brillo
	float glow_effect = wave * intensity;

	// Mezclar el color del brillo con el color original
	vec4 final_color = mix(original_color, glow_color, glow_effect);
	
	// Asignar el color final solo si el pixel no es transparente
	if (original_color.a > 0.01) {
		COLOR = final_color;
	} else {
		COLOR = original_color;
	}
}
			"""
			else:
				print("Error: Valor de shader no válido:", value)
				continue

			shader_material.set_shader(shader)
			shader_material.set_shader_parameter("intensity", 0)
			shader_material.set_shader_parameter("time_factor", 1.5)
			shader.resource_name = "ShaderGlowObject_" + name_option
			var shader_path = "res://addons/accesibilitytools/glow_object/GlowObject_"+name_option+".gdshader"
			var shader_save_result = ResourceSaver.save(shader, shader_path)
			if shader_save_result == OK:
				print("Shader successfully saved in:", shader_path)
			else:
				print("Error saving shader:", shader_save_result)

			scene.material = shader_material  # Asigna el material al padre
			# Recorrer los nodos hijos y activar 'use_parent_material' si es posible
			for child in scene.get_children():
				if child is Sprite2D or child is Sprite3D or child is MeshInstance3D or child is AnimatedSprite2D or child is AnimatedSprite3D:
					child.use_parent_material = true

			print("Shader applied to the parent node of the scene:", scene_path)
			print("Assigned shader: ", shader.resource_name)
			var packed_scene = PackedScene.new()
			packed_scene.pack(scene)
			var result = ResourceSaver.save(packed_scene, scene_path)
			if result == OK:
				print("Scene successfully saved to:", scene_path)
			else:
				print("Error saving scene:", result)
		#endregion
	else:
		print("Glow Objects don't Activated")

func _save_data_to_json(path: String, data: Array) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		# Convertir colores a strings para poder guardarlos en JSON
		var json_ready_data = []
		for item in data:
			var name = item[0]
			var scene_path = item[1]
			var valor = str(item[2])  # Convertir el color a string
			json_ready_data.append([name, scene_path, valor])
		# Convertir la matriz a formato JSON
		var json_data = JSON.stringify(json_ready_data)
		# Guardar el JSON en el archivo
		file.store_string(json_data)
		file.close()
		print("Data saved in: ", path)
	else:
		print("Error saving data to: ", path)

func _on_b_add_replace_color_pressed():
	var color_picker = color_picker_replace.color
	var name_option = name_replacecolor.text
	if scene_replace_path != "" and color_picker != null and name_option != "":
		color_replace_data.append([name_option,scene_replace_path,color_picker])
		print("Save: Name: ",name_option," Scene: ",scene_replace_path," Color: ",color_picker)
		_update_item_list_replace()
		name_replacecolor.text = ""
		color_picker_replace.color = "000000"
	else:
		print("There cannot be null fields: [", scene_replace_path, "] [", color_picker, "] [",name_option,"]")

func _on_arp_replace_color_resource_changed(resource):
	print(resource, " ")
	if resource:
		scene_replace_path = resource.resource_path
		print("Selected resource:", scene_replace_path)
	else:
		print("No valid resource has been selected.")

func _on_b_show_matriz_pressed():
	print(color_replace_data)

func _update_item_list_replace():
	itemlist_replacecolor.clear()
	for data in color_replace_data:
		itemlist_replacecolor.add_item("Name: " + data[0] + " | Scene: " + data[1] + " | Color: " + str(data[2]))

func _on_b_delete_replace_pressed():
	var selected_index = itemlist_replacecolor.get_selected_items()
	if selected_index.size() > 0:
		var index = selected_index[0]
		color_replace_data.remove_at(index)
		_update_item_list_replace()
		print("Element removed at position:", index)
	else:
		print("No items have been selected to delete.")

func _update_item_list_glow():
	itemlist_glow.clear()
	for data in glow_object_data:
		itemlist_glow.add_item("Name: " + data[0] + " | Scene: " + data[1] + " | Color: " + str(data[2]))

func _on_b_save_glow_pressed():
	var index = optionbutton_glow.get_selected_id() 
	if index == -1:  # Verificar si no hay una opción seleccionada
		print("No option selected on OptionButton")
		return
	var option_button = optionbutton_glow.get_item_text(index)
	var name_option = name_glow.text
	if scene_glow_path != "" and option_button != null and name_option != "":
		glow_object_data.append([name_option,scene_glow_path,option_button])
		print("Save: Name: ",name_option," Scene: ",scene_glow_path," Color: ",option_button)
		_update_item_list_glow()
		name_glow.text = ""
		optionbutton_glow.select(-1)
	else:
		print("There cannot be null fields: [", scene_glow_path, "] [", option_button, "] [",name_option,"]")

func _on_b_show_list_glow_pressed():
	print(glow_object_data)

func _on_b_delete_glow_pressed():
	var selected_index = itemlist_glow.get_selected_items()
	if selected_index.size() > 0:
		var index = selected_index[0]
		glow_object_data.remove_at(index)
		_update_item_list_glow()
		print("Element removed at position:", index)
	else:
		print("No items have been selected to delete.")

func _on_arp_scene_glow_resource_changed(resource):
	print(resource, " ")
	if resource:
		scene_glow_path = resource.resource_path
		print("Selected resource:", scene_glow_path)
	else:
		print("No valid resource has been selected.")

func _add_global_to_autoload(): 
	var project_path = "res://project.godot"
	var file = FileAccess.open(project_path, FileAccess.READ_WRITE)

	if file:
		var config = ConfigFile.new()
		config.parse(file.get_as_text())
		file.close()
		
		var autoloads_section_exists = config.has_section_key("autoload", "global_accesibility_signal")
		if not autoloads_section_exists:
			config.set_value("autoload", "global_accesibility_signal", "res://addons/accesibilitytools/global_accesibility_signal.gd")
			var save_err = config.save(project_path)
			
			if save_err == OK:
				print("Autoload Global.gd added successfully.")
			else:
				print("Error saving project.godot file: ", save_err)
		else:
			print("The Autoload 'Global' already exists in the project.")
	else:
		print("No se pudo abrir el archivo project.godot.")

func _on_b_autoload_pressed():
	if editor_interface:
		var message_dialog = AcceptDialog.new()
		message_dialog.dialog_text = """
		Activate autoload in Project Settings/Autoload
		,check "global_accesibility_signal" and 
		restart Godot Engine
		"""
		editor_interface.get_base_control().add_child(message_dialog)
		message_dialog.call_deferred("popup_centered")  # Mostrar el diálogo centrado de forma segura
	else:
		print("Error: Reference to editor_interface is not available.")
	_add_global_to_autoload()


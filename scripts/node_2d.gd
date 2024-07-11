extends Node2D

var points = []
var selected_point = -1
var point_radius = 10

func _ready():
	set_process_input(true)


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = event.position
			if selected_point == -1:
				points.append(mouse_pos)
				#point.global_position = mouse_pos
				#get_tree().root.add_child(point)
			else:
				points[selected_point] = mouse_pos
			selected_point = -1
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			return
	
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if selected_point != -1:
			points[selected_point] = event.position
	print(points)

extends Area2D
class_name Character
## Character management

## Used to move the character
var dragging: bool = false
## Offset to not snap character to mouse position when pressed the first time
var offset: Vector2 = Vector2.ZERO

## Attributes
var age: int = 0
var energy: int = 0
var disease: bool = false

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta) -> void:
	if dragging:
		position = get_global_mouse_position() - offset


## When pressed down
func _on_button_button_down() -> void:
	dragging = true
	offset = get_global_mouse_position() - position


## When not pressed
func _on_button_button_up() -> void:
	dragging = false


## When mouse hovers over the character
func _on_button_mouse_entered() -> void:
	$Sprite2D.modulate.a = 0.5


## When mouse leaves the area
func _on_button_mouse_exited() -> void:
	$Sprite2D.modulate.a = 1
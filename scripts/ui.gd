extends Control
## World UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_label(production: int) -> void:
	$LabelProduction.text = str(production)

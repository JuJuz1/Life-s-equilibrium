extends Control
## World UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Update production label
## [param production] current production amount
func update_label(production: int) -> void:
	$LabelProduction.text = str(production)


## Show end credits
func show_win() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($LabelWin, "modulate:a", 1, 1.5)

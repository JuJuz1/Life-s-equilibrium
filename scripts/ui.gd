extends Control
## World UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Update production label
## [param production, production_limit] current production amount and limit till next
func update_label(production: int, production_limit: int) -> void:
	$LabelProduction.text = str(production) + " / " + str(production_limit)


## Show end credits
func show_win() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($LabelWin, "modulate:a", 1, 1.5)


## Show game lose
func show_lose() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($LabelLose, "modulate:a", 1, 1.5)

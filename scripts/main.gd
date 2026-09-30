extends CenterContainer
## Scena startowa projektu. Podmień na właściwe menu/grę.

@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = "miernik"

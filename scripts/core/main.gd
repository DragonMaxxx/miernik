# Autor: Mateusz Bartoszewicz
extends CenterContainer
## Tymczasowa scena startowa, żeby projekt dało się uruchomić.
## Do zastąpienia po ustaleniu kierunku gry (mikrogra, potem projekt właściwy).

@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = "miernik"

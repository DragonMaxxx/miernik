# Autor: Mateusz Bartoszewicz
class_name Hud
extends CanvasLayer
## Widok: pokazuje wynik, czas i komunikat końca rundy. Niczego nie liczy,
## wszystko dostaje od Main przez sygnały.

@onready var _score_label: Label = $ScoreLabel
@onready var _time_label: Label = $TimeLabel
@onready var _message_label: Label = $MessageLabel


func set_score(score: int) -> void:
	_score_label.text = "Wynik: %d" % score


func set_time_left(seconds: int) -> void:
	_time_label.text = "Czas: %d" % seconds


func show_game_over(score: int) -> void:
	_message_label.text = "Koniec rundy!\nWynik: %d\n\nEnter lub spacja: jeszcze raz" % score
	_message_label.visible = true


func hide_message() -> void:
	_message_label.visible = false

# Autor: Mateusz Bartoszewicz
class_name Hud
extends CanvasLayer
## Widok: pokazuje wynik, czas, kombo i komunikaty (pauza, koniec rundy).
## Niczego nie liczy, wszystko dostaje od Main przez sygnały.

@onready var _score_label: Label = $ScoreLabel
@onready var _time_label: Label = $TimeLabel
@onready var _combo_label: Label = $ComboLabel
@onready var _message_label: Label = $MessageLabel


func set_score(score: int) -> void:
	_score_label.text = "Wynik: %d" % score


func set_time_left(seconds: int) -> void:
	_time_label.text = "Czas: %d" % seconds


# Kombo x1 to zwykłe zbieranie, więc pokazujemy je dopiero od x2.
func set_combo(combo: int) -> void:
	_combo_label.visible = combo >= 2
	_combo_label.text = "Kombo x%d" % combo


func set_paused(paused: bool) -> void:
	_message_label.text = "PAUZA\n\nEsc: wróć do gry"
	_message_label.visible = paused


func show_game_over(score: int) -> void:
	_message_label.text = "Koniec rundy!\nWynik: %d\n\nEnter lub spacja: jeszcze raz" % score
	_message_label.visible = true


func hide_message() -> void:
	_message_label.visible = false

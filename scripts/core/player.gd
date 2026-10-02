# Autor: Mateusz Bartoszewicz
class_name Player
extends CharacterBody2D
## Gracz: porusza się po arenie akcjami move_* z InputMap (WASD i strzałki,
## definicje w project.godot). Zbieranie jabłek obsługuje Apple, gracz o nich nie wie.

const SIZE: float = 32.0
const COLOR: Color = Color(0.23, 0.44, 0.82)

@export var speed: float = 240.0


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	# Arena to cały viewport, więc trzymamy gracza w jego granicach.
	var arena: Rect2 = get_viewport_rect().grow(-SIZE * 0.5)
	global_position = global_position.clamp(arena.position, arena.end)


func _draw() -> void:
	draw_rect(Rect2(Vector2(-SIZE, -SIZE) * 0.5, Vector2(SIZE, SIZE)), COLOR)


## Włącza lub wyłącza sterowanie (np. po końcu rundy).
func set_active(active: bool) -> void:
	set_physics_process(active)
	velocity = Vector2.ZERO

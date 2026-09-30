# miernik

Projekt w Godot 4 (GDScript) z agentem Claude do code review na pull requestach.
Repo: `DragonMaxxx/miernik`. Odpowiadaj po polsku.

## Stan na 2026-09-30

- Jest szkielet projektu (`project.godot`, `scenes/main.tscn`, `scripts/main.gd`) i dwa workflowy w `.github/workflows/`.
- Nie otwierano go jeszcze w edytorze Godot. Rodzaj gry (2D/3D) nie jest ustalony.
- Założenia domyślne (do zmiany przez właściciela): Godot 4.4, GDScript, renderer GL Compatibility, agent komentuje każdy PR automatycznie i reaguje na `@claude`.
- Sekret `ANTHROPIC_API_KEY` (Settings → Secrets and variables → Actions) musi dodać właściciel. Bez niego workflowy nie działają.
- Pracujemy na branchu `claude/friendly-lovelace-tbx807`. PR-ów nie zakładamy bez wyraźnej prośby.

## Struktura

- `scenes/` sceny `.tscn`, `scripts/` skrypty `.gd`.
- `.godot/` jest w `.gitignore`. Pliki `*.import` obok assetów MUSZĄ być w repo.

## Konwencje GDScript

- Wcięcia tabulatorami, `snake_case` dla funkcji i zmiennych, `PascalCase` dla klas, `UPPER_CASE` dla stałych.
- Statyczne typowanie wszędzie: `var x: int`, `func f(a: Node) -> void`.
- Prywatne składowe z prefiksem `_`.

## Zasady code review

Kolejność ważności: błędy i crashe > wycieki/wydajność > czytelność. Nie komentuj formatowania (to robi `gdformat`). Nie komentuj szumu w `.tscn` (uid, offsety, `load_steps`).

Checklista GDScript:

- Brak typów w zmiennych, parametrach i zwracanych wartościach.
- `get_node`/`$Node` wywoływane w `_process`/`_physics_process` zamiast cache'owania przez `@onready`.
- Dostęp do węzła, który mógł zostać zwolniony, bez `is_instance_valid()`. `await` na sygnale węzła, który może zniknąć.
- Sygnały: podłączone wielokrotnie, niepodłączone w `_ready`, brak rozłączenia przy zwalnianiu odbiorcy. Literówki w nazwach sygnałów i metod (stringi).
- `free()` zamiast `queue_free()` na węźle w drzewie. Węzły tworzone przez `Node.new()` i nigdy niedodane do drzewa ani niezwolnione.
- Logika fizyki w `_process` (lub odwrotnie), `delta` pominięte w ruchu.
- `load()` w pętli lub w `_process` zamiast `preload()`/cache. Alokacje (tablice, słowniki, `Vector2` w pętli) w gorącej ścieżce.
- Nieotypowane `@export`. Zależność od kolejności dzieci w drzewie (`get_child(0)`).
- Autoloady używane jako globalny stan bez potrzeby.
- Assety dodane bez plików `*.import`. Przypadkowo dodane `.godot/`.

Format odpowiedzi: komentarz inline przy konkretnej linii, z poziomem ważności (błąd / ostrzeżenie / sugestia) i proponowaną poprawką. Na końcu jedno krótkie podsumowanie. Nie zatwierdzaj i nie merguj PR-ów.
